<template>
  <div class="client-tasks-my-page">
    <!-- Заголовок страницы -->
    <div class="page-header">
      <div class="header-content">
        <h1>📋 Мои задачи</h1>
        <p class="page-subtitle">Просмотр и управление всеми вашими задачами</p>
      </div>
      <div class="header-actions">
        <router-link to="/client-tasks/create" class="create-task-btn">
          <span class="btn-icon">➕</span>
          <span class="btn-text">Создать задачу</span>
        </router-link>
        <router-link to="/dashboard/client" class="back-to-dashboard-btn">
          ← Назад в дашборд
        </router-link>
      </div>
    </div>

    <!-- Хлебные крошки -->
    <div class="breadcrumbs">
      <router-link to="/dashboard/client" class="breadcrumb">Дашборд</router-link>
      <span class="breadcrumb-separator">/</span>
      <span class="breadcrumb active">Мои задачи</span>
    </div>

    <!-- Фильтры и поиск -->
    <div class="filters-section">
      <div class="search-box">
        <div class="search-icon">🔍</div>
        <input
          type="text"
          v-model="searchQuery"
          placeholder="Поиск по названию или описанию..."
          class="search-input"
          @input="handleSearch"
        />
        <button v-if="searchQuery" @click="clearSearch" class="clear-search-btn">
          ✕
        </button>
      </div>

      <div class="filters-row">
        <!-- Фильтр по статусу -->
        <div class="filter-group">
          <label class="filter-label">Статус:</label>
          <div class="filter-buttons">
            <button
              v-for="status in statusFilters"
              :key="status.value"
              @click="toggleStatusFilter(status.value)"
              class="filter-btn"
              :class="{
                'active': selectedStatuses.includes(status.value),
                [status.class]: true
              }"
            >
              {{ status.label }}
              <span class="filter-count">{{ getStatusCount(status.value) }}</span>
            </button>
          </div>
        </div>

        <!-- Фильтр по приоритету -->
        <div class="filter-group">
          <label class="filter-label">Приоритет:</label>
          <div class="filter-buttons">
            <button
              v-for="priority in priorityFilters"
              :key="priority.value"
              @click="togglePriorityFilter(priority.value)"
              class="filter-btn"
              :class="{
                'active': selectedPriorities.includes(priority.value),
                [priority.class]: true
              }"
            >
              {{ priority.label }}
            </button>
          </div>
        </div>

        <!-- Сортировка -->
        <div class="sort-group">
          <label class="filter-label">Сортировка:</label>
          <select v-model="sortBy" @change="applyFilters" class="sort-select">
            <option value="created_at_desc">Сначала новые</option>
            <option value="created_at_asc">Сначала старые</option>
            <option value="deadline_asc">Ближайший дедлайн</option>
            <option value="deadline_desc">Дальний дедлайн</option>
            <option value="priority_asc">Приоритет (высокий)</option>
            <option value="priority_desc">Приоритет (низкий)</option>
          </select>
        </div>
      </div>

      <!-- Активные фильтры -->
      <div v-if="activeFiltersCount > 0" class="active-filters">
        <div class="active-filters-label">
          Активные фильтры ({{ activeFiltersCount }}):
        </div>
        <div class="active-filters-list">
          <span
            v-for="status in selectedStatuses"
            :key="'status-' + status"
            class="active-filter-tag"
            @click="removeStatusFilter(status)"
          >
            {{ getStatusLabel(status) }}
            <span class="remove-tag">×</span>
          </span>
          <span
            v-for="priority in selectedPriorities"
            :key="'priority-' + priority"
            class="active-filter-tag"
            @click="removePriorityFilter(priority)"
          >
            {{ getPriorityLabel(priority) }}
            <span class="remove-tag">×</span>
          </span>
          <button @click="clearAllFilters" class="clear-all-btn">
            Очистить все
          </button>
        </div>
      </div>
    </div>

    <!-- Индикатор загрузки -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>Загрузка задач...</p>
    </div>

    <!-- Ошибка загрузки -->
    <div v-else-if="error" class="error-container">
      <div class="error-icon">⚠️</div>
      <h3>Ошибка загрузки задач</h3>
      <p>{{ error }}</p>
      <button @click="loadTasks" class="retry-btn">Повторить попытку</button>
    </div>

    <!-- Основной контент -->
    <div v-else class="tasks-content">
      <!-- Статистика -->
      <div class="stats-summary">
        <div class="stat-item">
          <div class="stat-value">{{ tasks.length }}</div>
          <div class="stat-label">Всего задач</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ filteredTasks.length }}</div>
          <div class="stat-label">Показано</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ completedCount }}</div>
          <div class="stat-label">Завершено</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ inProgressCount }}</div>
          <div class="stat-label">В работе</div>
        </div>
      </div>

      <!-- Переключение вида -->
      <div class="view-toggle">
        <button
          @click="viewMode = 'list'"
          class="view-btn"
          :class="{ 'active': viewMode === 'list' }"
        >
          📋 Список
        </button>
        <button
          @click="viewMode = 'grid'"
          class="view-btn"
          :class="{ 'active': viewMode === 'grid' }"
        >
          🗂️ Сетка
        </button>
        <button
          @click="viewMode = 'kanban'"
          class="view-btn"
          :class="{ 'active': viewMode === 'kanban' }"
        >
          📋 Канбан
        </button>
      </div>

      <!-- Результаты поиска -->
      <div v-if="filteredTasks.length === 0" class="empty-state">
        <div class="empty-icon">🔍</div>
        <h3>Задачи не найдены</h3>
        <p v-if="searchQuery || selectedStatuses.length > 0 || selectedPriorities.length > 0">
          Попробуйте изменить параметры поиска или фильтры
        </p>
        <p v-else>У вас пока нет созданных задач</p>
        <div class="empty-actions">
          <button @click="clearAllFilters" class="empty-action-btn">
            Очистить фильтры
          </button>
          <router-link to="/client-tasks/create" class="empty-action-btn primary">
            ➕ Создать первую задачу
          </router-link>
        </div>
      </div>

      <!-- Вид списка -->
      <div v-else-if="viewMode === 'list'" class="tasks-list-view">
        <div class="tasks-table">
          <div class="table-header">
            <div class="table-cell task-title-header">Задача</div>
            <div class="table-cell task-status-header">Статус</div>
            <div class="table-cell task-priority-header">Приоритет</div>
            <div class="table-cell task-deadline-header">Дедлайн</div>
            <div class="table-cell task-project-header">Проект</div>
            <div class="table-cell task-actions-header">Действия</div>
          </div>

          <div v-for="task in filteredTasks" :key="task.id" class="table-row">
            <div class="table-cell task-title-cell">
              <div class="task-title-wrapper">
                <h4 class="task-title">
                  <router-link :to="`/client-tasks/${task.id}`" class="task-title-link">
                    {{ task.title }}
                  </router-link>
                </h4>
                <p class="task-description" v-if="task.description">
                  {{ truncateText(task.description, 80) }}
                </p>
                <div class="task-meta">
                  <span class="task-id">#{{ task.id }}</span>
                  <span class="task-created">
                    📅 Создано: {{ formatDate(task.created_at) }}
                  </span>
                  <span class="task-budget" v-if="task.budget">
                    💰 {{ formatCurrency(task.budget) }}
                  </span>
                </div>
              </div>
            </div>

            <div class="table-cell task-status-cell">
              <div class="task-status-badge" :class="getTaskStatusClass(task.status)">
                {{ getStatusText(task.status) }}
              </div>
              <div class="task-updated" v-if="task.updated_at">
                Обновлено: {{ formatDate(task.updated_at, true) }}
              </div>
            </div>

            <div class="table-cell task-priority-cell">
              <div class="task-priority-badge" :class="getPriorityClass(task.priority)">
                {{ getPriorityText(task.priority) }}
              </div>
            </div>

            <div class="table-cell task-deadline-cell">
              <div class="deadline-info">
                <span v-if="task.deadline" class="deadline-date">
                  {{ formatDate(task.deadline) }}
                </span>
                <span v-else class="deadline-empty">Не указан</span>
                <div class="deadline-warning" v-if="isDeadlineNear(task.deadline)">
                  ⚠️ {{ getDeadlineWarning(task.deadline) }}
                </div>
              </div>
            </div>

            <div class="table-cell task-project-cell">
              <div v-if="task.project" class="project-info">
                <router-link :to="`/projects/${task.project.id}`" class="project-link">
                  📁 {{ task.project.name }}
                </router-link>
              </div>
              <span v-else class="no-project">Без проекта</span>
            </div>

            <div class="table-cell task-actions-cell">
              <div class="task-actions">
                <router-link 
                  :to="`/client-tasks/${task.id}`" 
                  class="action-btn view-btn"
                  title="Просмотр"
                >
                  👁️
                </router-link>
                <button 
                  v-if="canEditTask(task)"
                  @click="editTask(task.id)"
                  class="action-btn edit-btn"
                  title="Редактировать"
                >
                  ✏️
                </button>
                <button 
                  v-if="canCancelTask(task)"
                  @click="confirmCancelTask(task)"
                  class="action-btn cancel-btn"
                  title="Отменить"
                >
                  ❌
                </button>
                <button 
                  v-if="task.attachments_count > 0"
                  @click="showAttachments(task)"
                  class="action-btn attachments-btn"
                  title="Вложения"
                >
                  📎 {{ task.attachments_count }}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Вид сетки -->
      <div v-else-if="viewMode === 'grid'" class="tasks-grid-view">
        <div class="tasks-grid">
          <div v-for="task in filteredTasks" :key="task.id" class="task-card">
            <div class="task-card-header">
              <div class="task-card-priority" :class="getPriorityClass(task.priority)">
                {{ getPriorityText(task.priority) }}
              </div>
              <div class="task-card-status" :class="getTaskStatusClass(task.status)">
                {{ getStatusText(task.status) }}
              </div>
            </div>

            <div class="task-card-body">
              <h4 class="task-card-title">
                <router-link :to="`/client-tasks/${task.id}`" class="task-card-title-link">
                  {{ task.title }}
                </router-link>
              </h4>
              
              <p class="task-card-description" v-if="task.description">
                {{ truncateText(task.description, 100) }}
              </p>

              <div class="task-card-meta">
                <div class="meta-item" v-if="task.project">
                  <span class="meta-icon">📁</span>
                  <span class="meta-text">{{ task.project.name }}</span>
                </div>
                <div class="meta-item" v-if="task.budget">
                  <span class="meta-icon">💰</span>
                  <span class="meta-text">{{ formatCurrency(task.budget) }}</span>
                </div>
                <div class="meta-item" v-if="task.deadline">
                  <span class="meta-icon">📅</span>
                  <span class="meta-text">{{ formatDate(task.deadline) }}</span>
                  <span v-if="isDeadlineNear(task.deadline)" class="deadline-warning-small">
                    ⚠️
                  </span>
                </div>
              </div>
            </div>

            <div class="task-card-footer">
              <div class="task-card-actions">
                <router-link :to="`/client-tasks/${task.id}`" class="card-action-btn view">
                  Просмотр
                </router-link>
                <button 
                  v-if="canEditTask(task)"
                  @click="editTask(task.id)"
                  class="card-action-btn edit"
                >
                  Редактировать
                </button>
              </div>
              <div class="task-card-info">
                <span class="task-id">#{{ task.id }}</span>
                <span class="task-created">
                  {{ formatDate(task.created_at, true) }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Вид канбан -->
      <div v-else class="tasks-kanban-view">
        <div class="kanban-board">
          <div class="kanban-column" v-for="status in kanbanStatuses" :key="status.value">
            <div class="kanban-column-header" :class="status.class">
              <h3 class="column-title">{{ status.label }}</h3>
              <span class="column-count">
                {{ getTasksByStatus(status.value).length }}
              </span>
            </div>
            <div class="kanban-column-body">
              <div
                v-for="task in getTasksByStatus(status.value)"
                :key="task.id"
                class="kanban-task"
                @click="$router.push(`/client-tasks/${task.id}`)"
              >
                <div class="kanban-task-header">
                  <div class="kanban-task-priority" :class="getPriorityClass(task.priority)">
                    {{ getPriorityText(task.priority) }}
                  </div>
                  <div class="kanban-task-id">#{{ task.id }}</div>
                </div>
                <h4 class="kanban-task-title">{{ task.title }}</h4>
                <div class="kanban-task-meta">
                  <span v-if="task.project" class="kanban-project">
                    📁 {{ task.project.name }}
                  </span>
                  <span v-if="task.deadline" class="kanban-deadline">
                    📅 {{ formatDate(task.deadline, true) }}
                  </span>
                </div>
              </div>
              <div
                v-if="getTasksByStatus(status.value).length === 0"
                class="kanban-empty"
              >
                Нет задач
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Пагинация -->
      <div v-if="filteredTasks.length > 0" class="pagination">
        <button
          @click="prevPage"
          :disabled="currentPage === 1"
          class="pagination-btn prev"
        >
          ← Назад
        </button>
        
        <div class="pagination-pages">
          <button
            v-for="page in visiblePages"
            :key="page"
            @click="goToPage(page)"
            class="pagination-page"
            :class="{ active: page === currentPage }"
          >
            {{ page }}
          </button>
          <span v-if="showEllipsis" class="pagination-ellipsis">...</span>
        </div>
        
        <button
          @click="nextPage"
          :disabled="currentPage === totalPages"
          class="pagination-btn next"
        >
          Вперед →
        </button>
        
        <div class="pagination-info">
          Показано {{ startIndex + 1 }}-{{ endIndex }} из {{ filteredTasks.length }}
        </div>
      </div>

      <!-- Экспорт -->
      <div v-if="filteredTasks.length > 0" class="export-section">
        <button @click="exportToCSV" class="export-btn">
          📥 Экспорт в CSV
        </button>
        <button @click="printTasks" class="export-btn">
          🖨️ Печать
        </button>
      </div>
    </div>

    <!-- Модальное окно подтверждения отмены -->
    <div v-if="showCancelModal" class="modal-overlay" @click.self="closeCancelModal">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title">Подтверждение отмены</h3>
          <button @click="closeCancelModal" class="modal-close-btn">×</button>
        </div>
        <div class="modal-body">
          <p>Вы уверены, что хотите отменить задачу "<strong>{{ taskToCancel?.title }}</strong>"?</p>
          <p class="modal-warning">⚠️ Это действие нельзя отменить.</p>
          
          <div class="cancel-reason" v-if="taskToCancel">
            <label for="cancelReason" class="cancel-reason-label">
              Причина отмены (необязательно):
            </label>
            <textarea
              id="cancelReason"
              v-model="cancelReason"
              placeholder="Укажите причину отмены задачи..."
              class="cancel-reason-input"
              rows="3"
            ></textarea>
          </div>
        </div>
        <div class="modal-actions">
          <button @click="closeCancelModal" class="modal-btn secondary">
            Отмена
          </button>
          <button @click="confirmCancel" class="modal-btn danger">
            Да, отменить задачу
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import clientTaskService from '@/services/clientTask.service'

export default {
  name: 'ClientTasksMyPage',
  
  setup() {
    const router = useRouter()
    
    // Состояние
    const loading = ref(true)
    const error = ref(null)
    const tasks = ref([])
    const searchQuery = ref('')
    const viewMode = ref('list')
    const currentPage = ref(1)
    const pageSize = ref(10)
    const showCancelModal = ref(false)
    const taskToCancel = ref(null)
    const cancelReason = ref('')
    
    // Фильтры
    const selectedStatuses = ref([])
    const selectedPriorities = ref([])
    const sortBy = ref('created_at_desc')
    
    // Фильтры статусов
    const statusFilters = ref([
      { value: 'pending', label: 'На рассмотрении', class: 'status-pending' },
      { value: 'approved', label: 'Одобрено', class: 'status-approved' },
      { value: 'in_progress', label: 'В работе', class: 'status-in-progress' },
      { value: 'completed', label: 'Завершено', class: 'status-completed' },
      { value: 'cancelled', label: 'Отменено', class: 'status-cancelled' },
      { value: 'rejected', label: 'Отклонено', class: 'status-rejected' }
    ])
    
    // Фильтры приоритетов
    const priorityFilters = ref([
      { value: 'high', label: 'Высокий', class: 'priority-high' },
      { value: 'medium', label: 'Средний', class: 'priority-medium' },
      { value: 'low', label: 'Низкий', class: 'priority-low' }
    ])
    
    // Статусы для канбан-доски
    const kanbanStatuses = ref([
      { value: 'pending', label: 'На рассмотрении', class: 'kanban-pending' },
      { value: 'approved', label: 'Одобрено', class: 'kanban-approved' },
      { value: 'in_progress', label: 'В работе', class: 'kanban-in-progress' },
      { value: 'completed', label: 'Завершено', class: 'kanban-completed' }
    ])
    
    // Вычисляемые свойства
    const activeFiltersCount = computed(() => {
      return selectedStatuses.value.length + selectedPriorities.value.length
    })
    
    const completedCount = computed(() => {
      return tasks.value.filter(task => task.status === 'completed').length
    })
    
    const inProgressCount = computed(() => {
      return tasks.value.filter(task => task.status === 'in_progress').length
    })
    
    // Фильтрация задач
    const filteredTasks = computed(() => {
      let result = [...tasks.value]
      
      // Поиск по тексту
      if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase()
        result = result.filter(task => 
          task.title.toLowerCase().includes(query) ||
          (task.description && task.description.toLowerCase().includes(query))
        )
      }
      
      // Фильтрация по статусу
      if (selectedStatuses.value.length > 0) {
        result = result.filter(task => selectedStatuses.value.includes(task.status))
      }
      
      // Фильтрация по приоритету
      if (selectedPriorities.value.length > 0) {
        result = result.filter(task => selectedPriorities.value.includes(task.priority))
      }
      
      // Сортировка
      result.sort((a, b) => {
        switch (sortBy.value) {
          case 'created_at_desc':
            return new Date(b.created_at) - new Date(a.created_at)
          case 'created_at_asc':
            return new Date(a.created_at) - new Date(b.created_at)
          case 'deadline_asc':
            if (!a.deadline && !b.deadline) return 0
            if (!a.deadline) return 1
            if (!b.deadline) return -1
            return new Date(a.deadline) - new Date(b.deadline)
          case 'deadline_desc':
            if (!a.deadline && !b.deadline) return 0
            if (!a.deadline) return 1
            if (!b.deadline) return -1
            return new Date(b.deadline) - new Date(a.deadline)
          case 'priority_asc':
            const priorityOrder = { high: 1, medium: 2, low: 3 }
            return (priorityOrder[a.priority] || 4) - (priorityOrder[b.priority] || 4)
          case 'priority_desc':
            const priorityOrderDesc = { high: 3, medium: 2, low: 1 }
            return (priorityOrderDesc[a.priority] || 0) - (priorityOrderDesc[b.priority] || 0)
          default:
            return 0
        }
      })
      
      return result
    })
    
    // Пагинация
    const totalPages = computed(() => {
      return Math.ceil(filteredTasks.value.length / pageSize.value)
    })
    
    const startIndex = computed(() => {
      return (currentPage.value - 1) * pageSize.value
    })
    
    const endIndex = computed(() => {
      return Math.min(startIndex.value + pageSize.value, filteredTasks.value.length)
    })
    
    const paginatedTasks = computed(() => {
      return filteredTasks.value.slice(startIndex.value, endIndex.value)
    })
    
    const visiblePages = computed(() => {
      const pages = []
      const maxVisible = 5
      
      if (totalPages.value <= maxVisible) {
        for (let i = 1; i <= totalPages.value; i++) {
          pages.push(i)
        }
      } else {
        let start = Math.max(1, currentPage.value - 2)
        let end = Math.min(totalPages.value, start + maxVisible - 1)
        
        if (end - start + 1 < maxVisible) {
          start = end - maxVisible + 1
        }
        
        for (let i = start; i <= end; i++) {
          pages.push(i)
        }
      }
      
      return pages
    })
    
    const showEllipsis = computed(() => {
      return totalPages.value > 5 && currentPage.value < totalPages.value - 2
    })
    
    // Методы
    const loadTasks = async () => {
      try {
        loading.value = true
        error.value = null
        
        const response = await clientTaskService.getMyTasks()
        
        if (response.success && response.data) {
          tasks.value = response.data.map(task => ({
            ...task,
            attachments_count: task.attachments?.length || 0
          }))
          console.log('✅ Задачи загружены:', tasks.value.length)
        } else {
          throw new Error(response.message || 'Неверный формат ответа')
        }
      } catch (err) {
        console.error('❌ Ошибка загрузки задач:', err)
        error.value = err.message || 'Не удалось загрузить задачи'
        
        // Тестовые данные
        loadTestData()
      } finally {
        loading.value = false
      }
    }
    
    const loadTestData = () => {
      console.log('🧪 Загрузка тестовых данных...')
      tasks.value = [
        {
          id: 1,
          title: 'Разработка лендинга для компании',
          description: 'Создание одностраничного сайта с адаптивным дизайном и формой обратной связи',
          status: 'in_progress',
          priority: 'high',
          budget: 150000,
          deadline: '2024-12-25T00:00:00Z',
          created_at: '2024-12-10T10:30:00Z',
          updated_at: '2024-12-15T14:20:00Z',
          project: { id: 1, name: 'Веб-разработка' },
          attachments: []
        },
        {
          id: 2,
          title: 'Дизайн мобильного приложения',
          description: 'Разработка UI/UX дизайна для банковского приложения',
          status: 'pending',
          priority: 'medium',
          budget: 200000,
          deadline: '2024-12-20T00:00:00Z',
          created_at: '2024-12-09T14:20:00Z',
          updated_at: '2024-12-09T14:20:00Z',
          project: { id: 2, name: 'Мобильная разработка' },
          attachments: [{ id: 1, name: 'макет.jpg' }]
        },
        {
          id: 3,
          title: 'Оптимизация SEO сайта',
          description: 'Проведение аудита и внедрение рекомендаций по SEO',
          status: 'completed',
          priority: 'low',
          budget: 80000,
          deadline: '2024-12-05T00:00:00Z',
          created_at: '2024-12-01T09:15:00Z',
          updated_at: '2024-12-05T16:30:00Z',
          project: null,
          attachments: []
        },
        {
          id: 4,
          title: 'Интеграция платежной системы',
          description: 'Настройка и интеграция платежного шлюза на сайте',
          status: 'in_progress',
          priority: 'high',
          budget: 120000,
          deadline: '2024-12-22T00:00:00Z',
          created_at: '2024-12-08T11:45:00Z',
          updated_at: '2024-12-14T09:30:00Z',
          project: { id: 1, name: 'Веб-разработка' },
          attachments: []
        },
        {
          id: 5,
          title: 'Тестирование сайта',
          description: 'Проведение функционального и нагрузочного тестирования',
          status: 'approved',
          priority: 'medium',
          budget: 60000,
          deadline: '2024-12-18T00:00:00Z',
          created_at: '2024-12-05T13:20:00Z',
          updated_at: '2024-12-10T10:15:00Z',
          project: { id: 1, name: 'Веб-разработка' },
          attachments: []
        }
      ]
    }
    
    const getStatusCount = (status) => {
      return tasks.value.filter(task => task.status === status).length
    }
    
    const getStatusLabel = (status) => {
      const filter = statusFilters.value.find(f => f.value === status)
      return filter ? filter.label : status
    }
    
    const getPriorityLabel = (priority) => {
      const filter = priorityFilters.value.find(f => f.value === priority)
      return filter ? filter.label : priority
    }
    
    const toggleStatusFilter = (status) => {
      const index = selectedStatuses.value.indexOf(status)
      if (index === -1) {
        selectedStatuses.value.push(status)
      } else {
        selectedStatuses.value.splice(index, 1)
      }
      currentPage.value = 1
    }
    
    const togglePriorityFilter = (priority) => {
      const index = selectedPriorities.value.indexOf(priority)
      if (index === -1) {
        selectedPriorities.value.push(priority)
      } else {
        selectedPriorities.value.splice(index, 1)
      }
      currentPage.value = 1
    }
    
    const removeStatusFilter = (status) => {
      selectedStatuses.value = selectedStatuses.value.filter(s => s !== status)
      currentPage.value = 1
    }
    
    const removePriorityFilter = (priority) => {
      selectedPriorities.value = selectedPriorities.value.filter(p => p !== priority)
      currentPage.value = 1
    }
    
    const clearAllFilters = () => {
      selectedStatuses.value = []
      selectedPriorities.value = []
      searchQuery.value = ''
      sortBy.value = 'created_at_desc'
      currentPage.value = 1
    }
    
    const handleSearch = () => {
      currentPage.value = 1
    }
    
    const clearSearch = () => {
      searchQuery.value = ''
      currentPage.value = 1
    }
    
    const applyFilters = () => {
      currentPage.value = 1
    }
    
    const getTaskStatusClass = (status) => {
      const classes = {
        'pending': 'status-pending',
        'in_progress': 'status-in-progress',
        'completed': 'status-completed',
        'cancelled': 'status-cancelled',
        'approved': 'status-approved',
        'rejected': 'status-rejected'
      }
      return classes[status] || 'status-unknown'
    }
    
    const getStatusText = (status) => {
      const texts = {
        'pending': 'На рассмотрении',
        'in_progress': 'В работе',
        'completed': 'Завершено',
        'cancelled': 'Отменено',
        'approved': 'Одобрено',
        'rejected': 'Отклонено'
      }
      return texts[status] || status
    }
    
    const getPriorityClass = (priority) => {
      const classes = {
        'high': 'priority-high',
        'medium': 'priority-medium',
        'low': 'priority-low'
      }
      return classes[priority] || 'priority-unknown'
    }
    
    const getPriorityText = (priority) => {
      const texts = {
        'high': 'Высокий',
        'medium': 'Средний',
        'low': 'Низкий'
      }
      return texts[priority] || priority
    }
    
    const formatDate = (dateString, short = false) => {
      if (!dateString) return 'Не указано'
      try {
        const date = new Date(dateString)
        if (short) {
          return date.toLocaleDateString('ru-RU')
        }
        return date.toLocaleDateString('ru-RU', {
          day: 'numeric',
          month: 'long',
          year: 'numeric'
        })
      } catch {
        return dateString
      }
    }
    
    const formatCurrency = (amount) => {
      if (!amount) return 'Не указано'
      return new Intl.NumberFormat('ru-RU', {
        style: 'currency',
        currency: 'KZT',
        minimumFractionDigits: 0
      }).format(amount)
    }
    
    const truncateText = (text, maxLength) => {
      if (!text) return ''
      if (text.length <= maxLength) return text
      return text.substring(0, maxLength) + '...'
    }
    
    const isDeadlineNear = (deadline) => {
      if (!deadline) return false
      try {
        const date = new Date(deadline)
        const today = new Date()
        const diffTime = date - today
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
        return diffDays <= 3 && diffDays >= 0
      } catch {
        return false
      }
    }
    
    const getDeadlineWarning = (deadline) => {
      if (!deadline) return ''
      try {
        const date = new Date(deadline)
        const today = new Date()
        const diffTime = date - today
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
        
        if (diffDays < 0) return 'Просрочено'
        if (diffDays === 0) return 'Сегодня'
        if (diffDays === 1) return 'Завтра'
        return `Осталось ${diffDays} дня`
      } catch {
        return ''
      }
    }
    
    const canEditTask = (task) => {
      return ['pending', 'approved'].includes(task.status)
    }
    
    const canCancelTask = (task) => {
      return ['pending', 'approved', 'in_progress'].includes(task.status)
    }
    
    const editTask = (taskId) => {
      router.push(`/client-tasks/edit/${taskId}`)
    }
    
    const confirmCancelTask = (task) => {
      taskToCancel.value = task
      cancelReason.value = ''
      showCancelModal.value = true
    }
    
    const closeCancelModal = () => {
      showCancelModal.value = false
      taskToCancel.value = null
      cancelReason.value = ''
    }
    
    const confirmCancel = async () => {
      if (!taskToCancel.value) return
      
      try {
        const response = await clientTaskService.cancelTask(taskToCancel.value.id, {
          reason: cancelReason.value
        })
        
        if (response.success) {
          // Обновляем статус задачи локально
          const index = tasks.value.findIndex(t => t.id === taskToCancel.value.id)
          if (index !== -1) {
            tasks.value[index].status = 'cancelled'
            tasks.value[index].updated_at = new Date().toISOString()
          }
          
          alert('Задача успешно отменена')
        } else {
          throw new Error(response.message || 'Ошибка при отмене задачи')
        }
      } catch (err) {
        console.error('❌ Ошибка отмены задачи:', err)
        alert(err.message || 'Не удалось отменить задачу')
      } finally {
        closeCancelModal()
      }
    }
    
    const showAttachments = (task) => {
      alert(`Вложения задачи "${task.title}": ${task.attachments_count} файлов`)
    }
    
    const getTasksByStatus = (status) => {
      return filteredTasks.value.filter(task => task.status === status)
    }
    
    // Пагинация
    const prevPage = () => {
      if (currentPage.value > 1) {
        currentPage.value--
      }
    }
    
    const nextPage = () => {
      if (currentPage.value < totalPages.value) {
        currentPage.value++
      }
    }
    
    const goToPage = (page) => {
      currentPage.value = page
    }
    
    // Экспорт
    const exportToCSV = () => {
      const headers = ['ID', 'Название', 'Статус', 'Приоритет', 'Дедлайн', 'Бюджет', 'Проект']
      const rows = filteredTasks.value.map(task => [
        task.id,
        task.title,
        getStatusText(task.status),
        getPriorityText(task.priority),
        task.deadline ? formatDate(task.deadline) : '',
        task.budget || '',
        task.project?.name || ''
      ])
      
      const csvContent = [
        headers.join(','),
        ...rows.map(row => row.map(cell => `"${cell}"`).join(','))
      ].join('\n')
      
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
      const link = document.createElement('a')
      const url = URL.createObjectURL(blob)
      
      link.setAttribute('href', url)
      link.setAttribute('download', `мои_задачи_${new Date().toISOString().split('T')[0]}.csv`)
      link.style.visibility = 'hidden'
      
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      
      alert('CSV файл успешно скачан')
    }
    
    const printTasks = () => {
      window.print()
    }
    
    // Загрузка при монтировании
    onMounted(() => {
      console.log('🚀 ClientTasksMyPage mounted')
      loadTasks()
    })
    
    return {
      // Состояние
      loading,
      error,
      tasks,
      searchQuery,
      viewMode,
      currentPage,
      selectedStatuses,
      selectedPriorities,
      sortBy,
      showCancelModal,
      taskToCancel,
      cancelReason,
      
      // Фильтры
      statusFilters,
      priorityFilters,
      kanbanStatuses,
      
      // Вычисляемые свойства
      activeFiltersCount,
      completedCount,
      inProgressCount,
      filteredTasks,
      totalPages,
      startIndex,
      endIndex,
      paginatedTasks,
      visiblePages,
      showEllipsis,
      
      // Методы
      loadTasks,
      getStatusCount,
      getStatusLabel,
      getPriorityLabel,
      toggleStatusFilter,
      togglePriorityFilter,
      removeStatusFilter,
      removePriorityFilter,
      clearAllFilters,
      handleSearch,
      clearSearch,
      applyFilters,
      getTaskStatusClass,
      getStatusText,
      getPriorityClass,
      getPriorityText,
      formatDate,
      formatCurrency,
      truncateText,
      isDeadlineNear,
      getDeadlineWarning,
      canEditTask,
      canCancelTask,
      editTask,
      confirmCancelTask,
      closeCancelModal,
      confirmCancel,
      showAttachments,
      getTasksByStatus,
      prevPage,
      nextPage,
      goToPage,
      exportToCSV,
      printTasks
    }
  }
}
</script>

