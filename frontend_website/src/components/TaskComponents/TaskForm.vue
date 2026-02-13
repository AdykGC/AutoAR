<template>
  <div class="task-form-container">
    <div class="form-header">
      <h1>➕ Создать новую задачу</h1>
      <p class="form-subtitle">Заполните форму ниже, чтобы отправить задачу на выполнение</p>
    </div>

    <form @submit.prevent="submitForm" class="task-form" ref="formElement">
      <!-- Основная информация -->
      <div class="form-section">
        <h2>📝 Основная информация</h2>
        
        <!-- Название задачи -->
        <div class="form-group" :class="{ 'has-error': errors.title }">
          <label for="title" class="form-label">
            Название задачи *
            <span class="label-hint">Краткое и понятное название</span>
          </label>
          <input
            type="text"
            id="title"
            v-model="formData.title"
            class="form-input"
            placeholder="Например: Разработка лендинга"
            :class="{ 'error': errors.title }"
            @input="clearError('title')"
          />
          <div v-if="errors.title" class="error-message">
            {{ errors.title }}
          </div>
        </div>

        <!-- Описание задачи -->
        <div class="form-group" :class="{ 'has-error': errors.description }">
          <label for="description" class="form-label">
            Подробное описание *
            <span class="label-hint">Опишите задачу максимально подробно</span>
          </label>
          <textarea
            id="description"
            v-model="formData.description"
            class="form-textarea"
            rows="6"
            placeholder="Опишите, что нужно сделать, какие требования, ожидаемый результат..."
            :class="{ 'error': errors.description }"
            @input="clearError('description')"
          ></textarea>
          <div class="textarea-info">
            <span class="char-count">{{ formData.description.length }}/5000</span>
            <span v-if="formData.description.length < 10" class="char-warning">
              ⚠️ Минимум 10 символов
            </span>
          </div>
          <div v-if="errors.description" class="error-message">
            {{ errors.description }}
          </div>
        </div>
      </div>

      <!-- Детали задачи -->
      <div class="form-section">
        <h2>⚙️ Детали задачи</h2>
        
        <div class="form-row">
          <!-- Бюджет -->
          <div class="form-group" :class="{ 'has-error': errors.budget }">
            <label for="budget" class="form-label">
              Бюджет (₸)
              <span class="label-hint">Примерная стоимость выполнения</span>
            </label>
            <div class="input-with-icon">
              <span class="input-icon">₸</span>
              <input
                type="number"
                id="budget"
                v-model.number="formData.budget"
                class="form-input"
                placeholder="0"
                min="0"
                step="1000"
                :class="{ 'error': errors.budget }"
                @input="clearError('budget')"
              />
            </div>
            <div v-if="errors.budget" class="error-message">
              {{ errors.budget }}
            </div>
          </div>

          <!-- Дедлайн -->
          <div class="form-group" :class="{ 'has-error': errors.deadline }">
            <label for="deadline" class="form-label">
              Желаемый дедлайн
              <span class="label-hint">Когда задача должна быть выполнена</span>
            </label>
            <input
              type="date"
              id="deadline"
              v-model="formData.deadline"
              class="form-input"
              :min="today"
              :class="{ 'error': errors.deadline }"
              @input="clearError('deadline')"
            />
            <div class="date-hint" v-if="formData.deadline">
              📅 {{ formatDate(formData.deadline) }}
            </div>
            <div v-if="errors.deadline" class="error-message">
              {{ errors.deadline }}
            </div>
          </div>
        </div>

        <!-- Приоритет (только для VIP клиентов) -->
        <div class="form-group" v-if="isVipClient">
          <label class="form-label">
            Приоритет задачи
            <span class="label-hint">Определяет скорость обработки</span>
          </label>
          <div class="priority-selector">
            <label 
              v-for="priority in priorityOptions" 
              :key="priority.value"
              class="priority-option"
              :class="{ 
                'selected': formData.priority === priority.value,
                [priority.value]: true
              }"
            >
              <input
                type="radio"
                v-model="formData.priority"
                :value="priority.value"
                class="priority-input"
              />
              <div class="priority-content">
                <div class="priority-icon">{{ priority.icon }}</div>
                <div class="priority-text">
                  <div class="priority-name">{{ priority.name }}</div>
                  <div class="priority-desc">{{ priority.description }}</div>
                </div>
              </div>
            </label>
          </div>
        </div>

        <!-- Категория -->
        <div class="form-group">
          <label for="category" class="form-label">
            Категория задачи
            <span class="label-hint">Выберите наиболее подходящую категорию</span>
          </label>
          <select
            id="category"
            v-model="formData.category"
            class="form-select"
          >
            <option value="">Выберите категорию</option>
            <option 
              v-for="category in categoryOptions" 
              :key="category.value"
              :value="category.value"
            >
              {{ category.label }}
            </option>
          </select>
        </div>
      </div>

      <!-- Вложения -->
      <div class="form-section">
        <h2>📎 Вложения</h2>
        
        <div class="form-group">
          <label class="form-label">
            Файлы
            <span class="label-hint">Загрузите документы, изображения или другие файлы (макс. 10MB)</span>
          </label>
          
          <!-- Область для перетаскивания файлов -->
          <div 
            class="file-dropzone"
            :class="{ 
              'dragover': isDragging,
              'has-files': formData.attachments.length > 0
            }"
            @dragover.prevent="handleDragOver"
            @dragleave.prevent="handleDragLeave"
            @drop.prevent="handleDrop"
            @click="triggerFileInput"
          >
            <div class="dropzone-content" v-if="formData.attachments.length === 0">
              <div class="dropzone-icon">📎</div>
              <div class="dropzone-text">
                <p>Перетащите файлы сюда или <span class="click-here">нажмите для выбора</span></p>
                <p class="dropzone-hint">Поддерживаемые форматы: PDF, JPG, PNG, DOC, XLS</p>
              </div>
            </div>
            
            <div class="files-list" v-else>
              <div class="files-header">
                <span>Загружено файлов: {{ formData.attachments.length }}</span>
                <button type="button" @click.stop="clearFiles" class="clear-files-btn">
                  Очистить все
                </button>
              </div>
              <div class="file-items">
                <div 
                  v-for="(file, index) in formData.attachments" 
                  :key="index"
                  class="file-item"
                >
                  <div class="file-info">
                    <div class="file-icon">{{ getFileIcon(file.type) }}</div>
                    <div class="file-details">
                      <div class="file-name">{{ file.name }}</div>
                      <div class="file-size">{{ formatFileSize(file.size) }}</div>
                    </div>
                  </div>
                  <button 
                    type="button" 
                    @click.stop="removeFile(index)"
                    class="remove-file-btn"
                  >
                    ✕
                  </button>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Скрытый input для файлов -->
          <input
            type="file"
            ref="fileInput"
            multiple
            @change="handleFileSelect"
            class="file-input-hidden"
            accept=".pdf,.jpg,.jpeg,.png,.doc,.docx,.xls,.xlsx"
          />
          
          <div class="upload-hint">
            Максимальный размер файла: 10MB. Можно загрузить до 5 файлов.
          </div>
        </div>
      </div>

      <!-- Дополнительные настройки -->
      <div class="form-section" v-if="showAdvancedOptions">
        <h2>⚡ Дополнительные настройки</h2>
        
        <!-- Уведомления -->
        <div class="form-group">
          <label class="form-label">
            Уведомления
          </label>
          <div class="checkbox-group">
            <label class="checkbox-label">
              <input
                type="checkbox"
                v-model="formData.notifications.email"
                class="checkbox-input"
              />
              <span class="checkbox-custom"></span>
              <span class="checkbox-text">Уведомлять по email</span>
            </label>
            <label class="checkbox-label">
              <input
                type="checkbox"
                v-model="formData.notifications.sms"
                class="checkbox-input"
              />
              <span class="checkbox-custom"></span>
              <span class="checkbox-text">Уведомлять по SMS</span>
            </label>
          </div>
        </div>

        <!-- Конфиденциальность -->
        <div class="form-group">
          <label class="form-label">
            Конфиденциальность
          </label>
          <div class="checkbox-label">
            <input
              type="checkbox"
              v-model="formData.is_private"
              class="checkbox-input"
            />
            <span class="checkbox-custom"></span>
            <span class="checkbox-text">
              Сделать задачу приватной (только для менеджера)
            </span>
          </div>
        </div>
      </div>

      <!-- Кнопки формы -->
      <div class="form-actions">
        <button
          type="button"
          @click="toggleAdvancedOptions"
          class="btn-secondary"
        >
          {{ showAdvancedOptions ? 'Скрыть' : 'Показать' }} дополнительные настройки
        </button>
        
        <div class="action-buttons">
          <router-link to="/dashboard/client" class="btn-cancel">
            Отмена
          </router-link>
          
          <button
            type="submit"
            :disabled="isSubmitting"
            class="btn-submit"
            :class="{ 'loading': isSubmitting }"
          >
            <span v-if="!isSubmitting">
              🚀 Отправить задачу
            </span>
            <span v-else class="loading-text">
              <span class="loading-spinner"></span>
              Отправка...
            </span>
          </button>
        </div>
      </div>

      <!-- Подсказка -->
      <div class="form-hint">
        <div class="hint-icon">💡</div>
        <div class="hint-content">
          <strong>Совет:</strong> Чем подробнее вы опишете задачу, тем быстрее менеджер сможет её оценить и назначить исполнителя.
        </div>
      </div>
    </form>

    <!-- Модальное окно успеха -->
    <div v-if="showSuccessModal" class="modal-overlay" @click="closeSuccessModal">
      <div class="modal-content" @click.stop>
        <div class="modal-icon">🎉</div>
        <h3 class="modal-title">Задача успешно создана!</h3>
        <p class="modal-message">
          Ваша задача отправлена на рассмотрение. Менеджер свяжется с вами в ближайшее время.
        </p>
        <div class="modal-actions">
          <button @click="createAnotherTask" class="modal-btn secondary">
            Создать ещё задачу
          </button>
          <router-link to="/dashboard/client" class="modal-btn primary">
            Вернуться в дашборд
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import clientTaskService from '@/services/clientTask.service'
import authService from '@/services/auth.service'

