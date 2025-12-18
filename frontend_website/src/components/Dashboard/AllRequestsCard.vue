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
            
            <router-link to="/requests" class="nav-item active">
              <span class="material-symbols-outlined">folder</span>
              <span>All Requests</span>
            </router-link>
            
            <router-link to="/cv-generation" class="nav-item">
              <span class="material-symbols-outlined">person</span>
              <span>CV</span>
            </router-link>
            
            <router-link to="/calendar" class="nav-item">
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
        <h1 class="page-title">All Requests</h1>
        <div class="header-actions">
          <button class="notification-btn">
            <span class="material-symbols-outlined">notifications</span>
            <div class="notification-dot"></div>
          </button>
        </div>
      </header>

      <!-- Content -->
      <div class="flex-1 p-10">
        <div class="flex flex-col gap-6">
          <!-- Search and Actions -->
          <div class="flex items-center justify-between gap-4">
            <!-- Search -->
            <div class="search-container">
              <span class="material-symbols-outlined search-icon">search</span>
              <input 
                v-model="searchQuery"
                @input="filterRequests"
                class="search-input"
                placeholder="Search by name or ID..."
              />
            </div>

            <!-- Filter, Sort, New Request -->
            <div class="flex items-center gap-2">
              <!-- Filter Dropdown -->
              <div class="relative">
                <button @click="toggleFilterMenu" class="filter-btn">
                  <span class="material-symbols-outlined">filter_list</span>
                  <span>Filter</span>
                </button>
                <div v-show="showFilterMenu" class="filter-menu">
                  <button @click="filterByStatus('')" class="filter-item">All</button>
                  <button @click="filterByStatus('approved')" class="filter-item">Approved</button>
                  <button @click="filterByStatus('pending')" class="filter-item">Pending</button>
                  <button @click="filterByStatus('rejected')" class="filter-item">Rejected</button>
                </div>
              </div>

              <!-- Sort Button -->
              <button @click="toggleSort" class="action-btn">
                <span class="material-symbols-outlined">swap_vert</span>
                <span>Sort</span>
              </button>

              <!-- New Request Button -->
              <router-link to="/new-request" class="new-request-btn">
                <span class="material-symbols-outlined">add</span>
                <span>New Request</span>
              </router-link>
            </div>
          </div>

          <!-- Requests Table -->
          <div class="w-full overflow-x-auto">
            <table class="requests-table">
              <thead>
                <tr>
                  <th class="table-header rounded-l-lg">Request ID</th>
                  <th class="table-header">Submitted By</th>
                  <th class="table-header">Request Type</th>
                  <th class="table-header">Date Submitted</th>
                  <th class="table-header">Status</th>
                  <th class="table-header rounded-r-lg">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="request in filteredRequests" :key="request.id" class="table-row">
                  <td class="table-cell font-medium">{{ request.id }}</td>
                  <td class="table-cell">
                    <div class="user-cell">
                      <div class="user-avatar" :style="{ backgroundImage: `url('${request.avatar}')` }"></div>
                      <span>{{ request.name }}</span>
                    </div>
                  </td>
                  <td class="table-cell">{{ request.type }}</td>
                  <td class="table-cell text-slate-600 dark:text-slate-400">{{ request.date }}</td>
                  <td class="table-cell">
                    <span :class="statusClass(request.status)">
                      {{ request.status }}
                    </span>
                  </td>
                  <td class="table-cell">
                    <button @click="viewDetails(request)" class="action-link">
                      View Details
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

// Состояния
const searchQuery = ref('')
const showFilterMenu = ref(false)
const sortAscending = ref(true)
const activeFilter = ref('')

