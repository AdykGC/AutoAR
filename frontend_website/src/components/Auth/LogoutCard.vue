<template>
  <div class="min-h-screen flex flex-col items-center justify-center bg-gray-50 dark:bg-gray-900">
    <div class="max-w-md w-full space-y-8 p-8 bg-white dark:bg-gray-800 rounded-xl shadow-lg">
      <div class="text-center">
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-4">
          Logout Test Page
        </h1>
        <p class="text-gray-600 dark:text-gray-300 mb-8">
          Test authentication and logout functionality
        </p>
      </div>

      <!-- Current User Info -->
      <div class="bg-gray-100 dark:bg-gray-700 p-4 rounded-lg mb-6">
        <h2 class="text-lg font-semibold text-gray-800 dark:text-white mb-2">
          Current Session Info
        </h2>
        <div class="space-y-2 text-sm">
          <div class="flex justify-between">
            <span class="text-gray-600 dark:text-gray-300">Authenticated:</span>
            <span :class="isAuthenticated ? 'text-green-600 font-bold' : 'text-red-600 font-bold'">
              {{ isAuthenticated ? 'YES' : 'NO' }}
            </span>
          </div>
          <div v-if="userData" class="space-y-1">
            <div class="flex justify-between">
              <span class="text-gray-600 dark:text-gray-300">User:</span>
              <span class="text-gray-800 dark:text-white font-medium">{{ userData.email }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-600 dark:text-gray-300">Name:</span>
              <span class="text-gray-800 dark:text-white">{{ userData.name }} {{ userData.surname }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-600 dark:text-gray-300">Role:</span>
              <span class="text-gray-800 dark:text-white">{{ userRole }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-600 dark:text-gray-300">Token:</span>
              <span class="text-gray-800 dark:text-white font-mono text-xs">
                {{ tokenPreview }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div class="space-y-4">
        <button
          @click="handleLogout"
          class="w-full py-3 px-4 bg-red-600 hover:bg-red-700 text-white font-semibold rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2"
          :disabled="loading"
        >
          <span v-if="loading">Logging out...</span>
          <span v-else>Logout Now</span>
        </button>

        <button
          @click="checkAuthStatus"
          class="w-full py-2 px-4 bg-blue-100 dark:bg-blue-900 hover:bg-blue-200 dark:hover:bg-blue-800 text-blue-700 dark:text-blue-300 font-medium rounded-lg transition-colors"
        >
          Refresh Status
        </button>

        <button
          @click="clearLocalStorage"
          class="w-full py-2 px-4 bg-yellow-100 dark:bg-yellow-900 hover:bg-yellow-200 dark:hover:bg-yellow-800 text-yellow-700 dark:text-yellow-300 font-medium rounded-lg transition-colors"
        >
          Clear LocalStorage
        </button>

        <div class="flex space-x-4">
          <button
            @click="goToLogin"
            class="flex-1 py-2 px-4 bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 text-gray-700 dark:text-gray-300 font-medium rounded-lg transition-colors"
          >
            Go to Login
          </button>
          <button
            @click="goToDashboard"
            class="flex-1 py-2 px-4 bg-green-100 dark:bg-green-900 hover:bg-green-200 dark:hover:bg-green-800 text-green-700 dark:text-green-300 font-medium rounded-lg transition-colors"
          >
            Go to Dashboard
          </button>
        </div>
      </div>

      <!-- Messages -->
      <div v-if="message" class="p-3 rounded-lg" :class="messageType === 'success' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'">
        {{ message }}
      </div>

      <!-- LocalStorage Data (for debugging) -->
      <details class="mt-6">
        <summary class="cursor-pointer text-gray-600 dark:text-gray-400 font-medium">
          Debug Info (LocalStorage)
        </summary>
        <div class="mt-2 p-3 bg-gray-900 text-gray-100 font-mono text-xs rounded-lg overflow-auto max-h-60">
          <pre>{{ debugInfo }}</pre>
        </div>
      </details>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import authService from '../../services/auth.service.js'

const router = useRouter()

// Состояния
const loading = ref(false)
const message = ref('')
const messageType = ref('')

// Данные из authService
const isAuthenticated = computed(() => authService.isAuthenticated())
const userData = computed(() => authService.getUserData())
const token = computed(() => authService.getToken())
const userRole = computed(() => authService.getUserRole())
const tokenPreview = computed(() => {
  const t = token.value
  return t ? `${t.substring(0, 20)}...` : 'No token'
})

// Отладочная информация
const debugInfo = computed(() => {
  const allStorage = {}
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i)
    try {
      allStorage[key] = JSON.parse(localStorage.getItem(key))
    } catch {
      allStorage[key] = localStorage.getItem(key)
    }
  }
  return allStorage
})

onMounted(() => {
  console.log('🔍 Logout page mounted')
  console.log('- Authenticated:', isAuthenticated.value)
  console.log('- User:', userData.value?.email)
  console.log('- Token exists:', !!token.value)
})

const showMessage = (text, type = 'info') => {
  message.value = text
  messageType.value = type
  setTimeout(() => {
    message.value = ''
  }, 5000)
}

// Логаут
const handleLogout = async () => {
  try {
    loading.value = true
    message.value = ''
    
    if (!isAuthenticated.value) {
      showMessage('You are not logged in', 'error')
      loading.value = false
      return
    }

    console.log('🚪 Starting logout process...')
    
    // Используем authService для выхода
    await authService.logout()
    
    console.log('✅ Logout successful')
    showMessage('Successfully logged out!', 'success')
    
    // Обновляем состояние
    setTimeout(() => {
      router.push('/login')
    }, 1500)
    
  } catch (err) {
    console.error('❌ Logout error:', err)
    showMessage(`Logout failed: ${err.message}`, 'error')
  } finally {
    loading.value = false
  }
}

// Проверка статуса аутентификации
const checkAuthStatus = () => {
  console.log('🔄 Refreshing auth status...')
  console.log('- isAuthenticated:', authService.isAuthenticated())
  console.log('- User data:', authService.getUserData())
  console.log('- Token:', authService.getToken()?.substring(0, 30) + '...')
  
  showMessage('Auth status refreshed. Check console for details.', 'success')
}

// Очистка localStorage
const clearLocalStorage = () => {
  localStorage.clear()
  console.log('🧹 LocalStorage cleared')
  showMessage('LocalStorage cleared! Page will reload.', 'success')
  
  setTimeout(() => {
    window.location.reload()
  }, 1000)
}

// Навигация
const goToLogin = () => {
  router.push('/login')
}

const goToDashboard = () => {
  if (isAuthenticated.value) {
    router.push('/dashboard')
  } else {
    showMessage('You need to login first', 'error')
  }
}
</script>

<style scoped>
details summary::-webkit-details-marker {
  display: none;
}

details summary {
  list-style: none;
}

pre {
  white-space: pre-wrap;
  word-wrap: break-word;
}
</style>