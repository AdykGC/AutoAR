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
            
            <router-link to="/cv-generation" class="nav-item active">
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
        <h1 class="page-title">CV Generation</h1>
        <div class="header-actions">
          <button class="notification-btn">
            <span class="material-symbols-outlined">notifications</span>
            <div class="notification-dot"></div>
          </button>
        </div>
      </header>

      <!-- Content -->
      <div class="flex-1 p-10">
        <div class="max-w-4xl mx-auto">
          <!-- CV Generator Card -->
          <div class="bg-white dark:bg-background-dark rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 p-8">
            <div class="text-center mb-8">
              <div class="w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center mx-auto mb-4">
                <span class="material-symbols-outlined text-primary text-4xl">description</span>
              </div>
              <h2 class="text-2xl font-bold text-slate-900 dark:text-white mb-2">Professional CV Generator</h2>
              <p class="text-slate-600 dark:text-slate-400">
                Generate a professional CV based on your profile data
              </p>
            </div>

            <!-- CV Preview -->
            <div class="mb-8 p-6 border border-slate-200 dark:border-slate-700 rounded-lg bg-slate-50 dark:bg-slate-800/50">
              <h3 class="text-lg font-semibold text-slate-900 dark:text-white mb-4">CV Preview</h3>
              <div class="space-y-4">
                <div class="flex items-start space-x-3">
                  <span class="material-symbols-outlined text-slate-400">person</span>
                  <div>
                    <p class="font-medium text-slate-900 dark:text-white">{{ user.name }}</p>
                    <p class="text-sm text-slate-600 dark:text-slate-400">{{ user.position }}</p>
                  </div>
                </div>
                <div class="flex items-start space-x-3">
                  <span class="material-symbols-outlined text-slate-400">mail</span>
                  <div>
                    <p class="text-sm text-slate-900 dark:text-white">{{ user.email }}</p>
                    <p class="text-sm text-slate-600 dark:text-slate-400">{{ user.phone }}</p>
                  </div>
                </div>
                <div class="flex items-start space-x-3">
                  <span class="material-symbols-outlined text-slate-400">work</span>
                  <div>
                    <p class="text-sm text-slate-900 dark:text-white">{{ user.department }}</p>
                    <p class="text-sm text-slate-600 dark:text-slate-400">Employee ID: {{ user.employeeId }}</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- CV Options -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
              <div>
                <label class="form-label">CV Template</label>
                <select v-model="cvTemplate" class="form-select">
                  <option value="modern">Modern</option>
                  <option value="professional">Professional</option>
                  <option value="creative">Creative</option>
                  <option value="minimal">Minimal</option>
                </select>
              </div>
              <div>
                <label class="form-label">Color Scheme</label>
                <select v-model="colorScheme" class="form-select">
                  <option value="blue">Blue</option>
                  <option value="green">Green</option>
                  <option value="purple">Purple</option>
                  <option value="gray">Gray</option>
                </select>
              </div>
              <div>
                <label class="form-label">Language</label>
                <select v-model="language" class="form-select">
                  <option value="en">English</option>
                  <option value="kz">Kazakh</option>
                  <option value="ru">Russian</option>
                </select>
              </div>
              <div>
                <label class="form-label">Format</label>
                <select v-model="format" class="form-select">
                  <option value="pdf">PDF</option>
                  <option value="docx">Word (.docx)</option>
                  <option value="txt">Text (.txt)</option>
                </select>
              </div>
            </div>

            <!-- Include Sections -->
            <div class="mb-8">
              <label class="form-label mb-3">Include Sections</label>
              <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
                <label v-for="section in sections" :key="section.id" class="flex items-center space-x-2">
                  <input type="checkbox" v-model="section.checked" class="rounded">
                  <span class="text-sm text-slate-700 dark:text-slate-300">{{ section.label }}</span>
                </label>
              </div>
            </div>

            <!-- Action Buttons -->
            <div class="flex justify-center space-x-4">
              <button 
                @click="generateCV" 
                :disabled="generating"
                class="px-6 py-3 bg-primary text-white rounded-lg font-medium hover:bg-primary/90 flex items-center space-x-2 disabled:opacity-50"
              >
                <span v-if="generating" class="spinner"></span>
                <span class="material-symbols-outlined">download</span>
                <span>{{ generating ? 'Generating...' : 'Generate CV' }}</span>
              </button>
              <button 
                @click="previewCV"
                class="px-6 py-3 border border-slate-300 dark:border-slate-700 text-slate-700 dark:text-slate-300 rounded-lg font-medium hover:bg-slate-50 dark:hover:bg-slate-800 flex items-center space-x-2"
              >
                <span class="material-symbols-outlined">visibility</span>
                <span>Preview</span>
              </button>
            </div>

            <!-- Generation Status -->
            <div v-if="generationMessage" 
              :class="`mt-6 p-4 rounded-lg ${generationMessage.type === 'success' ? 'bg-green-50 dark:bg-green-900/30 text-green-700 dark:text-green-300' : 'bg-red-50 dark:bg-red-900/30 text-red-700 dark:text-red-300'}`"
            >
              {{ generationMessage.text }}
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import authService from '../../services/auth.service.js'