export default {
  name: 'TaskForm',
  
  props: {
    // Можно использовать для редактирования существующей задачи
    taskId: {
      type: [String, Number],
      default: null
    }
  },
  
  setup(props) {
    const router = useRouter()
    const formElement = ref(null)
    const fileInput = ref(null)
    
    // Состояние формы
    const formData = ref({
      title: '',
      description: '',
      budget: null,
      deadline: '',
      priority: 'medium',
      category: '',
      attachments: [],
      notifications: {
        email: true,
        sms: false
      },
      is_private: false
    })
    
    // Ошибки валидации
    const errors = ref({})
    
    // Состояние UI
    const isSubmitting = ref(false)
    const isDragging = ref(false)
    const showAdvancedOptions = ref(false)
    const showSuccessModal = ref(false)
    const createdTaskId = ref(null)
    
    // Вычисляемые свойства
    const today = computed(() => {
      return new Date().toISOString().split('T')[0]
    })
    
    const isVipClient = computed(() => {
      const role = authService.getUserRole()
      return role === 'Client VIP'
    })
    
    // Опции для формы
    const priorityOptions = ref([
      {
        value: 'low',
        name: 'Низкий',
        description: 'Обычная очередь',
        icon: '📄'
      },
      {
        value: 'medium',
        name: 'Средний',
        description: 'Приоритетная обработка',
        icon: '⚡'
      },
      {
        value: 'high',
        name: 'Высокий',
        description: 'Срочный приоритет',
        icon: '🚨'
      }
    ])
    
    const categoryOptions = ref([
      { value: 'web', label: '🌐 Веб-разработка' },
      { value: 'mobile', label: '📱 Мобильная разработка' },
      { value: 'design', label: '🎨 Дизайн' },
      { value: 'marketing', label: '📢 Маркетинг' },
      { value: 'seo', label: '🔍 SEO' },
      { value: 'support', label: '🛠️ Техподдержка' },
      { value: 'consulting', label: '💼 Консалтинг' },
      { value: 'other', label: '📁 Другое' }
    ])
    
    // Методы
    const clearError = (field) => {
      if (errors.value[field]) {
        delete errors.value[field]
      }
    }
    
    const formatDate = (dateString) => {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleDateString('ru-RU', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    }
    
    const getFileIcon = (fileType) => {
      if (!fileType) return '📄'
      
      const icons = {
        'application/pdf': '📕',
        'image/': '🖼️',
        'text/': '📝',
        'application/msword': '📘',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document': '📘',
        'application/vnd.ms-excel': '📗',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': '📗'
      }
      
      for (const [type, icon] of Object.entries(icons)) {
        if (fileType.includes(type.replace('*', ''))) {
          return icon
        }
      }
      
      return '📄'
    }
    
    const formatFileSize = (bytes) => {
      if (bytes === 0) return '0 Bytes'
      const k = 1024
      const sizes = ['Bytes', 'KB', 'MB', 'GB']
      const i = Math.floor(Math.log(bytes) / Math.log(k))
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
    }
    
    // Работа с файлами
    const triggerFileInput = () => {
      fileInput.value.click()
    }
    
    const handleFileSelect = (event) => {
      const files = Array.from(event.target.files)
      addFiles(files)
    }
    
    const handleDragOver = (event) => {
      event.preventDefault()
      isDragging.value = true
    }
    
    const handleDragLeave = (event) => {
      event.preventDefault()
      isDragging.value = false
    }
    
    const handleDrop = (event) => {
      event.preventDefault()
      isDragging.value = false
      
      const files = Array.from(event.dataTransfer.files)
      addFiles(files)
    }
    
    const addFiles = (files) => {
      // Проверка максимального количества файлов
      if (formData.value.attachments.length + files.length > 5) {
        alert('Можно загрузить не более 5 файлов')
        return
      }
      
      // Проверка размера файлов
      for (const file of files) {
        if (file.size > 10 * 1024 * 1024) { // 10MB
          alert(`Файл "${file.name}" слишком большой. Максимальный размер: 10MB`)
          return
        }
      }
      
      // Добавляем файлы
      formData.value.attachments.push(...files)
      
      // Сбрасываем input
      if (fileInput.value) {
        fileInput.value.value = ''
      }
    }
    
    const removeFile = (index) => {
      formData.value.attachments.splice(index, 1)
    }
    
    const clearFiles = () => {
      formData.value.attachments = []
    }
    
    // Дополнительные настройки
    const toggleAdvancedOptions = () => {
      showAdvancedOptions.value = !showAdvancedOptions.value
    }
    
    // Валидация формы
    const validateForm = () => {
      const newErrors = {}
      
      if (!formData.value.title.trim()) {
        newErrors.title = 'Название задачи обязательно'
      } else if (formData.value.title.length > 255) {
        newErrors.title = 'Название должно быть не длиннее 255 символов'
      }
      
      if (!formData.value.description.trim()) {
        newErrors.description = 'Описание задачи обязательно'
      } else if (formData.value.description.length < 10) {
        newErrors.description = 'Описание должно быть не менее 10 символов'
      }
      
      if (formData.value.budget !== null && formData.value.budget < 0) {
        newErrors.budget = 'Бюджет не может быть отрицательным'
      }
      
      if (formData.value.deadline) {
        const deadlineDate = new Date(formData.value.deadline)
        const today = new Date()
        today.setHours(0, 0, 0, 0)
        
        if (deadlineDate < today) {
          newErrors.deadline = 'Дедлайн должен быть в будущем'
        }
      }
      
      errors.value = newErrors
      return Object.keys(newErrors).length === 0
    }
    
    // Отправка формы
    const submitForm = async () => {
      if (!validateForm()) {
        // Прокручиваем к первой ошибке
        const firstError = Object.keys(errors.value)[0]
        const errorElement = formElement.value.querySelector(`[name="${firstError}"]`) ||
                            formElement.value.querySelector(`#${firstError}`)
        if (errorElement) {
          errorElement.scrollIntoView({ behavior: 'smooth', block: 'center' })
          errorElement.focus()
        }
        return
      }
      
      try {
        isSubmitting.value = true
        
        // Подготавливаем данные для отправки
        const formDataToSend = new FormData()
        
        // Добавляем текстовые поля
        formDataToSend.append('title', formData.value.title)
        formDataToSend.append('description', formData.value.description)
        
        if (formData.value.budget) {
          formDataToSend.append('budget', formData.value.budget)
        }
        
        if (formData.value.deadline) {
          formDataToSend.append('deadline', formData.value.deadline)
        }
        
        if (isVipClient.value) {
          formDataToSend.append('priority', formData.value.priority)
        }
        
        if (formData.value.category) {
          formDataToSend.append('category', formData.value.category)
        }
        
        // Добавляем файлы
        formData.value.attachments.forEach(file => {
          formDataToSend.append('attachments[]', file)
        })
        
        // Дополнительные настройки
        formDataToSend.append('notifications', JSON.stringify(formData.value.notifications))
        formDataToSend.append('is_private', formData.value.is_private ? '1' : '0')
        
        console.log('📤 Отправка данных задачи:', Object.fromEntries(formDataToSend.entries()))
        
        // Отправляем запрос
        const response = await clientTaskService.createTask(formDataToSend)
        
        if (response.success) {
          createdTaskId.value = response.data.id
          showSuccessModal.value = true
          console.log('✅ Задача создана:', response.data)
        } else {
          throw new Error(response.message || 'Ошибка при создании задачи')
        }
      } catch (error) {
        console.error('❌ Ошибка при создании задачи:', error)
        
        // Обработка ошибок валидации
        if (error.response?.data?.errors) {
          errors.value = error.response.data.errors
          alert('Пожалуйста, исправьте ошибки в форме')
        } else {
          alert(error.message || 'Не удалось создать задачу. Пожалуйста, попробуйте еще раз.')
        }
      } finally {
        isSubmitting.value = false
      }
    }
    
    // Действия после успешного создания
    const closeSuccessModal = () => {
      showSuccessModal.value = false
      router.push('/dashboard/client')
    }
    
    const createAnotherTask = () => {
      showSuccessModal.value = false
      resetForm()
      window.scrollTo(0, 0)
    }
    
    const resetForm = () => {
      formData.value = {
        title: '',
        description: '',
        budget: null,
        deadline: '',
        priority: 'medium',
        category: '',
        attachments: [],
        notifications: {
          email: true,
          sms: false
        },
        is_private: false
      }
      errors.value = {}
    }
    
    // Если редактируем существующую задачу
    const loadTaskData = async () => {
      if (props.taskId) {
        try {
          const response = await clientTaskService.getTask(props.taskId)
          if (response.success) {
            const task = response.data
            
            formData.value = {
              title: task.title,
              description: task.description,
              budget: task.budget,
              deadline: task.deadline ? task.deadline.split('T')[0] : '',
              priority: task.priority || 'medium',
              category: task.category || '',
              attachments: [],
              notifications: {
                email: task.notifications?.email ?? true,
                sms: task.notifications?.sms ?? false
              },
              is_private: task.is_private || false
            }
          }
        } catch (error) {
          console.error('Ошибка загрузки задачи:', error)
        }
      }
    }
    
    // Инициализация
    onMounted(() => {
      if (props.taskId) {
        loadTaskData()
      }
    })
    
    return {
      // Refs
      formElement,
      fileInput,
      formData,
      errors,
      isSubmitting,
      isDragging,
      showAdvancedOptions,
      showSuccessModal,
      createdTaskId,
      
      // Computed
      today,
      isVipClient,
      
      // Options
      priorityOptions,
      categoryOptions,
      
      // Methods
      clearError,
      formatDate,
      getFileIcon,
      formatFileSize,
      triggerFileInput,
      handleFileSelect,
      handleDragOver,
      handleDragLeave,
      handleDrop,
      removeFile,
      clearFiles,
      toggleAdvancedOptions,
      submitForm,
      closeSuccessModal,
      createAnotherTask
    }
  }
}
</script>

<style scoped>
.task-form-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px;
  background: #f8fafc;
  min-height: 100vh;
}