// Данные запросов
const requests = ref([
  {
    id: '#REQ-001',
    name: 'Alex Johnson',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCWjviukgd6T1ZmYboweR2U4WJ4xrPZ7IlxrVvHv44uvu2KQNUbgZR78J2kmcLls5IgiQHA3hAKIjxzcTEvoNCCna8rw95LjPKOrK4i1Q4i3DwPL48IWzWZAgsnanpvCmjjJYGbLKzEKpC8Y-HIPGv3CpIvREIM3-MrZcqbGo6RYsyIXuKMtkHMj2kzV4waf9mVOny-tiW6OH2yu3il-sKZyonwt8KbwQr4c0K1K-PeoX64lBZpjPScwVyQdwcbP9qYpgU5aeb_jn68',
    type: 'Time Off',
    date: 'Oct 15, 2023',
    status: 'Approved'
  },
  {
    id: '#REQ-002',
    name: 'Maria Garcia',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_OFBWtxLb2srR792lnqTBbahsvpA8JrmHcI2CoeqemISdy6nDdOUw9m9T4oA7qQn-mX0aSmnGoneonPtPycmK96Cq1uYYtwW3Eb7Y05oV6igU1whZ7tNVX3iKkUyJCZcqQWwbu4WbsdZwFWXjik4bsRiL2TMhcN3sLglqc2N3OlaU8npXrr8bo8qTWgITQ4hndArikYZleNcH-enSgUFJLUkS_nX0uiHz2FSXsV2pFx8jSP2951LXK8JxTqgm2wwbta1rJMOykIFq',
    type: 'Expense Report',
    date: 'Oct 14, 2023',
    status: 'Pending'
  },
  {
    id: '#REQ-003',
    name: 'David Smith',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_OFBWtxLb2srR792lnqTBbahsvpA8JrmHcI2CoeqemISdy6nDdOUw9m9T4oA7qQn-mX0aSmnGoneonPtPycmK96Cq1uYYtwW3Eb7Y05oV6igU1whZ7tNVX3iKkUyJCZcqQWwbu4WbsdZwFWXjik4bsRiL2TMhcN3sLglqc2N3OlaU8npXrr8bo8qTWgITQ4hndArikYZleNcH-enSgUFJLUkS_nX0uiHz2FSXsV2pFx8jSP2951LXK8JxTqgm2wwbta1rJMOykIFq',
    type: 'IT Support',
    date: 'Oct 12, 2023',
    status: 'Rejected'
  },
  {
    id: '#REQ-004',
    name: 'Emily White',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_OFBWtxLb2srR792lnqTBbahsvpA8JrmHcI2CoeqemISdy6nDdOUw9m9T4oA7qQn-mX0aSmnGoneonPtPycmK96Cq1uYYtwW3Eb7Y05oV6igU1whZ7tNVX3iKkUyJCZcqQWwbu4WbsdZwFWXjik4bsRiL2TMhcN3sLglqc2N3OlaU8npXrr8bo8qTWgITQ4hndArikYZleNcH-enSgUFJLUkS_nX0uiHz2FSXsV2pFx8jSP2951LXK8JxTqgm2wwbta1rJMOykIFq',
    type: 'Equipment Purchase',
    date: 'Oct 11, 2023',
    status: 'Approved'
  },
  {
    id: '#REQ-005',
    name: 'Michael Brown',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_OFBWtxLb2srR792lnqTBbahsvpA8JrmHcI2CoeqemISdy6nDdOUw9m9T4oA7qQn-mX0aSmnGoneonPtPycmK96Cq1uYYtwW3Eb7Y05oV6igU1whZ7tNVX3iKkUyJCZcqQWwbu4WbsdZwFWXjik4bsRiL2TMhcN3sLglqc2N3OlaU8npXrr8bo8qTWgITQ4hndArikYZleNcH-enSgUFJLUkS_nX0uiHz2FSXsV2pFx8jSP2951LXK8JxTqgm2wwbta1rJMOykIFq',
    type: 'Time Off',
    date: 'Oct 10, 2023',
    status: 'Pending'
  },
  {
    id: '#REQ-006',
    name: 'Jessica Davis',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_OFBWtxLb2srR792lnqTBbahsvpA8JrmHcI2CoeqemISdy6nDdOUw9m9T4oA7qQn-mX0aSmnGoneonPtPycmK96Cq1uYYtwW3Eb7Y05oV6igU1whZ7tNVX3iKkUyJCZcqQWwbu4WbsdZwFWXjik4bsRiL2TMhcN3sLglqc2N3OlaU8npXrr8bo8qTWgITQ4hndArikYZleNcH-enSgUFJLUkS_nX0uiHz2FSXsV2pFx8jSP2951LXK8JxTqgm2wwbta1rJMOykIFq',
    type: 'Travel Authorization',
    date: 'Oct 09, 2023',
    status: 'Approved'
  }
])