// User data
const user = reactive({
  name: 'Alex Johnson',
  position: 'Senior Developer',
  email: 'alex.johnson@company.com',
  phone: '+7 701 123 4567',
  department: 'IT Department',
  employeeId: 'EMP-2023-001'
})

// CV options
const cvTemplate = ref('modern')
const colorScheme = ref('blue')
const language = ref('en')
const format = ref('pdf')
const generating = ref(false)
const generationMessage = ref(null)

// CV sections
const sections = ref([
  { id: 'personal', label: 'Personal Info', checked: true },
  { id: 'experience', label: 'Work Experience', checked: true },
  { id: 'education', label: 'Education', checked: true },
  { id: 'skills', label: 'Skills', checked: true },
  { id: 'projects', label: 'Projects', checked: true },
  { id: 'languages', label: 'Languages', checked: true },
  { id: 'certificates', label: 'Certificates', checked: false },
  { id: 'references', label: 'References', checked: false }
])

// Load user data
onMounted(() => {
  const userData = authService.getUserData()
  if (userData) {
    user.name = `${userData.name || ''} ${userData.surname || ''}`.trim() || 'Alex Johnson'
    user.email = userData.email || 'alex.johnson@company.com'
    user.position = userData.position || 'Senior Developer'
  }
})

// Methods
const generateCV = async () => {
  generating.value = true
  generationMessage.value = null

  try {
    // Имитация генерации CV
    await new Promise(resolve => setTimeout(resolve, 2000))

    generationMessage.value = {
      type: 'success',
      text: `CV generated successfully! Download will start automatically.`
    }

    // Имитация скачивания файла
    setTimeout(() => {
      const link = document.createElement('a')
      link.href = '#' // В реальном приложении здесь будет ссылка на файл
      link.download = `CV_${user.name.replace(/\s+/g, '_')}.${format.value}`
      link.click()
    }, 1000)

  } catch (error) {
    generationMessage.value = {
      type: 'error',
      text: 'Failed to generate CV. Please try again.'
    }
  } finally {
    generating.value = false
  }
}

const previewCV = () => {
  alert('CV preview feature coming soon!')
}
</script>

<style scoped>
/* Используем те же стили, что и в других компонентах */
.spinner {
  @apply animate-spin rounded-full h-4 w-4 border-b-2 border-white;
}

.form-label {
  @apply text-sm font-medium text-slate-700 dark:text-slate-300 mb-2 block;
}

.form-select {
  @apply w-full h-12 px-4 text-sm rounded-lg bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:ring-primary focus:border-primary text-slate-900 dark:text-white;
}
</style>