<style scoped>
.client-tasks-my-page {
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
  background: #f8fafc;
  min-height: 100vh;
}

/* Заголовок страницы */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding: 24px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.header-content h1 {
  margin: 0 0 8px 0;
  color: #1e293b;
  font-size: 32px;
}

.page-subtitle {
  margin: 0;
  color: #64748b;
  font-size: 16px;
}

.header-actions {
  display: flex;
  gap: 16px;
  align-items: center;
}

.create-task-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  background: #4f46e5;
  color: white;
  text-decoration: none;
  border-radius: 8px;
  font-weight: 500;
  transition: all 0.2s ease;
}

.create-task-btn:hover {
  background: #3730a3;
  transform: translateY(-2px);
}

.btn-icon {
  font-size: 18px;
}

.back-to-dashboard-btn {
  color: #64748b;
  text-decoration: none;
  font-weight: 500;
  padding: 8px 16px;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.back-to-dashboard-btn:hover {
  color: #4f46e5;
  background: #eef2ff;
}

/* Хлебные крошки */
.breadcrumbs {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 24px;
  padding: 16px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.breadcrumb {
  color: #64748b;
  text-decoration: none;
  font-size: 14px;
  transition: color 0.2s ease;
}

.breadcrumb:hover {
  color: #4f46e5;
}

.breadcrumb.active {
  color: #1e293b;
  font-weight: 500;
}

.breadcrumb-separator {
  color: #cbd5e1;
}

/* Фильтры и поиск */
.filters-section {
  background: white;
  padding: 24px;
  border-radius: 16px;
  margin-bottom: 24px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.search-box {
  position: relative;
  margin-bottom: 24px;
}

.search-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  color: #64748b;
  font-size: 18px;
}

.search-input {
  width: 100%;
  padding: 14px 16px 14px 48px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-size: 16px;
  transition: all 0.2s ease;
}

.search-input:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.clear-search-btn {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: #94a3b8;
  font-size: 18px;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
}

.clear-search-btn:hover {
  color: #64748b;
  background: #f1f5f9;
}

.filters-row {
  display: flex;
  flex-wrap: wrap;
  gap: 24px;
  margin-bottom: 20px;
}

.filter-group {
  flex: 1;
  min-width: 300px;
}

.filter-label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #1e293b;
}

.filter-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.filter-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  background: #f1f5f9;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 14px;
  color: #475569;
  cursor: pointer;
  transition: all 0.2s ease;
}