.form-header {
  margin-bottom: 32px;
  text-align: center;
}

.form-header h1 {
  margin: 0 0 8px 0;
  color: #1e293b;
  font-size: 32px;
}

.form-subtitle {
  margin: 0;
  color: #64748b;
  font-size: 16px;
}

.form-section {
  background: white;
  padding: 24px;
  border-radius: 16px;
  margin-bottom: 24px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.form-section h2 {
  margin: 0 0 24px 0;
  color: #1e293b;
  font-size: 20px;
  border-bottom: 2px solid #e2e8f0;
  padding-bottom: 12px;
}

/* Форма */
.form-group {
  margin-bottom: 24px;
}

.form-group:last-child {
  margin-bottom: 0;
}

.form-label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #1e293b;
}

.label-hint {
  display: block;
  font-size: 12px;
  color: #64748b;
  font-weight: normal;
  margin-top: 4px;
}

.form-input,
.form-textarea,
.form-select {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 16px;
  font-family: inherit;
  transition: border-color 0.2s ease;
  background: white;
}

.form-input:focus,
.form-textarea:focus,
.form-select:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.form-input.error,
.form-textarea.error {
  border-color: #ef4444;
}

.form-textarea {
  resize: vertical;
  min-height: 120px;
}

.textarea-info {
  display: flex;
  justify-content: space-between;
  margin-top: 8px;
  font-size: 12px;
}

