<template>
  <div class="root flex min-h-screen bg-gray-50 dark:bg-background-dark">
    <!-- Sidebar -->
    <nav class="sidebar w-64 bg-white dark:bg-background-dark border-r border-slate-200 dark:border-slate-800 flex flex-col">
      <div class="flex h-full min-h-[700px] flex-col justify-between p-4">
        <div class="flex flex-col gap-4">
          <!-- Brand -->
          <div class="flex gap-3 items-center px-2">
            <div class="rounded-full size-10 flex items-center justify-center">
              <svg class="text-primary h-12 w-12" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24">
                <path d="M12 2L2 7l10 5 10-5-10-5z"></path>
                <path d="M2 17l10 5 10-5"></path>
                <path d="M2 12l10 5 10-5"></path>
              </svg>
            </div>
            <div class="flex flex-col">
              <h1 class="text-slate-900 dark:text-white text-base font-bold leading-normal">AutoAr</h1>
              <p class="text-slate-500 dark:text-slate-400 text-sm font-normal leading-normal">Automation Hub</p>
            </div>
          </div>

          <!-- Navigation -->
          <div class="flex flex-col gap-2 pt-4">
            <router-link to="/dashboard" class="nav-item">
              <span class="material-symbols-outlined">dashboard</span>
              <span>Dashboard</span>
            </router-link>
            
            <router-link to="/requests" class="nav-item">
              <span class="material-symbols-outlined">folder</span>
              <span>All Requests</span>
            </router-link>
            
            <router-link to="/cv-generation" class="nav-item">
              <span class="material-symbols-outlined">person</span>
              <span>CV</span>
            </router-link>
            
            <router-link to="/calendar" class="nav-item active">
              <span class="material-symbols-outlined">calendar_month</span>
              <span>Jobs Calendar</span>
            </router-link>
          </div>
        </div>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="flex-1 flex flex-col">
      <!-- Header -->
      <header class="header">
        <!-- Search -->
        <div class="search-container">
          <span class="material-symbols-outlined search-icon">search</span>
          <input 
            v-model="searchQuery"
            class="search-input"
            placeholder="Search"
          />
        </div>
        
        <div class="header-actions">
          <button class="notification-btn">
            <span class="material-symbols-outlined">notifications</span>
            <div class="notification-dot"></div>
          </button>
        </div>
      </header>

      <!-- Content -->
      <div class="flex-1 p-10">
        <!-- Page Header -->
        <div class="flex justify-between items-center mb-8">
          <h1 class="page-title">Jobs Calendar</h1>
          
          <!-- Month Navigation -->
          <div class="flex items-center gap-2">
            <button @click="prevMonth" class="month-nav-btn">
              <span class="material-symbols-outlined text-xl">chevron_left</span>
            </button>
            
            <span class="month-label">
              {{ monthNames[currentMonth] }} {{ currentYear }}
            </span>
            
            <button @click="nextMonth" class="month-nav-btn">
              <span class="material-symbols-outlined text-xl">chevron_right</span>
            </button>
          </div>
        </div>

        <!-- Main Grid -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <!-- Calendar (2/3) -->
          <div class="lg:col-span-2">
            <div class="calendar-wrapper">
              <!-- Week Days Header -->
              <div class="weekdays-header">
                <div v-for="day in weekDays" :key="day" class="weekday">
                  {{ day }}
                </div>
              </div>
              
              <!-- Calendar Grid -->
              <div class="calendar-grid">
                <div 
                  v-for="day in calendarDays" 
                  :key="day.key"
                  :class="[
                    'calendar-day',
                    { 'current-month': day.isCurrentMonth },
                    { 'selected': selectedDate === day.date },
                    { 'has-tasks': hasTasks(day.date) }
                  ]"
                  @click="selectDay(day)"
                >
                  <div class="day-number">
                    {{ day.number }}
                  </div>
                  
                  <!-- Tasks for this day -->
                  <div v-if="hasTasks(day.date)" class="day-tasks">
                    <div 
                      v-for="(task, index) in getTasksForDay(day.date).slice(0, 2)" 
                      :key="index"
                      :class="taskClass(task.complexity)"
                      :title="task.title"
                    >
                      {{ task.title }}
                    </div>
                    <div 
                      v-if="getTasksForDay(day.date).length > 2"
                      class="more-tasks"
                    >
                      +{{ getTasksForDay(day.date).length - 2 }} more
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Task Details (1/3) -->
          <div class="lg:col-span-1">
            <div v-if="selectedTask" class="task-details">
              <div class="task-header">
                <h2 class="task-title">Task Details</h2>
                <button @click="closeTaskDetails" class="close-btn">
                  ✕
                </button>
              </div>
              
              <p class="task-date">{{ formatDate(selectedDate) }}</p>
              
              <div class="task-section">
                <h3 class="section-title">What you should do:</h3>
                <p class="task-description">{{ selectedTask.description }}</p>
              </div>
              
              <div class="task-info">
                <div class="info-row">
                  <span class="info-label">Reward</span>
                  <span class="info-value reward">{{ selectedTask.reward }}</span>
                </div>
                
                <div class="info-row">
                  <span class="info-label">Estimated Time</span>
                  <span class="info-value">{{ selectedTask.time }}</span>
                </div>
                
                <div class="info-row">
                  <span class="info-label">Complexity</span>
                  <span :class="complexityClass(selectedTask.complexity)">
                    {{ selectedTask.complexity }}
                  </span>
                </div>
              </div>
              
              <!-- Task Navigation -->
              <div v-if="selectedTasks.length > 1" class="task-navigation">
                <button 
                  @click="prevTask" 
                  :disabled="currentTaskIndex === 0"
                  class="nav-btn"
                >
                  ← Previous
                </button>
                
                <span class="task-counter">
                  {{ currentTaskIndex + 1 }} of {{ selectedTasks.length }}
                </span>
                
                <button 
                  @click="nextTask" 
                  :disabled="currentTaskIndex === selectedTasks.length - 1"
                  class="nav-btn"
                >
                  Next →
                </button>
              </div>
              
              <button class="accept-btn">
                Accept Task
              </button>
            </div>
            
            <div v-else class="empty-state">
              <div class="empty-icon">
                <span class="material-symbols-outlined">calendar_month</span>
              </div>
              <h3 class="empty-title">No Task Selected</h3>
              <p class="empty-description">
                Select a day from the calendar to view task details
              </p>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

