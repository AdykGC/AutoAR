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
        <h1 class="page-title">New Request Submission</h1>
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
          <!-- Form Card -->
          <div class="bg-white dark:bg-background-dark rounded-xl shadow-sm border border-slate-200 dark:border-slate-800">
            <div class="p-8">
              <!-- Success/Error Message -->
              <div v-if="message" :class="`mb-6 p-4 rounded-lg ${message.type === 'success' ? 'bg-green-50 dark:bg-green-900/30 text-green-700 dark:text-green-300' : 'bg-red-50 dark:bg-red-900/30 text-red-700 dark:text-red-300'}`">
                {{ message.text }}
              </div>

              <form @submit.prevent="submitRequest" class="flex flex-col gap-6">
                <!-- Row 1: Request Type & Submitted By -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <!-- Request Type -->
                  <div>
                    <label class="form-label">
                      Request Type <span class="required">*</span>
                    </label>
                    <div class="relative">
                      <select 
                        v-model="form.requestType"
                        class="form-select"
                        required
                      >
                        <option value="" disabled>Select request type</option>
                        <option value="job">Job Request</option>
                        <option value="timeoff">Time-Off Request</option>
                        <option value="report">Report Request</option>
                        <option value="equipment">Equipment Purchase</option>
                        <option value="travel">Travel Authorization</option>
                        <option value="it">IT Support</option>
                        <option value="expense">Expense Report</option>
                      </select>
                      <span class="select-icon material-symbols-outlined">arrow_drop_down</span>
                    </div>
                  </div>

                  <!-- Submitted By -->
                  <div>
                    <label class="form-label">
                      Submitted By <span class="required">*</span>
                    </label>
                    <div class="submitted-by">
                      <div class="user-avatar" :style="{ backgroundImage: `url('${user.avatar}')` }"></div>
                      <span class="user-name">{{ user.name }}</span>
                    </div>
                  </div>
                </div>

                <!-- Row 2: Dates -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <!-- Start Date -->
                  <div>
                    <label class="form-label">
                      Start Date <span class="required">*</span>
                    </label>
                    <input 
                      v-model="form.startDate"
                      type="date" 
                      class="form-input"
                      required
                    />
                  </div>

                  <!-- End Date -->
                  <div>
                    <label class="form-label">
                      End Date <span class="required">*</span>
                    </label>
                    <input 
                      v-model="form.endDate"
                      type="date" 
                      class="form-input"
                      required
                    />
                  </div>
                </div>

                <!-- Row 3: Reason -->
                <div>
                  <label class="form-label">
                    Reason for Request <span class="required">*</span>
                  </label>
                  <textarea 
                    v-model="form.reason"
                    class="form-textarea"
                    placeholder="Please provide a brief reason for your request..."
                    rows="4"
                    required
                  ></textarea>
                  <div class="text-xs text-slate-500 dark:text-slate-400 mt-1">
                    Minimum 20 characters
                  </div>
                </div>

                <!-- Row 4: Priority & Category -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <!-- Priority -->
                  <div>
                    <label class="form-label">
                      Priority <span class="required">*</span>
                    </label>
                    <div class="grid grid-cols-3 gap-2">
                      <label 
                        v-for="priority in priorities" 
                        :key="priority.value"
                        :class="['priority-option', { 'selected': form.priority === priority.value }]"
                        @click="form.priority = priority.value"
                      >
                        <span class="priority-dot" :style="{ backgroundColor: priority.color }"></span>
                        <span>{{ priority.label }}</span>
                      </label>
                    </div>
                  </div>

                  <!-- Category -->
                  <div>
                    <label class="form-label">
                      Category
                    </label>
                    <select 
                      v-model="form.category"
                      class="form-select"
                    >
                      <option value="">Select category</option>
                      <option value="hr">Human Resources</option>
                      <option value="finance">Finance</option>
                      <option value="it">IT Department</option>
                      <option value="operations">Operations</option>
                      <option value="management">Management</option>
                    </select>
                  </div>
                </div>

                <!-- Row 5: Attachment -->
                <div>
                  <label class="form-label">
                    Attach File <span class="required">*</span>
                  </label>
                  <div 
                    @dragover.prevent="dragOver = true"
                    @dragleave="dragOver = false"
                    @drop.prevent="handleFileDrop"
                    @click="triggerFileInput"
                    :class="['file-upload-area', { 'drag-over': dragOver, 'has-file': form.attachment }]"
                  >
                    <input 
                      ref="fileInput"
                      type="file"
                      @change="handleFileSelect"
                      class="hidden"
                      accept=".pdf,.png,.jpg,.jpeg,.doc,.docx"
                    />
                    <div class="upload-content">
                      <span class="material-symbols-outlined upload-icon">cloud_upload</span>
                      <div v-if="!form.attachment">
                        <p class="upload-text">
                          <span class="font-semibold">Click to upload</span> or drag and drop
                        </p>
                        <p class="upload-subtext">
                          PDF, PNG, JPG or DOCX (MAX. 10MB)
                        </p>
                      </div>
                      <div v-else class="file-info">
                        <span class="material-symbols-outlined text-green-500">check_circle</span>
                        <div class="file-details">
                          <p class="file-name">{{ form.attachment.name }}</p>
                          <p class="file-size">{{ formatFileSize(form.attachment.size) }}</p>
                        </div>
                        <button 
                          type="button"
                          @click.stop="removeFile"
                          class="remove-file-btn"
                        >
                          <span class="material-symbols-outlined">close</span>
                        </button>
                      </div>
                    </div>
                  </div>
                  <div v-if="form.attachmentError" class="text-red-500 text-sm mt-2">
                    {{ form.attachmentError }}
                  </div>
                </div>

                <!-- Row 6: Additional Notes -->
                <div>
                  <label class="form-label">
                    Additional Notes
                  </label>
                  <textarea 
                    v-model="form.notes"
                    class="form-textarea"
                    placeholder="Any additional information or special requirements..."
                    rows="3"
                  ></textarea>
                </div>

                <!-- Form Actions -->
                <div class="flex justify-end gap-4 pt-4">
                  <!-- Cancel Button -->
                  <router-link 
                    to="/requests" 
                    class="cancel-btn"
                  >
                    <span>Cancel</span>
                  </router-link>

                  <!-- Submit Button -->
                  <button 
                    type="submit" 
                    :disabled="submitting"
                    class="submit-btn"
                  >
                    <span v-if="submitting" class="flex items-center gap-2">
                      <span class="spinner"></span>
                      Submitting...
                    </span>
                    <span v-else class="flex items-center gap-2">
                      <span class="material-symbols-outlined">send</span>
                      Submit Request
                    </span>
                  </button>
                </div>
              </form>
            </div>
          </div>

          <!-- Request Preview (Optional) -->
          <div v-if="showPreview" class="mt-6 bg-white dark:bg-background-dark rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 p-6">
            <h3 class="text-lg font-semibold text-slate-900 dark:text-white mb-4">Request Preview</h3>
            <div class="grid grid-cols-2 gap-4 text-sm">
              <div>
                <p class="text-slate-500 dark:text-slate-400">Request Type:</p>
                <p class="font-medium">{{ getRequestTypeLabel(form.requestType) }}</p>
              </div>
              <div>
                <p class="text-slate-500 dark:text-slate-400">Priority:</p>
                <p class="font-medium">
                  <span class="priority-badge" :style="{ backgroundColor: getPriorityColor(form.priority) }">
                    {{ getPriorityLabel(form.priority) }}
                  </span>
                </p>
              </div>
              <div>
                <p class="text-slate-500 dark:text-slate-400">Dates:</p>
                <p class="font-medium">{{ formatDate(form.startDate) }} - {{ formatDate(form.endDate) }}</p>
              </div>
              <div>
                <p class="text-slate-500 dark:text-slate-400">Category:</p>
                <p class="font-medium">{{ form.category || 'Not specified' }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import authService from '../../services/auth.service.js'

const router = useRouter()
const fileInput = ref(null)
const dragOver = ref(false)
const submitting = ref(false)
const message = ref(null)
const showPreview = ref(false)

// User data
const user = reactive({
  name: 'Alex Johnson',
  avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCWjviukgd6T1ZmYboweR2U4WJ4xrPZ7IlxrVvHv44uvu2KQNUbgZR78J2kmcLls5IgiQHA3hAKIjxzcTEvoNCCna8rw95LjPKOrK4i1Q4i3DwPL48IWzWZAgsnanpvCmjjJYGbLKzEKpC8Y-HIPGv3CpIvREIM3-MrZcqbGo6RYsyIXuKMtkHMj2kzV4waf9mVOny-tiW6OH2yu3il-sKZyonwt8KbwQr4c0K1K-PeoX64lBZpjPScwVyQdwcbP9qYpgU5aeb_jn68'
})

// Priority options
const priorities = [
  { value: 'low', label: 'Low', color: '#10b981' },
  { value: 'medium', label: 'Medium', color: '#f59e0b' },
  { value: 'high', label: 'High', color: '#ef4444' }
]

// Form data
const form = reactive({
  requestType: '',
  startDate: '',
  endDate: '',
  reason: '',
  priority: 'medium',
  category: '',
  attachment: null,
  attachmentError: '',
  notes: ''
})

// Initialize dates
onMounted(() => {
  const today = new Date()
  const nextWeek = new Date(today)
  nextWeek.setDate(today.getDate() + 7)
  
  form.startDate = formatDateForInput(today)
  form.endDate = formatDateForInput(nextWeek)
  
  // Load user data from auth service
  const userData = authService.getUserData()
  if (userData) {
    user.name = `${userData.name || ''} ${userData.surname || ''}`.trim() || 'Alex Johnson'
    user.avatar = userData.avatar || user.avatar
  }
})

// Helper methods
const formatDateForInput = (date) => {
  const d = new Date(date)
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    month: 'short', 
    day: 'numeric',
    year: 'numeric'
  })
}

