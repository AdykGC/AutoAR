<template>
  <div class="relative flex min-h-screen w-full flex-col overflow-x-hidden">
    <div class="layout-container flex h-full grow flex-col">
      <main class="flex flex-1 items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div class="w-full max-w-md space-y-8">
          <div class="flex flex-col gap-3 text-center">
            <p class="custom-heading">
              Welcome to the Rubicon
            </p>
            <p class="deprecated-text">
              Enter your credentials to access your account.
            </p>
          </div>

          <div class="bg-white dark:bg-background-dark/50 rounded-xl shadow-lg p-6 sm:p-8 border border-gray-200 dark:border-gray-800">
            <!-- Табы для переключения -->
            <div class="flex h-10 flex-1 items-center justify-center rounded-lg bg-[#e7ebf3] dark:bg-gray-800 p-1 mb-6">
              <router-link 
                to="/login"
                class="flex cursor-pointer h-full grow items-center justify-center overflow-hidden rounded-lg px-2 text-sm font-medium leading-normal transition-all"
                :class="{
                  'bg-white dark:bg-gray-700 text-[#0d121b] dark:text-white shadow-[0_1px_3px_rgba(0,0,0,0.1)]': $route.path === '/login',
                  'text-gray-500 dark:text-gray-400 hover:bg-white dark:hover:bg-gray-700 hover:text-[#0d121b] dark:hover:text-white': $route.path !== '/login'
                }"
              >
                <span class="truncate">Sign In</span>
              </router-link>

              <router-link 
                to="/register"
                class="flex cursor-pointer h-full grow items-center justify-center overflow-hidden rounded-lg px-2 text-sm font-medium leading-normal transition-all"
                :class="{
                  'bg-white dark:bg-gray-700 text-[#0d121b] dark:text-white shadow-[0_1px_3px_rgba(0,0,0,0.1)]': $route.path === '/register',
                  'text-gray-500 dark:text-gray-400 hover:bg-white dark:hover:bg-gray-700 hover:text-[#0d121b] dark:hover:text-white': $route.path !== '/register'
                }"
              >
                <span class="truncate">Register</span>
              </router-link>
            </div>

            <!-- Сообщение об ошибке -->
            <div v-if="error" class="mb-4 p-3 bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-800 rounded-lg">
              <p class="text-red-700 dark:text-red-300 text-sm">{{ error }}</p>
            </div>

            <!-- Форма логина -->
            <form @submit.prevent="handleLogin" class="space-y-6">
              <div class="space-y-4">
                <!-- Email -->
                <label class="flex flex-col flex-1">
                  <p class="text-[#0d121b] dark:text-gray-200 text-sm font-medium leading-normal pb-2">
                    Work Email Address
                  </p>
                  <div class="relative flex w-full flex-1 items-stretch">
                    <div class="text-gray-400 dark:text-gray-500 pointer-events-none absolute inset-y-0 left-0 flex items-center justify-center pl-4">
                      <span class="material-symbols-outlined text-xl">mail</span>
                    </div>
                    <input 
                      v-model="loginForm.email"
                      class="form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden rounded-lg text-[#0d121b] dark:text-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/50 border border-gray-300 dark:border-gray-700 bg-background-light dark:bg-gray-800 focus:border-primary h-12 placeholder:text-gray-400 dark:placeholder:text-gray-500 pl-12 pr-4 text-base font-normal leading-normal"
                      placeholder="you@youremail.com"
                      type="email"
                      required
                    />
                  </div>
                </label>

                <!-- Password -->
                <div class="flex flex-col flex-1">
                  <label>
                    <p class="text-[#0d121b] dark:text-gray-200 text-sm font-medium leading-normal pb-2">
                      Password
                    </p>
                    <div class="relative flex w-full flex-1 items-stretch">
                      <!-- Lock Icon -->
                      <div class="text-gray-400 dark:text-gray-500 pointer-events-none absolute inset-y-0 left-0 flex items-center justify-center pl-4">
                        <span class="material-symbols-outlined text-xl">lock</span>
                      </div>

                      <!-- Password Input -->
                      <input 
                        v-model="loginForm.password"
                        :type="showPassword ? 'text' : 'password'"
                        class="form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden rounded-lg text-[#0d121b] dark:text-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/50 border border-gray-300 dark:border-gray-700 bg-background-light dark:bg-gray-800 focus:border-primary h-12 placeholder:text-gray-400 dark:placeholder:text-gray-500 pl-12 pr-12 text-base font-normal leading-normal"
                        placeholder="Enter your password"
                        required
                      />

                      <!-- Toggle Button -->
                      <button 
                        @click="showPassword = !showPassword"
                        type="button"
                        class="text-gray-400 dark:text-gray-500 absolute inset-y-0 right-0 flex cursor-pointer items-center justify-center pr-4"
                      >
                        <span class="material-symbols-outlined text-xl">
                          {{ showPassword ? 'visibility_off' : 'visibility' }}
                        </span>
                      </button>
                    </div>
                  </label>
                </div>
              </div>

              <div class="flex items-center justify-end">
                <div class="text-sm">
                  <router-link to="/forgot" class="font-medium text-primary hover:text-primary/80">
                    Forgot Password?
                  </router-link>
                </div>
              </div>

              <button 
                :disabled="loading"
                class="group relative flex w-full justify-center rounded-lg bg-primary py-3 px-4 text-sm font-semibold text-white hover:bg-primary/90 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 dark:focus:ring-offset-background-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                type="submit"
              >
                <span v-if="loading">Signing in...</span>
                <span v-else>Sign In</span>
              </button>

              <div class="text-center text-sm text-gray-500 dark:text-gray-400 pt-4">
                <a class="font-medium text-primary hover:text-primary/80 cursor-pointer"> </a>
              </div>
            </form>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import authService from '../../services/auth.service.js' // Используем ваш authService

const router = useRouter()

// Состояния
const loading = ref(false)
const error = ref('')
const showPassword = ref(false)

// Форма логина
const loginForm = reactive({
  email: '',
  password: ''
})

// Автозаполнение для тестирования
onMounted(() => {
  // Используйте существующие данные
  loginForm.email = 'register@crm.test3'
  loginForm.password = 'password123'
})

// Логин с использованием authService
const handleLogin = async () => {
  try {
    loading.value = true
    error.value = ''

    // Базовая валидация
    if (!loginForm.email || !loginForm.password) {
      error.value = 'Please enter email and password'
      loading.value = false
      return
    }

    console.log('📤 Attempting login...')

    // Используем authService для логина
    const response = await authService.login(loginForm.email, loginForm.password)
    
    console.log('✅ Login successful via authService')
    
    // Проверяем, что пользователь сохранен
    const userData = authService.getUserData()
    const token = authService.getToken()
    
    if (token && userData) {
      console.log('✅ Token and user data saved')
      console.log('- User:', userData.email)
      console.log('- Role:', userData.roles?.[0]?.name)
      console.log('- Token (first 20 chars):', token.substring(0, 20) + '...')
      
      // Перенаправляем на дашборд
      router.push('/dashboard')
    } else {
      error.value = 'Login successful but data not saved properly'
    }
    
  } catch (err) {
    console.error('❌ Login error:', err.message)
    error.value = err.message || 'Login failed. Please try again.'
  } finally {
    loading.value = false
  }
}
</script>