// Month names
const monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
]

const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

// State
const searchQuery = ref('')
const currentMonth = ref(new Date().getMonth())
const currentYear = ref(new Date().getFullYear())
const selectedDate = ref(null)
const selectedTask = ref(null)
const selectedTasks = ref([])
const currentTaskIndex = ref(0)

// Tasks data
const tasks = {
  '2025-12-05': [
    {
      title: 'Server health check',
      description: 'Check CPU, memory usage, disk space and running services.',
      reward: '6,000 ₸',
      time: '1.5 hours',
      complexity: 'Low'
    },
    {
      title: 'Monitor check',
      description: 'Check monitors',
      reward: '8,000 ₸',
      time: '1 hour',
      complexity: 'High'
    }
  ],
  '2025-12-12': [
    {
      title: 'Deploy new API version',
      description: 'Deploy v2 of REST API and run smoke tests.',
      reward: '25,000 ₸',
      time: '6 hours',
      complexity: 'High'
    }
  ],
  '2025-12-15': [
    {
      title: 'Database backup',
      description: 'Perform weekly database backup and verification.',
      reward: '10,000 ₸',
      time: '3 hours',
      complexity: 'Medium'
    }
  ]
}

// Calendar days computation
const calendarDays = computed(() => {
  const days = []
  const firstDay = new Date(currentYear.value, currentMonth.value, 1)
  const lastDay = new Date(currentYear.value, currentMonth.value + 1, 0)
  const daysInMonth = lastDay.getDate()
  const firstDayIndex = firstDay.getDay()
  
  // Previous month days
  const prevMonthLastDay = new Date(currentYear.value, currentMonth.value, 0).getDate()
  for (let i = firstDayIndex; i > 0; i--) {
    const dayNumber = prevMonthLastDay - i + 1
    const date = new Date(currentYear.value, currentMonth.value - 1, dayNumber)
    days.push({
      key: `prev-${dayNumber}`,
      number: dayNumber,
      date: formatDateForDay(date),
      isCurrentMonth: false
    })
  }
  
  // Current month days
  for (let i = 1; i <= daysInMonth; i++) {
    const date = new Date(currentYear.value, currentMonth.value, i)
    days.push({
      key: `current-${i}`,
      number: i,
      date: formatDateForDay(date),
      isCurrentMonth: true
    })
  }
  
  // Next month days
  const totalCells = 42 // 6 weeks
  const nextMonthDays = totalCells - days.length
  for (let i = 1; i <= nextMonthDays; i++) {
    const date = new Date(currentYear.value, currentMonth.value + 1, i)
    days.push({
      key: `next-${i}`,
      number: i,
      date: formatDateForDay(date),
      isCurrentMonth: false
    })
  }
  
  return days
})

