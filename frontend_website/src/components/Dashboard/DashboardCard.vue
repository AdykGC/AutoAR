<template>
  <div class="root flex min-h-screen bg-gray-50 dark:bg-background-dark">
    <!-- Sidebar -->
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
            to="/tasks" 
            class="navlink flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
          >
            <span class="material-symbols-outlined">folder</span>
            <span>All Requests</span>
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

    <!-- Main Content -->
    <main class="flex-1 flex flex-col">
      <!-- Topbar -->
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
          </button>
          
          <div class="flex items-center space-x-3">
            <div class="avatar w-9 h-9 rounded-full bg-gradient-to-r from-blue-500 to-purple-600 flex items-center justify-center text-white font-semibold">
              {{ userInitials }}
            </div>
            <div class="hidden md:block">
              <p class="text-sm font-medium text-gray-800 dark:text-white">{{ userName }}</p>
              <p class="text-xs text-gray-500 dark:text-gray-400">{{ userRole }}</p>
            </div>
          </div>
        </div>
      </header>

      <!-- Page Content -->
      <section class="page flex-1 p-6">
        <!-- Page Header -->
        <div class="page-head mb-8 flex flex-col md:flex-row md:items-center justify-between">
          <div>
            <h2 class="text-2xl font-bold text-gray-800 dark:text-white mb-2">Welcome back, {{ userName }}!</h2>
            <p class="text-gray-600 dark:text-gray-400">
              Here's a summary of your activity. Today is {{ currentDate }}.
            </p>
          </div>
          
          <div class="mt-4 md:mt-0">
            <button class="btn-primary bg-primary hover:bg-primary/90 text-white px-6 py-3 rounded-lg font-medium transition-colors flex items-center space-x-2">
              <span class="material-symbols-outlined text-lg">add</span>
              <span>Submit New Request</span>
            </button>
          </div>
        </div>

        <!-- Grid -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <!-- Left Column (2/3) -->
          <div class="lg:col-span-2 space-y-6">
            <!-- Pending Requests Card -->
            <div class="card bg-white dark:bg-slate-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-gray-800 dark:text-white">Your Pending Requests</h3>
                <router-link to="/tasks" class="text-sm text-primary hover:text-primary/80 font-medium">
                  View All
                </router-link>
              </div>
              
              <div class="overflow-auto">
                <table class="w-full">
                  <thead>
                    <tr class="text-left text-sm text-gray-600 dark:text-gray-400">
                      <th class="pb-3 font-medium">Request Type</th>
                      <th class="pb-3 font-medium">Request ID</th>
                      <th class="pb-3 font-medium">Date Submitted</th>
                      <th class="pb-3 font-medium">Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="request in pendingRequests" :key="request.id" class="border-t border-gray-100 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-slate-700/50">
                      <td class="py-4 text-sm font-medium text-gray-800 dark:text-gray-200">{{ request.type }}</td>
                      <td class="py-4 text-sm text-gray-500 dark:text-gray-400">{{ request.id }}</td>
                      <td class="py-4 text-sm text-gray-500 dark:text-gray-400">{{ request.date }}</td>
                      <td class="py-4">
                        <span :class="`status ${request.statusClass} inline-flex items-center px-3 py-1 rounded-full text-xs font-medium`">
                          <span class="w-2 h-2 rounded-full mr-2" :style="{ backgroundColor: request.statusColor }"></span>
                          {{ request.status }}
                        </span>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- Quick Actions Card -->
            <div class="card bg-white dark:bg-slate-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
              <h3 class="text-lg font-semibold text-gray-800 dark:text-white mb-4">What would you like to do?</h3>
              
              <div class="quicklinks grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div v-for="action in quickActions" :key="action.id"
                  class="quick bg-gray-50 dark:bg-slate-700/50 hover:bg-gray-100 dark:hover:bg-slate-700 rounded-lg p-4 text-center cursor-pointer transition-colors"
                  @click="handleQuickAction(action.action)"
                >
                  <div class="icon w-12 h-12 rounded-lg bg-primary/10 dark:bg-primary/20 flex items-center justify-center mx-auto">
                    <span class="material-symbols-outlined text-primary text-xl">{{ action.icon }}</span>
                  </div>
                  <p class="mt-3 font-semibold text-gray-800 dark:text-white">{{ action.title }}</p>
                  <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">{{ action.description }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Right Column (1/3) -->
          <div class="lg:col-span-1">
            <!-- Recent Activity Card -->
            <div class="card bg-white dark:bg-slate-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
              <h3 class="text-lg font-semibold text-gray-800 dark:text-white mb-4">Recent Activity</h3>
              
              <div class="activity space-y-4">
                <div v-for="activity in recentActivities" :key="activity.id" 
                  class="activity-row flex space-x-3 p-3 rounded-lg hover:bg-gray-50 dark:hover:bg-slate-700/50 transition-colors"
                >
                  <div class="badge flex-shrink-0 w-10 h-10 rounded-lg flex items-center justify-center" :style="{ backgroundColor: activity.bgColor, color: activity.color }">
                    <span class="material-symbols-outlined">{{ activity.icon }}</span>
                  </div>
                  
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-semibold text-gray-800 dark:text-white mb-1">{{ activity.title }}</p>
                    <p class="text-xs text-gray-500 dark:text-gray-400">{{ activity.time }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import authService from '../../services/auth.service.js'

const router = useRouter()

// Данные пользователя
const userData = ref({
  name: 'Alex',
  role: 'Employee'
})

// Инициализация
onMounted(() => {
  const storedUser = authService.getUserData()
  if (storedUser) {
    userData.value.name = storedUser.name || 'Alex'
    userData.value.role = storedUser.role || 'Employee'
  }
})

// Вычисляемые свойства
const userName = computed(() => userData.value.name)
const userRole = computed(() => userData.value.role)
const userInitials = computed(() => {
  const name = userData.value.name || 'A'
  return name.charAt(0).toUpperCase()
})

const currentDate = computed(() => {
  const now = new Date()
  const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
  return now.toLocaleDateString('en-US', options)
})

// Данные для таблицы
const pendingRequests = ref([
  { id: '#789123', type: 'PTO Request', date: 'Oct 23, 2023', status: 'Pending Approval', statusClass: 'pending', statusColor: '#f97316' },
  { id: '#789122', type: 'Expense Report', date: 'Oct 22, 2023', status: 'Needs Information', statusClass: 'info', statusColor: '#0284c7' },
  { id: '#789120', type: 'Hardware Request', date: 'Oct 20, 2023', status: 'Pending Approval', statusClass: 'pending', statusColor: '#f97316' }
])

// Быстрые действия
const quickActions = ref([
  { id: 1, icon: 'event_available', title: 'Request Time Off', description: 'Submit PTO request', action: 'timeoff' },
  { id: 2, icon: 'receipt_long', title: 'Submit Expense', description: 'Create expense report', action: 'expense' },
  { id: 3, icon: 'computer', title: 'Request Hardware', description: 'Order equipment', action: 'hardware' }
])

// Последние активности
const recentActivities = ref([
  { id: 1, icon: 'check_circle', title: 'Your PTO request #789121 was approved by Jane Doe.', time: '2 hours ago', bgColor: '#ecfdf5', color: '#059669' },
  { id: 2, icon: 'cancel', title: 'Your expense report #789115 was rejected.', time: 'Yesterday', bgColor: '#fff1f2', color: '#ef4444' },
  { id: 3, icon: 'chat', title: 'John Smith commented on your hardware request #789120.', time: '3 days ago', bgColor: '#eff6ff', color: '#2563eb' },
  { id: 4, icon: 'campaign', title: 'System announcement: The office will be closed on Friday.', time: '4 days ago', bgColor: '#f8fafc', color: '#475569' }
])

// Обработчики
const handleQuickAction = (action) => {
  console.log('Quick action:', action)
  // Здесь можно добавить логику для каждого действия
  switch(action) {
    case 'timeoff':
      router.push('/requests/timeoff')
      break
    case 'expense':
      router.push('/requests/expense')
      break
    case 'hardware':
      router.push('/requests/hardware')
      break
  }
}
</script>

<style scoped>
/* Дополнительные стили для компонента */
.navlink.active {
  background-color: rgba(19, 91, 236, 0.1);
  color: #135bec;
}

.navlink.active .material-symbols-outlined {
  color: #135bec;
}

.status.pending {
  background-color: #fef3c7;
  color: #d97706;
}

.status.info {
  background-color: #dbeafe;
  color: #1d4ed8;
}

.card {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

.quick:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}
</style>