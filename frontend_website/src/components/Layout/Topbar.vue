<template>
  <header class="topbar bg-white dark:bg-slate-800 border-b border-gray-200 dark:border-gray-700 px-6 py-4 flex items-center justify-between">
    <div class="search flex items-center flex-1 max-w-xl">
      <span class="material-symbols-outlined text-gray-400 mr-3">search</span>
      <input 
        placeholder="Search" 
        class="w-full bg-transparent border-none focus:outline-none text-gray-700 dark:text-gray-300 placeholder-gray-500"
      />
    </div>
    
    <div class="top-actions flex items-center space-x-4">
      <button class="icon-btn p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors" title="Notifications">
        <span class="material-symbols-outlined text-gray-600 dark:text-gray-400">notifications</span>
        <span v-if="notificationCount > 0" class="notification-badge">
          {{ notificationCount }}
        </span>
      </button>
      
      <div class="user-profile flex items-center space-x-3 cursor-pointer" @click="toggleUserMenu">
        <div class="avatar w-9 h-9 rounded-full bg-gradient-to-r from-blue-500 to-purple-600 flex items-center justify-center text-white font-semibold">
          {{ userInitials }}
        </div>
        <div class="hidden md:block">
          <p class="text-sm font-medium text-gray-800 dark:text-white">{{ userName }}</p>
          <p class="text-xs text-gray-500 dark:text-gray-400">{{ userRole }}</p>
        </div>
        <span class="material-symbols-outlined text-gray-500">expand_more</span>
      </div>
    </div>

    <!-- User Dropdown Menu -->
    <div v-if="showUserMenu" class="user-menu absolute right-6 top-16 mt-2 w-48 bg-white dark:bg-slate-800 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700 z-50">
      <div class="p-4 border-b border-gray-200 dark:border-gray-700">
        <p class="font-medium text-gray-800 dark:text-white">{{ userName }}</p>
        <p class="text-sm text-gray-500 dark:text-gray-400">{{ userEmail }}</p>
      </div>
      <div class="py-1">
        <router-link to="/profile" class="menu-item">
          <span class="material-symbols-outlined">person</span>
          My Profile
        </router-link>
        <router-link to="/settings" class="menu-item">
          <span class="material-symbols-outlined">settings</span>
          Settings
        </router-link>
        <div class="menu-item text-red-500" @click="handleLogout">
          <span class="material-symbols-outlined">logout</span>
          Logout
        </div>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import authService from '../../services/auth.service.js'

const router = useRouter()
const showUserMenu = ref(false)
const notificationCount = ref(3) // Примерное количество уведомлений

// Получаем данные пользователя
const userData = computed(() => authService.getUserData() || {})

const userName = computed(() => {
  const user = userData.value
  if (user.name && user.surname) {
    return `${user.name} ${user.surname}`
  }
  return user.name || user.email || 'User'
})

const userEmail = computed(() => userData.value.email || '')
const userRole = computed(() => userData.value.roles?.[0]?.name || 'User')
const userInitials = computed(() => {
  const name = userData.value.name || 'U'
  return name.charAt(0).toUpperCase()
})

// Переключение меню
const toggleUserMenu = () => {
  showUserMenu.value = !showUserMenu.value
}

// Закрытие меню при клике вне его
const handleClickOutside = (event) => {
  if (!event.target.closest('.user-profile') && !event.target.closest('.user-menu')) {
    showUserMenu.value = false
  }
}

// Логаут
const handleLogout = async () => {
  try {
    await authService.logout()
    router.push('/login')
  } catch (error) {
    console.error('Logout error:', error)
  }
}

// Жизненный цикл
onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.notification-badge {
  position: absolute;
  top: -2px;
  right: -2px;
  background-color: #ef4444;
  color: white;
  border-radius: 50%;
  width: 18px;
  height: 18px;
  font-size: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.user-menu {
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  color: #374151;
  text-decoration: none;
  transition: background-color 0.2s;
}

.menu-item:hover {
  background-color: #f3f4f6;
}

.dark .menu-item {
  color: #d1d5db;
}

.dark .menu-item:hover {
  background-color: #374151;
}

.menu-item .material-symbols-outlined {
  font-size: 18px;
}
</style>