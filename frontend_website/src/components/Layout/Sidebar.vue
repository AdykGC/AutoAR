<template>
  <nav class="sidebar w-64 bg-white dark:bg-slate-800 border-r border-gray-200 dark:border-gray-700 flex flex-col">
    <!-- Brand -->
    <div class="p-6 border-b border-gray-200 dark:border-gray-700">
      <div class="brand flex items-center space-x-3">
        <div class="logo w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center">
          <span class="material-symbols-outlined text-primary text-xl">auto_awesome</span>
        </div>
        <div>
          <h1 class="text-xl font-bold text-gray-800 dark:text-white">AutoAr</h1>
          <p class="text-xs text-gray-500 dark:text-gray-400">Automation Hub</p>
        </div>
      </div>
    </div>

    <!-- Navigation -->
    <div class="flex-1 p-4">
      <div class="navlist space-y-1">
        <router-link 
          to="/dashboard" 
          class="navlink flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
          :class="{ 'active bg-blue-50 dark:bg-blue-900/20 text-primary dark:text-blue-300': $route.path === '/dashboard' }"
        >
          <span class="material-symbols-outlined">dashboard</span>
          <span>Dashboard</span>
        </router-link>
        
        <router-link 
          to="/task" 
          class="navlink flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
          :class="{ 'active bg-blue-50 dark:bg-blue-900/20 text-primary dark:text-blue-300': $route.path === '/task' }"
        >
          <span class="material-symbols-outlined">folder</span>
          <span>Requests</span>
        </router-link>
        
        <router-link 
          to="/reports" 
          class="navlink flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
        >
          <span class="material-symbols-outlined">bar_chart</span>
          <span>Reports</span>
        </router-link>
        
        <router-link 
          to="/settings" 
          class="navlink flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
        >
          <span class="material-symbols-outlined">settings</span>
          <span>Settings</span>
        </router-link>
        
        <!-- Logout link -->
        <router-link 
          to="/logout" 
          class="navlink flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors mt-8"
        >
          <span class="material-symbols-outlined text-red-500">logout</span>
          <span class="text-red-500">Logout</span>
        </router-link>
      </div>
    </div>

    <!-- Bottom Help -->
    <div class="p-4 border-t border-gray-200 dark:border-gray-700">
      <router-link 
        to="/help" 
        class="navlink flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
      >
        <span class="material-symbols-outlined">help</span>
        <span>Help</span>
      </router-link>
    </div>
  </nav>
</template>

<script setup>
import { computed } from 'vue'
import authService from '../../services/auth.service.js'

const userRole = computed(() => {
  const user = authService.getUserData()
  return user?.roles?.[0]?.name || 'User'
})
</script>

<style scoped>
.navlink.active {
  background-color: rgba(19, 91, 236, 0.1);
  color: #135bec;
}

.navlink.active .material-symbols-outlined {
  color: #135bec;
}
</style>