.char-count {
  color: #94a3b8;
}

.char-warning {
  color: #f59e0b;
}

/* Ошибки */
.has-error .form-label {
  color: #ef4444;
}

.error-message {
  color: #ef4444;
  font-size: 14px;
  margin-top: 8px;
}

/* Строка формы */
.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }
}

/* Input с иконкой */
.input-with-icon {
  position: relative;
}

.input-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  color: #64748b;
  font-size: 16px;
}

.input-with-icon .form-input {
  padding-left: 40px;
}

/* Дата */
.date-hint {
  margin-top: 8px;
  font-size: 14px;
  color: #4f46e5;
  font-weight: 500;
}

/* Приоритет */
.priority-selector {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 12px;
}

.priority-option {
  display: block;
  padding: 16px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.priority-option:hover {
  border-color: #c7d2fe;
  background: #f8fafc;
}

.priority-option.selected {
  border-color: #4f46e5;
  background: #eef2ff;
}

.priority-option.low.selected {
  border-color: #10b981;
  background: #d1fae5;
}

.priority-option.medium.selected {
  border-color: #f59e0b;
  background: #fef3c7;
}

.priority-option.high.selected {
  border-color: #ef4444;
  background: #fee2e2;
}

.priority-input {
  display: none;
}

.priority-content {
  display: flex;
  align-items: center;
  gap: 12px;
}

.priority-icon {
  font-size: 24px;
}

.priority-text {
  flex: 1;
}

.priority-name {
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 2px;
}

.priority-desc {
  font-size: 12px;
  color: #64748b;
}

/* Файлы */
.file-dropzone {
  border: 2px dashed #cbd5e1;
  border-radius: 12px;
  padding: 40px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s ease;
  background: #f8fafc;
}

.file-dropzone:hover {
  border-color: #94a3b8;
  background: #f1f5f9;
}

.file-dropzone.dragover {
  border-color: #4f46e5;
  background: #eef2ff;
}

.file-dropzone.has-files {
  padding: 20px;
  text-align: left;
}

.dropzone-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}