.filter-btn:hover {
  background: #e2e8f0;
}

.filter-btn.active {
  color: white;
  border-color: transparent;
}

.filter-btn.status-pending.active {
  background: #f59e0b;
}

.filter-btn.status-approved.active {
  background: #10b981;
}

.filter-btn.status-in-progress.active {
  background: #3b82f6;
}

.filter-btn.status-completed.active {
  background: #10b981;
}

.filter-btn.status-cancelled.active {
  background: #6b7280;
}

.filter-btn.status-rejected.active {
  background: #ef4444;
}

.filter-btn.priority-high.active {
  background: #ef4444;
}

.filter-btn.priority-medium.active {
  background: #f59e0b;
}

.filter-btn.priority-low.active {
  background: #10b981;
}

.filter-count {
  background: rgba(255, 255, 255, 0.2);
  padding: 2px 6px;
  border-radius: 10px;
  font-size: 12px;
  font-weight: 600;
}

.sort-group {
  min-width: 200px;
}

.sort-select {
  width: 100%;
  padding: 10px 12px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 14px;
  color: #1e293b;
  background: white;
  cursor: pointer;
  transition: border-color 0.2s ease;
}

.sort-select:focus {
  outline: none;
  border-color: #4f46e5;
}

/* Активные фильтры */
.active-filters {
  padding-top: 16px;
  border-top: 1px solid #e2e8f0;
}