// Вычисляемые свойства
const filteredRequests = computed(() => {
  let result = [...requests.value]

  // Поиск
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(request => 
      request.id.toLowerCase().includes(query) ||
      request.name.toLowerCase().includes(query) ||
      request.type.toLowerCase().includes(query)
    )
  }

  // Фильтрация по статусу
  if (activeFilter.value) {
    result = result.filter(request => 
      request.status.toLowerCase() === activeFilter.value
    )
  }

  // Сортировка по дате
  result.sort((a, b) => {
    const dateA = new Date(a.date)
    const dateB = new Date(b.date)
    return sortAscending.value ? dateB - dateA : dateA - dateB
  })

  return result
})

// Методы
const toggleFilterMenu = () => {
  showFilterMenu.value = !showFilterMenu.value
}

const filterByStatus = (status) => {
  activeFilter.value = status
  showFilterMenu.value = false
}

const toggleSort = () => {
  sortAscending.value = !sortAscending.value
}

const statusClass = (status) => {
  switch(status.toLowerCase()) {
    case 'approved':
      return 'status-badge status-approved'
    case 'pending':
      return 'status-badge status-pending'
    case 'rejected':
      return 'status-badge status-rejected'
    default:
      return 'status-badge'
  }
}

const viewDetails = (request) => {
  console.log('View details for:', request.id)
  // Здесь можно открыть модальное окно или перейти на страницу деталей
  alert(`Details for ${request.id}: ${request.type} - ${request.status}`)
}

// Закрытие меню фильтра при клике вне
const closeFilterMenu = (event) => {
  if (!event.target.closest('.relative')) {
    showFilterMenu.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', closeFilterMenu)
})

onUnmounted(() => {
  document.removeEventListener('click', closeFilterMenu)
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

.page-title {
  @apply text-slate-900 dark:text-white text-2xl font-bold leading-tight tracking-tight;
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

/* Search */
.search-container {
  @apply flex flex-col min-w-40 !h-10 max-w-sm flex-1;
}

.search-icon {
  @apply text-slate-500 flex border-none bg-white dark:bg-slate-800 items-center justify-center pl-4 rounded-l-lg border-r-0;
}

.search-input {
  @apply form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden rounded-lg text-slate-900 dark:text-white focus:outline-0 focus:ring-0 border-none bg-white dark:bg-slate-800 focus:border-none h-full placeholder:text-slate-500 dark:placeholder:text-slate-400 px-4 rounded-l-none border-l-0 pl-2 text-base font-normal leading-normal;
}

/* Buttons */
.filter-btn, .action-btn {
  @apply flex items-center gap-2 h-10 px-4 rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-300 text-sm font-medium hover:bg-slate-50 dark:hover:bg-slate-700;
}

.new-request-btn {
  @apply flex items-center gap-2 h-10 px-4 rounded-lg bg-primary text-white text-sm font-medium hover:bg-primary/90;
}

.filter-menu {
  @apply absolute right-0 mt-2 w-40 rounded-lg bg-white dark:bg-slate-800 shadow-lg border border-slate-200 dark:border-slate-700 z-20;
}

.filter-item {
  @apply w-full text-left px-4 py-2 text-sm hover:bg-slate-100 dark:hover:bg-slate-700;
}

/* Table */
.requests-table {
  @apply w-full text-left;
}

.table-header {
  @apply px-6 py-3 text-xs text-slate-500 dark:text-slate-400 uppercase bg-slate-50 dark:bg-slate-800 font-semibold;
}

.table-row {
  @apply bg-white dark:bg-background-dark border-b dark:border-slate-800;
}

.table-cell {
  @apply px-6 py-4;
}

.user-cell {
  @apply flex items-center gap-3;
}

.user-avatar {
  @apply bg-center bg-no-repeat aspect-square bg-cover rounded-full size-8;
}

/* Status Badges */
.status-badge {
  @apply inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium;
}

.status-approved {
  @apply bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300;
}

.status-pending {
  @apply bg-amber-100 text-amber-800 dark:bg-amber-900 dark:text-amber-300;
}

.status-rejected {
  @apply bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300;
}

/* Action Link */
.action-link {
  @apply text-primary hover:underline;
}
</style>