.dropzone-icon {
  font-size: 48px;
  color: #94a3b8;
}

.dropzone-text {
  color: #64748b;
}

.click-here {
  color: #4f46e5;
  font-weight: 500;
}

.dropzone-hint {
  font-size: 14px;
  margin-top: 8px;
  color: #94a3b8;
}

.files-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #e2e8f0;
}

.clear-files-btn {
  background: none;
  border: none;
  color: #ef4444;
  font-size: 14px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
}

.clear-files-btn:hover {
  background: #fee2e2;
}

.file-items {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.file-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px;
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
}

.file-info {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
}

.file-icon {
  font-size: 24px;
}

.file-details {
  flex: 1;
}

.file-name {
  font-weight: 500;
  color: #1e293b;
  margin-bottom: 4px;
  word-break: break-all;
}

.file-size {
  font-size: 12px;
  color: #64748b;
}

.remove-file-btn {
  background: none;
  border: none;
  color: #94a3b8;
  font-size: 18px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
}

.remove-file-btn:hover {
  color: #ef4444;
  background: #fee2e2;
}

.file-input-hidden {
  display: none;
}

.upload-hint {
  margin-top: 8px;
  font-size: 12px;
  color: #64748b;
}

/* Checkbox */
.checkbox-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
}

.checkbox-input {
  display: none;
}