.active-filters-label {
  font-size: 14px;
  color: #64748b;
  margin-bottom: 8px;
}

.active-filters-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}

.active-filter-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: #e0e7ff;
  color: #4f46e5;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.active-filter-tag:hover {
  background: #c7d2fe;
}

.remove-tag {
  font-size: 16px;
  font-weight: bold;
  margin-left: 4px;
}

.clear-all-btn {
  padding: 6px 12px;
  background: none;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  color: #64748b;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.clear-all-btn:hover {
  background: #f1f5f9;
  color: #475569;
}

/* Загрузка и ошибка */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px;
  background: white;
  border-radius: 16px;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 4px solid #e0e7ff;
  border-top: 4px solid #4f46e5;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-container {
  text-align: center;
  padding: 40px;
  background: #fef2f2;
  border: 2px solid #fecaca;
  border-radius: 16px;
}

.error-icon {
  font-size: 48px;
  margin-bottom: 20px;
}

.error-container h3 {
  color: #dc2626;
  margin-bottom: 10px;
}

.error-container p {
  color: #991b1b;
  margin-bottom: 20px;
}

.retry-btn {
  background: #dc2626;
  color: white;
  border: none;
  padding: 10px 24px;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s ease;
}

.retry-btn:hover {
  background: #b91c1c;
}