// Helper methods
const formatDateForDay = (date) => {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    weekday: 'long', 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  })
}

const hasTasks = (date) => {
  return tasks[date] && tasks[date].length > 0
}

const getTasksForDay = (date) => {
  return tasks[date] || []
}

const taskClass = (complexity) => {
  switch(complexity) {
    case 'High': return 'task-high'
    case 'Medium': return 'task-medium'
    case 'Low': return 'task-low'
    default: return ''
  }
}

const complexityClass = (complexity) => {
  switch(complexity) {
    case 'High': return 'complexity-high'
    case 'Medium': return 'complexity-medium'
    case 'Low': return 'complexity-low'
    default: return ''
  }
}

// Navigation methods
const prevMonth = () => {
  if (currentMonth.value === 0) {
    currentMonth.value = 11
    currentYear.value--
  } else {
    currentMonth.value--
  }
  clearSelection()
}

const nextMonth = () => {
  if (currentMonth.value === 11) {
    currentMonth.value = 0
    currentYear.value++
  } else {
    currentMonth.value++
  }
  clearSelection()
}

const selectDay = (day) => {
  if (!day.isCurrentMonth) return
  
  selectedDate.value = day.date
  selectedTasks.value = getTasksForDay(day.date)
  
  if (selectedTasks.value.length > 0) {
    currentTaskIndex.value = 0
    selectedTask.value = selectedTasks.value[0]
  } else {
    selectedTask.value = null
  }
}

const clearSelection = () => {
  selectedDate.value = null
  selectedTask.value = null
  selectedTasks.value = []
  currentTaskIndex.value = 0
}

const closeTaskDetails = () => {
  clearSelection()
}

const prevTask = () => {
  if (currentTaskIndex.value > 0) {
    currentTaskIndex.value--
    selectedTask.value = selectedTasks.value[currentTaskIndex.value]
  }
}

const nextTask = () => {
  if (currentTaskIndex.value < selectedTasks.value.length - 1) {
    currentTaskIndex.value++
    selectedTask.value = selectedTasks.value[currentTaskIndex.value]
  }
}

// Initialize with today's date
onMounted(() => {
  const today = new Date()
  const todayString = formatDateForDay(today)
  
  if (hasTasks(todayString)) {
    selectDay({
      date: todayString,
      isCurrentMonth: true,
      number: today.getDate()
    })
  }
})
</script>

<style scoped>
/* Sidebar */
.sidebar {
  transition: all 0.3s ease;
}

.nav-item {
  @apply flex items-center gap-3 px-3 py-2 rounded-lg text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 text-sm font-medium leading-normal transition-colors;
}

.nav-item.active {
  @apply bg-primary/10 text-primary dark:bg-primary/20 dark:text-blue-300;
}

/* Header */
.header {
  @apply flex items-center justify-between whitespace-nowrap border-b border-solid border-slate-200 dark:border-slate-800 px-10 py-3 bg-white dark:bg-background-dark sticky top-0 z-10;
}

.search-container {
  @apply flex flex-col min-w-40 !h-10 max-w-64;
}

.search-icon {
  @apply text-slate-500 flex border-none bg-background-light dark:bg-slate-800 items-center justify-center pl-4 rounded-l-lg border-r-0;
}

.search-input {
  @apply form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden rounded-lg text-slate-900 dark:text-white focus:outline-0 focus:ring-0 border-none bg-background-light dark:bg-slate-800 focus:border-none h-full placeholder:text-slate-500 dark:placeholder:text-slate-400 px-4 rounded-l-none border-l-0 pl-2 text-base font-normal leading-normal;
}

.header-actions {
  @apply flex flex-1 justify-end items-center gap-4;
}

.notification-btn {
  @apply flex max-w-[480px] cursor-pointer items-center justify-center overflow-hidden rounded-lg h-10 w-10 relative bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300;
}

.notification-dot {
  @apply absolute top-1.5 right-1.5 h-2.5 w-2.5 rounded-full bg-red-500 border-2 border-white dark:border-background-dark;
}

/* Page Header */
.page-title {
  @apply text-slate-900 dark:text-white text-3xl font-bold leading-tight tracking-tight;
}

.month-nav-btn {
  @apply flex-none w-9 h-9 flex items-center justify-center rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-300;
}