const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

const getRequestTypeLabel = (value) => {
  const types = {
    'job': 'Job Request',
    'timeoff': 'Time-Off Request',
    'report': 'Report Request',
    'equipment': 'Equipment Purchase',
    'travel': 'Travel Authorization',
    'it': 'IT Support',
    'expense': 'Expense Report'
  }
  return types[value] || value
}

const getPriorityLabel = (value) => {
  const priority = priorities.find(p => p.value === value)
  return priority ? priority.label : 'Medium'
}

const getPriorityColor = (value) => {
  const priority = priorities.find(p => p.value === value)
  return priority ? priority.color : '#f59e0b'
}

// File handling
const triggerFileInput = () => {
  fileInput.value.click()
}

const handleFileSelect = (event) => {
  const file = event.target.files[0]
  if (file) {
    validateAndSetFile(file)
  }
}

const handleFileDrop = (event) => {
  dragOver.value = false
  const file = event.dataTransfer.files[0]
  if (file) {
    validateAndSetFile(file)
  }
}

const validateAndSetFile = (file) => {
  // Check file size (10MB limit)
  const maxSize = 10 * 1024 * 1024 // 10MB in bytes
  if (file.size > maxSize) {
    form.attachmentError = 'File size exceeds 10MB limit'
    return
  }

  // Check file type
  const allowedTypes = [
    'application/pdf',
    'image/png',
    'image/jpeg',
    'image/jpg',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]
  
  if (!allowedTypes.includes(file.type)) {
    form.attachmentError = 'File type not allowed. Please upload PDF, PNG, JPG, or DOCX files.'
    return
  }

  form.attachment = file
  form.attachmentError = ''
}