/* Статистика */
.stats-summary {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.stat-item {
  text-align: center;
  padding: 16px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: #4f46e5;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #64748b;
}

/* Переключение вида */
.view-toggle {
  display: flex;
  gap: 8px;
  margin-bottom: 24px;
  padding: 8px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.view-btn {
  flex: 1;
  padding: 10px 16px;
  background: none;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 14px;
  color: #64748b;
  cursor: pointer;
  transition: all 0.2s ease;
}

.view-btn:hover {
  background: #f8fafc;
}

.view-btn.active {
  background: #4f46e5;
  color: white;
  border-color: #4f46e5;
}

/* Пустое состояние */
.empty-state {
  text-align: center;
  padding: 60px;
  background: white;
  border-radius: 16px;
  margin-bottom: 24px;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 20px;
  color: #cbd5e1;
}

.empty-state h3 {
  margin: 0 0 8px 0;
  color: #1e293b;
}

.empty-state p {
  margin: 0 0 24px 0;
  color: #64748b;
}

.empty-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
}

.empty-action-btn {
  padding: 10px 20px;
  background: #f1f5f9;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  color: #475569;
  text-decoration: none;
  font-size: 14px;
  transition: all 0.2s ease;
}

.empty-action-btn:hover {
  background: #e2e8f0;
}

.empty-action-btn.primary {
  background: #4f46e5;
  color: white;
  border-color: #4f46e5;
}

.empty-action-btn.primary:hover {
  background: #3730a3;
}

/* Вид списка */
.tasks-table {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.table-header {
  display: grid;
  grid-template-columns: 2fr 1fr 0.8fr 1fr 1fr 0.8fr;
  padding: 16px 20px;
  background: #f8fafc;
  border-bottom: 2px solid #e2e8f0;
  font-weight: 600;
  color: #475569;
  font-size: 14px;
}

.table-cell {
  padding: 8px;
}

.table-row {
  display: grid;
  grid-template-columns: 2fr 1fr 0.8fr 1fr 1fr 0.8fr;
  padding: 20px;
  border-bottom: 1px solid #e2e8f0;
  transition: background 0.2s ease;
}

.table-row:hover {
  background: #f8fafc;
}

.table-row:last-child {
  border-bottom: none;
}

.task-title-wrapper {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.task-title-link {
  color: #1e293b;
  text-decoration: none;
  font-weight: 500;
  transition: color 0.2s ease;
}

.task-title-link:hover {
  color: #4f46e5;
}

.task-description {
  margin: 0;
  color: #64748b;
  font-size: 14px;
  line-height: 1.4;
}

.task-meta {
  display: flex;
  gap: 16px;
  font-size: 12px;
  color: #94a3b8;
}

.task-id {
  font-weight: 600;
  color: #4f46e5;
}

.task-status-badge {
  display: inline-block;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  margin-bottom: 8px;
}

.task-status-badge.status-pending {
  background: #fef3c7;
  color: #92400e;
}

.task-status-badge.status-in-progress {
  background: #dbeafe;
  color: #1e40af;
}

.task-status-badge.status-completed {
  background: #d1fae5;
  color: #065f46;
}

.task-status-badge.status-cancelled {
  background: #f1f5f9;
  color: #64748b;
}

.task-status-badge.status-approved {
  background: #dcfce7;
  color: #166534;
}

.task-status-badge.status-rejected {
  background: #fee2e2;
  color: #991b1b;
}

.task-updated {
  font-size: 12px;
  color: #94a3b8;
}

.task-priority-badge {
  display: inline-block;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
}

.task-priority-badge.priority-high {
  background: #fee2e2;
  color: #991b1b;
}

.task-priority-badge.priority-medium {
  background: #fef3c7;
  color: #92400e;
}

.task-priority-badge.priority-low {
  background: #d1fae5;
  color: #065f46;
}

.deadline-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.deadline-date {
  font-weight: 500;
  color: #1e293b;
}

.deadline-empty {
  color: #94a3b8;
  font-style: italic;
}

.deadline-warning {
  font-size: 12px;
  color: #dc2626;
  font-weight: 500;
}

.project-link {
  color: #4f46e5;
  text-decoration: none;
  font-weight: 500;
  transition: color 0.2s ease;
}

.project-link:hover {
  color: #3730a3;
}

.no-project {
  color: #94a3b8;
  font-style: italic;
}

.task-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.action-btn.view-btn {
  background: #e0e7ff;
  color: #4f46e5;
}

.action-btn.view-btn:hover {
  background: #c7d2fe;
}

.action-btn.edit-btn {
  background: #fef3c7;
  color: #92400e;
}

.action-btn.edit-btn:hover {
  background: #fde68a;
}

.action-btn.cancel-btn {
  background: #fee2e2;
  color: #991b1b;
}

.action-btn.cancel-btn:hover {
  background: #fecaca;
}

.action-btn.attachments-btn {
  background: #f1f5f9;
  color: #475569;
}

.action-btn.attachments-btn:hover {
  background: #e2e8f0;
}

/* Вид сетки */
.tasks-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.task-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  display: flex;
  flex-direction: column;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.task-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.task-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-bottom: 1px solid #e2e8f0;
}

.task-card-priority {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 600;
}

.task-card-priority.priority-high {
  background: #fee2e2;
  color: #991b1b;
}

.task-card-priority.priority-medium {
  background: #fef3c7;
  color: #92400e;
}

.task-card-priority.priority-low {
  background: #d1fae5;
  color: #065f46;
}

.task-card-status {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 600;
}

.task-card-status.status-pending {
  background: #fef3c7;
  color: #92400e;
}

.task-card-status.status-in-progress {
  background: #dbeafe;
  color: #1e40af;
}

.task-card-status.status-completed {
  background: #d1fae5;
  color: #065f46;
}

.task-card-status.status-cancelled {
  background: #f1f5f9;
  color: #64748b;
}

.task-card-body {
  padding: 20px;
  flex: 1;
}

.task-card-title {
  margin: 0 0 12px 0;
  color: #1e293b;
  font-size: 16px;
}

.task-card-title-link {
  color: inherit;
  text-decoration: none;
}

.task-card-title-link:hover {
  color: #4f46e5;
}

.task-card-description {
  margin: 0 0 16px 0;
  color: #64748b;
  font-size: 14px;
  line-height: 1.5;
}

.task-card-meta {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #475569;
}

.meta-icon {
  font-size: 16px;
}

.deadline-warning-small {
  color: #dc2626;
  font-weight: bold;
}

.task-card-footer {
  padding: 16px 20px;
  border-top: 1px solid #e2e8f0;
  background: #f8fafc;
}

.task-card-actions {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}

.card-action-btn {
  flex: 1;
  padding: 8px 12px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.card-action-btn.view {
  background: #4f46e5;
  color: white;
}

.card-action-btn.view:hover {
  background: #3730a3;
}

.card-action-btn.edit {
  background: #f1f5f9;
  color: #475569;
  border: 1px solid #e2e8f0;
}

.card-action-btn.edit:hover {
  background: #e2e8f0;
}

.task-card-info {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #94a3b8;
}

/* Канбан доска */
.kanban-board {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}

.kanban-column {
  background: #f8fafc;
  border-radius: 12px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  max-height: 700px;
}

.kanban-column-header {
  padding: 16px;
  color: white;
  font-weight: 600;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.kanban-column-header.kanban-pending {
  background: #f59e0b;
}

.kanban-column-header.kanban-approved {
  background: #10b981;
}

.kanban-column-header.kanban-in-progress {
  background: #3b82f6;
}

.kanban-column-header.kanban-completed {
  background: #10b981;
}

.column-title {
  margin: 0;
  font-size: 16px;
}

.column-count {
  background: rgba(255, 255, 255, 0.2);
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
}

.kanban-column-body {
  padding: 16px;
  flex: 1;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.kanban-task {
  background: white;
  border-radius: 8px;
  padding: 16px;
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.kanban-task:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.kanban-task-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.kanban-task-priority {
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 10px;
  font-weight: 600;
}

.kanban-task-priority.priority-high {
  background: #fee2e2;
  color: #991b1b;
}

.kanban-task-priority.priority-medium {
  background: #fef3c7;
  color: #92400e;
}

.kanban-task-priority.priority-low {
  background: #d1fae5;
  color: #065f46;
}

.kanban-task-id {
  font-size: 12px;
  color: #94a3b8;
  font-weight: 600;
}

.kanban-task-title {
  margin: 0 0 8px 0;
  color: #1e293b;
  font-size: 14px;
  font-weight: 500;
}

.kanban-task-meta {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-size: 12px;
  color: #64748b;
}

.kanban-empty {
  text-align: center;
  padding: 40px 20px;
  color: #94a3b8;
  font-style: italic;
}

/* Пагинация */
.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: white;
  border-radius: 12px;
  margin-top: 24px;
}

.pagination-btn {
  padding: 10px 16px;
  background: #f1f5f9;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  color: #475569;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.pagination-btn:hover:not(:disabled) {
  background: #e2e8f0;
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.pagination-pages {
  display: flex;
  gap: 8px;
  align-items: center;
}

.pagination-page {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f1f5f9;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  color: #475569;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.pagination-page:hover {
  background: #e2e8f0;
}

.pagination-page.active {
  background: #4f46e5;
  color: white;
  border-color: #4f46e5;
}

.pagination-ellipsis {
  color: #94a3b8;
  padding: 0 8px;
}

.pagination-info {
  font-size: 14px;
  color: #64748b;
}

/* Экспорт */
.export-section {
  display: flex;
  gap: 12px;
  justify-content: center;
  margin-top: 24px;
}

.export-btn {
  padding: 12px 24px;
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  color: #475569;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.export-btn:hover {
  background: #f8fafc;
  border-color: #4f46e5;
  color: #4f46e5;
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
  padding: 20px;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal-content {
  background: white;
  border-radius: 16px;
  max-width: 500px;
  width: 100%;
  max-height: 90vh;
  overflow: hidden;
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from { transform: translateY(20px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #e2e8f0;
}

.modal-title {
  margin: 0;
  color: #1e293b;
  font-size: 20px;
}

.modal-close-btn {
  background: none;
  border: none;
  font-size: 24px;
  color: #64748b;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
}

.modal-close-btn:hover {
  background: #f1f5f9;
  color: #475569;
}

.modal-body {
  padding: 20px;
}

.modal-warning {
  color: #dc2626;
  font-weight: 500;
  margin: 16px 0;
}

.cancel-reason {
  margin-top: 20px;
}

.cancel-reason-label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #1e293b;
}

.cancel-reason-input {
  width: 100%;
  padding: 12px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 14px;
  font-family: inherit;
  resize: vertical;
  transition: border-color 0.2s ease;
}

.cancel-reason-input:focus {
  outline: none;
  border-color: #4f46e5;
}

.modal-actions {
  display: flex;
  gap: 12px;
  padding: 20px;
  border-top: 1px solid #e2e8f0;
}

.modal-btn {
  flex: 1;
  padding: 12px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.modal-btn.secondary {
  background: #f1f5f9;
  color: #475569;
}

.modal-btn.secondary:hover {
  background: #e2e8f0;
}

.modal-btn.danger {
  background: #dc2626;
  color: white;
}

.modal-btn.danger:hover {
  background: #b91c1c;
}

/* Адаптивность */
@media (max-width: 1024px) {
  .tasks-table,
  .table-header,
  .table-row {
    grid-template-columns: 1fr;
  }
  
  .table-cell {
    border-bottom: 1px solid #e2e8f0;
    padding: 12px 0;
  }
  
  .table-cell:last-child {
    border-bottom: none;
  }
  
  .table-header {
    display: none;
  }
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }
  
  .header-actions {
    width: 100%;
    flex-direction: column;
  }
  
  .create-task-btn,
  .back-to-dashboard-btn {
    width: 100%;
    justify-content: center;
  }
  
  .filters-row {
    flex-direction: column;
  }
  
  .filter-group {
    min-width: 100%;
  }
  
  .kanban-board {
    grid-template-columns: 1fr;
  }
  
  .pagination {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }
  
  .export-section {
    flex-direction: column;
  }
  
  .modal-actions {
    flex-direction: column;
  }
}

@media print {
  .page-header,
  .breadcrumbs,
  .filters-section,
  .view-toggle,
  .pagination,
  .export-section {
    display: none;
  }
  
  .task-card,
  .table-row {
    break-inside: avoid;
  }
}
</style>