.month-label {
  @apply mx-2 text-slate-900 dark:text-white font-semibold text-lg text-center min-w-[11rem];
}

/* Calendar */
.calendar-wrapper {
  @apply bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-800 overflow-hidden;
}

.weekdays-header {
  @apply grid grid-cols-7 text-center text-sm font-semibold text-slate-600 dark:text-slate-400 border-b border-slate-200 dark:border-slate-800;
}

.weekday {
  @apply py-3;
}

.calendar-grid {
  @apply grid grid-cols-7 border-t border-slate-200 dark:border-slate-800;
}

.calendar-day {
  @apply h-28 p-2 border-b border-r border-slate-200 dark:border-slate-800 cursor-pointer transition-colors;
}

.calendar-day:not(.current-month) {
  @apply bg-slate-50 dark:bg-slate-900/50;
}

.calendar-day.current-month:hover {
  @apply bg-slate-50 dark:bg-slate-700/50;
}

.calendar-day.selected {
  @apply bg-primary/10 dark:bg-primary/20;
}

.day-number {
  @apply text-slate-900 dark:text-white font-medium;
}

.calendar-day:not(.current-month) .day-number {
  @apply text-slate-400 dark:text-slate-600;
}

.day-tasks {
  @apply mt-1 flex flex-col gap-0.5;
}

.task-high {
  @apply text-[10px] font-semibold p-[2px] rounded bg-red-100 text-red-600 dark:bg-red-900/30 dark:text-red-300 truncate;
}

.task-medium {
  @apply text-[10px] font-semibold p-[2px] rounded bg-amber-100 text-amber-600 dark:bg-amber-900/30 dark:text-amber-300 truncate;
}

.task-low {
  @apply text-[10px] font-semibold p-[2px] rounded bg-green-100 text-green-600 dark:bg-green-900/30 dark:text-green-300 truncate;
}

.more-tasks {
  @apply text-[10px] font-semibold p-[2px] rounded bg-slate-100 dark:bg-slate-700 text-slate-600 dark:text-slate-300;
}

/* Task Details */
.task-details {
  @apply bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 self-start;
}

.task-header {
  @apply flex justify-between items-start mb-2;
}

.task-title {
  @apply text-lg font-bold text-slate-900 dark:text-white;
}

.close-btn {
  @apply text-slate-400 hover:text-slate-600 dark:hover:text-slate-300 text-xl leading-none;
}

.task-date {
  @apply text-sm text-slate-500 dark:text-slate-400 mb-6;
}

.task-section {
  @apply mt-6 border-t border-slate-200 dark:border-slate-800 pt-6;
}

.section-title {
  @apply font-semibold text-slate-800 dark:text-slate-200 mb-2;
}

.task-description {
  @apply text-sm text-slate-600 dark:text-slate-400;
}

.task-info {
  @apply mt-6 border-t border-slate-200 dark:border-slate-800 pt-6 space-y-4;
}

.info-row {
  @apply flex items-center justify-between;
}

.info-label {
  @apply text-sm font-medium text-slate-600 dark:text-slate-400;
}

.info-value {
  @apply text-sm font-semibold text-slate-800 dark:text-slate-200;
}

.reward {
  @apply text-green-600 dark:text-green-500 bg-green-500/10 px-2 py-1 rounded-full;
}

.complexity-high {
  @apply text-sm font-semibold text-red-600;
}

.complexity-medium {
  @apply text-sm font-semibold text-amber-600;
}

.complexity-low {
  @apply text-sm font-semibold text-green-600;
}

.task-navigation {
  @apply mt-6 flex justify-between items-center;
}

.nav-btn {
  @apply px-3 py-1 bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 rounded hover:bg-slate-200 dark:hover:bg-slate-700 disabled:opacity-50 disabled:cursor-not-allowed;
}

.task-counter {
  @apply text-sm text-slate-500 dark:text-slate-400;
}

.accept-btn {
  @apply mt-8 w-full h-10 bg-primary text-white rounded-lg font-bold hover:bg-primary/90;
}

/* Empty State */
.empty-state {
  @apply bg-white dark:bg-slate-900 p-8 rounded-xl border border-slate-200 dark:border-slate-800 self-start text-center;
}

.empty-icon {
  @apply w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center mx-auto mb-4;
}

.empty-icon .material-symbols-outlined {
  @apply text-primary text-3xl;
}

.empty-title {
  @apply text-lg font-semibold text-slate-800 dark:text-white mb-2;
}

.empty-description {
  @apply text-sm text-slate-600 dark:text-slate-400;
}
</style>