.checkbox-custom {
  width: 20px;
  height: 20px;
  border: 2px solid #cbd5e1;
  border-radius: 4px;
  position: relative;
  transition: all 0.2s ease;
}

.checkbox-input:checked + .checkbox-custom {
  border-color: #4f46e5;
  background: #4f46e5;
}

.checkbox-input:checked + .checkbox-custom::after {
  content: '✓';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-size: 12px;
  font-weight: bold;
}

.checkbox-text {
  color: #1e293b;
}

/* Кнопки формы */
.form-actions {
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-top: 32px;
}

.action-buttons {
  display: flex;
  gap: 16px;
  justify-content: flex-end;
}

.btn-secondary {
  align-self: flex-start;
  background: none;
  border: none;
  color: #4f46e5;
  font-size: 14px;
  cursor: pointer;
  padding: 8px 16px;
  border-radius: 8px;
  transition: background 0.2s ease;
}

.btn-secondary:hover {
  background: #eef2ff;
}

.btn-cancel {
  padding: 12px 24px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  color: #64748b;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.2s ease;
}

.btn-cancel:hover {
  border-color: #cbd5e1;
  background: #f1f5f9;
}

.btn-submit {
  padding: 12px 32px;
  background: #4f46e5;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  font-size: 16px;
  cursor: pointer;
  transition: background 0.2s ease;
}