const removeFile = () => {
  form.attachment = null
  form.attachmentError = ''
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

// Form validation
const validateForm = () => {
  const errors = []

  if (!form.requestType) {
    errors.push('Request type is required')
  }

  if (!form.startDate) {
    errors.push('Start date is required')
  }

  if (!form.endDate) {
    errors.push('End date is required')
  }

  if (form.startDate && form.endDate) {
    const start = new Date(form.startDate)
    const end = new Date(form.endDate)
    if (end < start) {
      errors.push('End date cannot be before start date')
    }
  }

  if (!form.reason || form.reason.length < 20) {
    errors.push('Reason must be at least 20 characters')
  }

  if (!form.attachment) {
    errors.push('File attachment is required')
  }

  return errors
}

// Form submission
const submitRequest = async () => {
  // Validate form
  const errors = validateForm()
  if (errors.length > 0) {
    message.value = {
      type: 'error',
      text: errors[0]
    }
    return
  }

  submitting.value = true
  message.value = null

  try {
    // Prepare form data
    const formData = new FormData()
    formData.append('request_type', form.requestType)
    formData.append('start_date', form.startDate)
    formData.append('end_date', form.endDate)
    formData.append('reason', form.reason)
    formData.append('priority', form.priority)
    formData.append('category', form.category)
    formData.append('notes', form.notes)
    
    if (form.attachment) {
      formData.append('attachment', form.attachment)
    }

    // In реальном приложении здесь будет вызов API
    // const response = await api.post('/requests', formData, {
    //   headers: {
    //     'Content-Type': 'multipart/form-data'
    //   }
    // })

    // Имитация задержки API
    await new Promise(resolve => setTimeout(resolve, 2000))

    // Success message
    message.value = {
      type: 'success',
      text: 'Request submitted successfully! Redirecting to requests page...'
    }

    // Reset form
    Object.assign(form, {
      requestType: '',
      startDate: formatDateForInput(new Date()),
      endDate: formatDateForInput(new Date(new Date().getTime() + 7 * 24 * 60 * 60 * 1000)),
      reason: '',
      priority: 'medium',
      category: '',
      attachment: null,
      attachmentError: '',
      notes: ''
    })

    // Remove file input value
    if (fileInput.value) {
      fileInput.value.value = ''
    }

    // Redirect after delay
    setTimeout(() => {
      router.push('/requests')
    }, 3000)

  } catch (error) {
    console.error('Request submission error:', error)
    message.value = {
      type: 'error',
      text: error.response?.data?.message || 'Failed to submit request. Please try again.'
    }
  } finally {
    submitting.value = false
  }
}

// Computed properties
const formIsValid = computed(() => {
  return form.requestType && 
         form.startDate && 
         form.endDate && 
         form.reason && 
         form.reason.length >= 20 && 
         form.attachment
})

const requestSummary = computed(() => {
  return {
    type: getRequestTypeLabel(form.requestType),
    dates: `${formatDate(form.startDate)} - ${formatDate(form.endDate)}`,
    priority: getPriorityLabel(form.priority),
    category: form.category || 'Not specified'
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

/* Form Styles */
.form-label {
  @apply text-sm font-medium text-slate-700 dark:text-slate-300 mb-2 block;
}

.required {
  @apply text-red-500;
}

.form-select, .form-input, .form-textarea {
  @apply w-full h-12 px-4 text-sm rounded-lg bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:ring-primary focus:border-primary text-slate-900 dark:text-white transition-colors;
}

.form-textarea {
  @apply h-auto py-3;
}

.form-select {
  @apply appearance-none pr-10;
}

.select-icon {
  @apply absolute right-3 top-1/2 transform -translate-y-1/2 text-slate-400 pointer-events-none;
}

.submitted-by {
  @apply flex items-center gap-3 h-12 px-4 rounded-lg bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700;
}

.user-avatar {
  @apply bg-center bg-no-repeat aspect-square bg-cover rounded-full size-8;
}

.user-name {
  @apply text-sm text-slate-900 dark:text-white;
}

.priority-option {
  @apply flex items-center gap-2 p-3 rounded-lg border border-slate-200 dark:border-slate-700 cursor-pointer transition-colors hover:bg-slate-50 dark:hover:bg-slate-800;
}

.priority-option.selected {
  @apply border-primary bg-primary/5;
}

.priority-dot {
  @apply w-3 h-3 rounded-full;
}

.priority-badge {
  @apply inline-block px-2 py-1 rounded-full text-xs font-medium text-white;
}

/* File Upload */
.file-upload-area {
  @apply flex items-center justify-center w-full h-32 border-2 border-dashed rounded-lg cursor-pointer transition-colors;
  border-color: #cbd5e1;
}

.file-upload-area.drag-over {
  @apply border-primary bg-primary/5;
}

.file-upload-area.has-file {
  @apply border-green-200 dark:border-green-800 bg-green-50 dark:bg-green-900/20;
}

.upload-content {
  @apply flex flex-col items-center justify-center;
}

.upload-icon {
  @apply text-slate-500 dark:text-slate-400 text-3xl mb-2;
}

.upload-text {
  @apply mb-2 text-sm text-slate-500 dark:text-slate-400;
}

.upload-subtext {
  @apply text-xs text-slate-500 dark:text-slate-400;
}

.file-info {
  @apply flex items-center gap-3;
}

.file-details {
  @apply flex flex-col;
}

.file-name {
  @apply text-sm font-medium text-slate-900 dark:text-white;
}

.file-size {
  @apply text-xs text-slate-500 dark:text-slate-400;
}

.remove-file-btn {
  @apply text-slate-400 hover:text-slate-600 dark:hover:text-slate-300;
}

/* Buttons */
.cancel-btn {
  @apply flex items-center gap-2 h-11 px-6 rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-300 text-sm font-medium hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors;
}

.submit-btn {
  @apply flex items-center gap-2 h-11 px-6 rounded-lg bg-primary text-white text-sm font-medium hover:bg-primary/90 transition-colors disabled:opacity-50 disabled:cursor-not-allowed;
}

.submit-btn:disabled {
  @apply opacity-50 cursor-not-allowed;
}

/* Spinner */
.spinner {
  @apply animate-spin rounded-full h-4 w-4 border-b-2 border-white;
}

/* Preview */
.preview-item {
  @apply border-b border-slate-200 dark:border-slate-800 py-2;
}

.preview-label {
  @apply text-sm font-medium text-slate-600 dark:text-slate-400;
}

.preview-value {
  @apply text-sm text-slate-900 dark:text-white;
}
</style>