.btn-submit:hover:not(:disabled) {
  background: #3730a3;
}

.btn-submit:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-submit.loading {
  background: #8b5cf6;
}

.loading-text {
  display: flex;
  align-items: center;
  gap: 8px;
}

.loading-spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

/* Подсказка */
.form-hint {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  margin-top: 24px;
  padding: 16px;
  background: #fef3c7;
  border-radius: 8px;
  border-left: 4px solid #f59e0b;
}

.hint-icon {
  font-size: 24px;
}

.hint-content {
  flex: 1;
  color: #92400e;
}

/* Модальное окно */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal-content {
  background: white;
  padding: 40px;
  border-radius: 20px;
  max-width: 500px;
  width: 90%;
  text-align: center;
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from { transform: translateY(20px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

.modal-icon {
  font-size: 64px;
  margin-bottom: 20px;
}

.modal-title {
  margin: 0 0 16px 0;
  color: #1e293b;
  font-size: 24px;
}

.modal-message {
  margin: 0 0 32px 0;
  color: #64748b;
  line-height: 1.5;
}

.modal-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
}

.modal-btn {
  padding: 12px 24px;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.2s ease;
}

.modal-btn.secondary {
  background: #f1f5f9;
  color: #475569;
  border: 2px solid #e2e8f0;
}

.modal-btn.secondary:hover {
  background: #e2e8f0;
}

.modal-btn.primary {
  background: #4f46e5;
  color: white;
  border: 2px solid #4f46e5;
}

.modal-btn.primary:hover {
  background: #3730a3;
  border-color: #3730a3;
}

/* Адаптивность */
@media (max-width: 768px) {
  .task-form-container {
    padding: 16px;
  }
  
  .form-header h1 {
    font-size: 24px;
  }
  
  .form-section {
    padding: 16px;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .modal-actions {
    flex-direction: column;
  }
}
</style>