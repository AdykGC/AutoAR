<template>
  <div class="dashboard-client-page">
    <!-- Заголовок с приветствием -->
    <div class="dashboard-header">
      <div class="welcome-section">
        <h1>👋 Добро пожаловать, {{ userName }}!</h1>
        <p class="welcome-text">Здесь вы можете управлять своими задачами и проектами</p>
      </div>
      <div class="user-info-badge">
        <div class="user-avatar">👤</div>
        <div class="user-details">
          <div class="user-name-small">{{ userData?.name || 'Клиент' }}</div>
          <div class="user-role">{{ userRole }}</div>
          <div class="user-since">С {{ userSince }}</div>
        </div>
      </div>
    </div>

    <!-- Индикатор загрузки -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>Загрузка данных...</p>
    </div>

    <!-- Ошибка загрузки -->
    <div v-else-if="error" class="error-container">
      <div class="error-icon">⚠️</div>
      <h3>Ошибка загрузки данных</h3>
      <p>{{ error }}</p>
      <button @click="loadDashboardData" class="retry-btn">Повторить попытку</button>
    </div>

    <!-- Основной контент -->
    <div v-else class="dashboard-content">
      <!-- Карточки статистики -->
      <div class="stats-section">
        <h2>📊 Ваша статистика</h2>
        <div class="stats-grid">
          <div class="stat-card" :class="getStatCardClass('total')">
            <div class="stat-icon">📋</div>
            <div class="stat-content">
              <div class="stat-title">Всего задач</div>
              <div class="stat-value">{{ dashboardData?.overview?.total_tasks || 0 }}</div>
              <div class="stat-subtitle">за все время</div>
            </div>
          </div>

          <div class="stat-card" :class="getStatCardClass('active')">
            <div class="stat-icon">⚡</div>
            <div class="stat-content">
              <div class="stat-title">В работе</div>
              <div class="stat-value">{{ dashboardData?.overview?.in_progress_tasks || 0 }}</div>
              <div class="stat-subtitle">активных сейчас</div>
            </div>
          </div>

          <div class="stat-card" :class="getStatCardClass('completed')">
            <div class="stat-icon">✅</div>
            <div class="stat-content">
              <div class="stat-title">Завершено</div>
              <div class="stat-value">{{ dashboardData?.overview?.completed_tasks || 0 }}</div>
              <div class="stat-subtitle">успешно выполнено</div>
            </div>
          </div>

          <div class="stat-card" :class="getStatCardClass('pending')">
            <div class="stat-icon">⏳</div>
            <div class="stat-content">
              <div class="stat-title">Ожидают</div>
              <div class="stat-value">{{ dashboardData?.overview?.pending_tasks || 0 }}</div>
              <div class="stat-subtitle">на рассмотрении</div>
            </div>
          </div>
        </div>

        <!-- Прогресс выполнения -->
        <div class="progress-section" v-if="dashboardData?.overview">
          <div class="progress-header">
            <span class="progress-title">Процент выполнения: {{ dashboardData.overview.completion_rate || 0 }}%</span>
            <span class="progress-value">{{ dashboardData.overview.completed_tasks || 0 }}/{{ dashboardData.overview.total_tasks || 0 }}</span>
          </div>
          <div class="progress-bar">
            <div class="progress-fill" :style="{ width: (dashboardData.overview.completion_rate || 0) + '%' }"></div>
          </div>
        </div>
      </div>

      <!-- Быстрые действия -->
      <div class="actions-section">
        <h2>🚀 Быстрые действия</h2>
        <div class="actions-grid">
          <router-link to="/client-tasks/my" class="action-card">
            <div class="action-icon">📋</div>
            <div class="action-content">
              <h3>Мои задачи</h3>
              <p>Просмотр и управление вашими задачами</p>
            </div>
            <div class="action-arrow">→</div>
          </router-link>

          <router-link to="/client-tasks/create" class="action-card">
            <div class="action-icon">➕</div>
            <div class="action-content">
              <h3>Создать задачу</h3>
              <p>Отправить новую задачу на выполнение</p>
            </div>
            <div class="action-arrow">→</div>
          </router-link>

          <router-link to="/projects" class="action-card">
            <div class="action-icon">📁</div>
            <div class="action-content">
              <h3>Мои проекты</h3>
              <p>Все проекты, связанные с вашими задачами</p>
            </div>
            <div class="action-arrow">→</div>
          </router-link>

          <router-link to="/profile" class="action-card">
            <div class="action-icon">👤</div>
            <div class="action-content">
              <h3>Мой профиль</h3>
              <p>Управление личной информацией</p>
            </div>
            <div class="action-arrow">→</div>
          </router-link>
        </div>
      </div>

      <!-- Последние обновления задач -->
      <div class="recent-tasks-section">
        <div class="section-header">
          <h2>🔄 Последние обновления</h2>
          <router-link to="/client-tasks/my" class="view-all-link">
            Все задачи ({{ dashboardData?.overview?.total_tasks || 0 }}) →
          </router-link>
        </div>
        
        <div v-if="dashboardData?.recent_updates?.length > 0" class="tasks-list">
          <div v-for="task in dashboardData.recent_updates" :key="task.id" class="task-item">
            <div class="task-priority" :class="getPriorityClass(task.priority)">
              {{ getPriorityText(task.priority) }}
            </div>
            <div class="task-content">
              <div class="task-header">
                <h4 class="task-title">{{ task.title }}</h4>
                <div class="task-status" :class="getTaskStatusClass(task.status)">
                  {{ getStatusText(task.status) }}
                </div>
              </div>
              
              <div class="task-meta">
                <span class="task-updated">
                  📅 Обновлено: {{ formatDate(task.updated_at) }}
                </span>
                <span class="task-deadline" v-if="task.deadline">
                  ⏰ Дедлайн: {{ formatDeadline(task.deadline) }}
                </span>
                <span class="task-budget" v-if="task.budget">
                  💰 {{ formatCurrency(task.budget) }}
                </span>
              </div>
            </div>
            <div class="task-actions">
              <router-link :to="`/client-tasks/${task.id}`" class="task-view-btn">
                Просмотр →
              </router-link>
            </div>
          </div>
        </div>
        
        <div v-else class="empty-state">
          <div class="empty-icon">📝</div>
          <h3>Нет обновлений задач</h3>
          <p>У вас пока нет задач или обновлений</p>
          <router-link to="/client-tasks/create" class="empty-action-btn">
            ➕ Создать первую задачу
          </router-link>
        </div>
      </div>

      <!-- Активные проекты -->
      <div class="projects-section">
        <div class="section-header">
          <h2>🏢 Активные проекты</h2>
          <router-link to="/projects" class="view-all-link">
            Все проекты ({{ dashboardData?.active_projects?.length || 0 }}) →
          </router-link>
        </div>
        
        <div v-if="dashboardData?.active_projects?.length > 0" class="projects-grid">
          <div v-for="project in dashboardData.active_projects" :key="project.id" class="project-card">
            <div class="project-header">
              <div class="project-icon">📁</div>
              <div class="project-info">
                <h3 class="project-title">{{ project.name }}</h3>
                <div class="project-status" :class="getProjectStatusClass(project.status)">
                  {{ getProjectStatusText(project.status) }}
                </div>
              </div>
            </div>
            
            <div class="project-description" v-if="project.description">
              {{ truncateText(project.description, 120) }}
            </div>
            
            <div class="project-meta">
              <div class="meta-item" v-if="project.deadline">
                <span class="meta-icon">📅</span>
                <span class="meta-text">Дедлайн: {{ formatDate(project.deadline) }}</span>
              </div>
              
              <div class="meta-item" v-if="project.team">
                <span class="meta-icon">👥</span>
                <span class="meta-text">Команда: {{ project.team.name }}</span>
              </div>
            </div>
            
            <!-- Задачи проекта -->
            <div class="project-tasks" v-if="project.project_tasks?.length > 0">
              <div class="tasks-title">Активные задачи:</div>
              <div class="task-items">
                <div v-for="task in project.project_tasks.slice(0, 2)" :key="task.id" class="project-task-item">
                  <span class="task-bullet">•</span>
                  <span class="task-name">{{ task.title }}</span>
                  <span class="task-status-small" :class="getTaskStatusClass(task.status)">
                    {{ getStatusText(task.status) }}
                  </span>
                </div>
                <div v-if="project.project_tasks.length > 2" class="more-tasks">
                  + ещё {{ project.project_tasks.length - 2 }} задач
                </div>
              </div>
            </div>
            
            <div class="project-actions">
              <router-link :to="`/projects/${project.id}`" class="project-view-btn">
                Открыть проект
              </router-link>
              <router-link :to="`/client-tasks/create?project_id=${project.id}`" 
                          class="project-add-task-btn">
                ➕ Добавить задачу
              </router-link>
            </div>
          </div>
        </div>
        
        <div v-else class="empty-state">
          <div class="empty-icon">📁</div>
          <h3>Нет активных проектов</h3>
          <p>Ваши задачи пока не связаны с проектами</p>
        </div>
      </div>

      <!-- Предстоящие дедлайны -->
      <div class="deadlines-section" v-if="dashboardData?.upcoming_deadlines?.length > 0">
        <div class="section-header">
          <h2>⏰ Предстоящие дедлайны</h2>
          <span class="deadlines-count">{{ dashboardData.upcoming_deadlines.length }} задач</span>
        </div>
        
        <div class="deadlines-list">
          <div v-for="task in dashboardData.upcoming_deadlines.slice(0, 3)" :key="task.id" 
               class="deadline-item" :class="getDeadlineClass(task.deadline)">
            <div class="deadline-date">
              <div class="date-day">{{ getDay(task.deadline) }}</div>
              <div class="date-month">{{ getMonth(task.deadline) }}</div>
            </div>
            <div class="deadline-info">
              <h4 class="deadline-title">{{ task.title }}</h4>
              <div class="deadline-meta">
                <span class="deadline-project" v-if="task.project_id">Проект #{{ task.project_id }}</span>
                <span class="deadline-time-left">
                  {{ getTimeLeft(task.deadline) }}
                </span>
              </div>
            </div>
            <div class="deadline-actions">
              <router-link :to="`/client-tasks/${task.id}`" class="deadline-view-btn">
                →
              </router-link>
            </div>
          </div>
        </div>
        
        <router-link v-if="dashboardData.upcoming_deadlines.length > 3" 
                    to="/client-tasks/my?filter=upcoming" 
                    class="view-more-deadlines">
          Показать все {{ dashboardData.upcoming_deadlines.length }} дедлайнов →
        </router-link>
      </div>

      <!-- Отладочная информация -->
      <div v-if="showDebug" class="debug-section">
        <h3 @click="toggleDebug" style="cursor: pointer">🔧 Отладочная информация</h3>
        <div v-if="debugExpanded">
          <pre>{{ debugInfo }}</pre>
          <div class="debug-actions">
            <button @click="refreshDashboard" class="debug-btn">
              🔄 Обновить данные
            </button>
            <button @click="loadTestData" class="debug-btn">
              🧪 Загрузить тестовые данные
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import authService from '@/services/auth.service'
import dashboardService from '@/services/dashboard.service'

export default {
  name: 'DashboardClientPage',
  
  setup() {
    const loading = ref(true)
    const error = ref(null)
    const dashboardData = ref(null)
    const debugExpanded = ref(false)
    const showDebug = ref(process.env.NODE_ENV === 'development')

    // Получение данных пользователя
    const userData = computed(() => authService.getUserData())
    const userRole = computed(() => authService.getUserRole())

    // Форматированные данные пользователя
    const userName = computed(() => {
      const user = userData.value
      return user ? `${user.name} ${user.surname}` : 'Клиент'
    })

    const userSince = computed(() => {
      return userData.value?.created_at 
        ? new Date(userData.value.created_at).toLocaleDateString('ru-RU')
        : 'недавно'
    })

    // Отладочная информация
    const debugInfo = computed(() => ({
      loading: loading.value,
      error: error.value,
      dashboardData: dashboardData.value,
      userData: userData.value,
      userRole: userRole.value,
      timestamp: new Date().toISOString()
    }))

    // Метод загрузки данных
    const loadDashboardData = async () => {
      try {
        loading.value = true
        error.value = null
        console.log('🔄 Загрузка данных дашборда клиента...')
        
        const response = await dashboardService.getClientDashboard()
        
        if (response.success && response.data) {
          dashboardData.value = response.data
          console.log('✅ Данные дашборда загружены:', dashboardData.value)
        } else {
          throw new Error(response.message || 'Неверный формат ответа')
        }
      } catch (err) {
        console.error('❌ Ошибка загрузки дашборда:', err)
        error.value = err.message || 'Не удалось загрузить данные дашборда'
        
        // Загружаем тестовые данные при ошибке
        loadTestData()
      } finally {
        loading.value = false
      }
    }

    // Тестовые данные
    const loadTestData = () => {
      console.log('🧪 Загрузка тестовых данных...')
      dashboardData.value = {
        overview: {
          total_tasks: 8,
          completed_tasks: 3,
          in_progress_tasks: 3,
          pending_tasks: 2,
          completion_rate: 37.5
        },
        recent_updates: [
          {
            id: 1,
            title: 'Разработка лендинга для компании',
            status: 'in_progress',
            priority: 'high',
            budget: 150000,
            deadline: '2024-12-25',
            updated_at: '2024-12-10T10:30:00Z'
          },
          {
            id: 2,
            title: 'Дизайн мобильного приложения',
            status: 'pending',
            priority: 'medium',
            budget: 200000,
            deadline: '2024-12-20',
            updated_at: '2024-12-09T14:20:00Z'
          },
          {
            id: 3,
            title: 'Оптимизация SEO сайта',
            status: 'completed',
            priority: 'low',
            budget: 80000,
            deadline: '2024-12-05',
            updated_at: '2024-12-01T09:15:00Z'
          }
        ],
        active_projects: [
          {
            id: 1,
            name: 'Веб-разработка',
            description: 'Разработка и поддержка веб-сайтов для различных клиентов',
            status: 'active',
            deadline: '2024-12-31',
            team: { id: 1, name: 'Веб-команда' },
            project_tasks: [
              { id: 1, title: 'Разработка лендинга', status: 'in_progress' },
              { id: 4, title: 'Интеграция платежной системы', status: 'pending' },
              { id: 5, title: 'Тестирование сайта', status: 'in_progress' }
            ]
          },
          {
            id: 2,
            name: 'Мобильная разработка',
            description: 'Создание мобильных приложений для iOS и Android',
            status: 'active',
            deadline: '2024-12-28',
            team: { id: 2, name: 'Мобильная команда' },
            project_tasks: [
              { id: 2, title: 'Дизайн мобильного приложения', status: 'pending' }
            ]
          }
        ],
        upcoming_deadlines: [
          {
            id: 1,
            title: 'Разработка лендинга для компании',
            deadline: '2024-12-25',
            project_id: 1
          },
          {
            id: 2,
            title: 'Дизайн мобильного приложения',
            deadline: '2024-12-20',
            project_id: 2
          },
          {
            id: 6,
            title: 'Настройка серверов',
            deadline: '2024-12-22',
            project_id: 1
          }
        ]
      }
    }

    // Вспомогательные методы
    const getStatCardClass = (type) => {
      const classes = {
        total: 'stat-total',
        active: 'stat-active',
        completed: 'stat-completed',
        pending: 'stat-pending'
      }
      return classes[type] || ''
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

    const getProjectStatusClass = (status) => {
      const classes = {
        'planning': 'status-planning',
        'active': 'status-active',
        'on_hold': 'status-on-hold',
        'completed': 'status-completed',
        'cancelled': 'status-cancelled'
      }
      return classes[status] || 'status-unknown'
    }

    const getProjectStatusText = (status) => {
      const texts = {
        'planning': 'Планирование',
        'active': 'Активен',
        'on_hold': 'Приостановлен',
        'completed': 'Завершен',
        'cancelled': 'Отменен'
      }
      return texts[status] || status
    }

    const formatDate = (dateString) => {
      if (!dateString) return 'Дата не указана'
      try {
        const date = new Date(dateString)
        return date.toLocaleDateString('ru-RU', {
          day: 'numeric',
          month: 'long',
          year: 'numeric'
        })
      } catch {
        return dateString
      }
    }

    const formatDeadline = (dateString) => {
      if (!dateString) return 'Не указано'
      try {
        const date = new Date(dateString)
        const today = new Date()
        const diffTime = date - today
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
        
        if (diffDays < 0) return 'Просрочено'
        if (diffDays === 0) return 'Сегодня'
        if (diffDays === 1) return 'Завтра'
        if (diffDays < 7) return `Через ${diffDays} дня`
        if (diffDays < 30) return `Через ${Math.floor(diffDays / 7)} недели`
        return formatDate(dateString)
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

    const getDeadlineClass = (deadline) => {
      if (!deadline) return 'deadline-far'
      
      try {
        const date = new Date(deadline)
        const today = new Date()
        const diffTime = date - today
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
        
        if (diffDays < 0) return 'deadline-overdue'
        if (diffDays <= 1) return 'deadline-urgent'
        if (diffDays <= 3) return 'deadline-soon'
        return 'deadline-far'
      } catch {
        return 'deadline-far'
      }
    }

    const getDay = (dateString) => {
      if (!dateString) return '?'
      try {
        const date = new Date(dateString)
        return date.getDate().toString().padStart(2, '0')
      } catch {
        return '??'
      }
    }

    const getMonth = (dateString) => {
      if (!dateString) return '???'
      try {
        const date = new Date(dateString)
        const months = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
        return months[date.getMonth()]
      } catch {
        return '???'
      }
    }

    const getTimeLeft = (deadline) => {
      if (!deadline) return 'Нет дедлайна'
      
      try {
        const date = new Date(deadline)
        const today = new Date()
        const diffTime = date - today
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
        
        if (diffDays < 0) return 'Просрочено'
        if (diffDays === 0) return 'Сегодня'
        if (diffDays === 1) return 'Завтра'
        if (diffDays < 7) return `Осталось ${diffDays} дней`
        if (diffDays < 30) return `Осталось ${Math.floor(diffDays / 7)} недель`
        return '> 1 месяца'
      } catch {
        return deadline
      }
    }

    const toggleDebug = () => {
      debugExpanded.value = !debugExpanded.value
    }

    const refreshDashboard = () => {
      loadDashboardData()
    }

    // Загрузка при монтировании
    onMounted(() => {
      console.log('🚀 DashboardClientPage mounted')
      loadDashboardData()
    })

    return {
      // Состояние
      loading,
      error,
      dashboardData,
      debugExpanded,
      showDebug,
      
      // Данные
      userData,
      userRole,
      userName,
      userSince,
      debugInfo,
      
      // Методы
      loadDashboardData,
      getStatCardClass,
      getTaskStatusClass,
      getStatusText,
      getPriorityClass,
      getPriorityText,
      getProjectStatusClass,
      getProjectStatusText,
      formatDate,
      formatDeadline,
      formatCurrency,
      truncateText,
      getDeadlineClass,
      getDay,
      getMonth,
      getTimeLeft,
      toggleDebug,
      refreshDashboard
    }
  }
}
</script>

<style scoped>
/* Основные стили */
.dashboard-client-page {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
  background: #f8fafc;
  min-height: 100vh;
}

/* Заголовок */
.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
  padding: 24px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.welcome-section h1 {
  margin: 0 0 8px 0;
  color: #1e293b;
  font-size: 28px;
}

.welcome-text {
  margin: 0;
  color: #64748b;
  font-size: 16px;
}

.user-info-badge {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: #f1f5f9;
  border-radius: 12px;
  min-width: 200px;
}

.user-avatar {
  font-size: 32px;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: white;
  border-radius: 12px;
}

.user-details {
  flex: 1;
}

.user-name-small {
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 4px;
}

.user-role {
  font-size: 14px;
  color: #4f46e5;
  background: #e0e7ff;
  padding: 4px 8px;
  border-radius: 6px;
  display: inline-block;
}

.user-since {
  font-size: 12px;
  color: #64748b;
  margin-top: 4px;
}

/* Загрузка */
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

/* Ошибка */
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

/* Секции */
.stats-section,
.actions-section,
.recent-tasks-section,
.projects-section,
.deadlines-section,
.debug-section {
  background: white;
  padding: 24px;
  border-radius: 16px;
  margin-bottom: 24px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 15px;
  border-bottom: 1px solid #e2e8f0;
}

.section-header h2 {
  margin: 0;
  color: #1e293b;
  font-size: 20px;
}

.view-all-link {
  color: #4f46e5;
  text-decoration: none;
  font-weight: 500;
  transition: color 0.2s ease;
}

.view-all-link:hover {
  color: #3730a3;
}

/* Карточки статистики */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 20px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.stat-card.stat-total {
  border-left: 4px solid #4f46e5;
}

.stat-card.stat-active {
  border-left: 4px solid #3b82f6;
}

.stat-card.stat-completed {
  border-left: 4px solid #10b981;
}

.stat-card.stat-pending {
  border-left: 4px solid #f59e0b;
}

.stat-icon {
  font-size: 32px;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f1f5f9;
  border-radius: 10px;
}

.stat-content {
  flex: 1;
}

.stat-title {
  font-size: 14px;
  color: #64748b;
  margin-bottom: 4px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  color: #1e293b;
  margin-bottom: 2px;
}

.stat-subtitle {
  font-size: 12px;
  color: #94a3b8;
}

/* Прогресс выполнения */
.progress-section {
  margin-top: 24px;
  padding: 16px;
  background: #f8fafc;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.progress-title {
  font-weight: 500;
  color: #1e293b;
}

.progress-value {
  font-weight: 600;
  color: #4f46e5;
}

.progress-bar {
  height: 8px;
  background: #e2e8f0;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #4f46e5, #7c3aed);
  border-radius: 4px;
  transition: width 0.5s ease;
}

/* Быстрые действия */
.actions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}

.action-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: #f8fafc;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  text-decoration: none;
  color: inherit;
  transition: all 0.2s ease;
}

.action-card:hover {
  background: white;
  border-color: #4f46e5;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(79, 70, 229, 0.1);
}

.action-icon {
  font-size: 32px;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: white;
  border-radius: 10px;
}

.action-content {
  flex: 1;
}

.action-content h3 {
  margin: 0 0 8px 0;
  color: #1e293b;
  font-size: 16px;
}

.action-content p {
  margin: 0;
  color: #64748b;
  font-size: 14px;
  line-height: 1.4;
}

.action-arrow {
  color: #94a3b8;
  font-size: 20px;
}

/* Список задач */
.tasks-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.task-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  transition: background 0.2s ease;
}

.task-item:hover {
  background: #f8fafc;
}

.task-priority {
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
  min-width: 80px;
  text-align: center;
}

.task-priority.priority-high {
  background: #fee2e2;
  color: #991b1b;
}

.task-priority.priority-medium {
  background: #fef3c7;
  color: #92400e;
}

.task-priority.priority-low {
  background: #d1fae5;
  color: #065f46;
}

.task-content {
  flex: 1;
}

.task-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.task-title {
  margin: 0;
  color: #1e293b;
  font-size: 16px;
  font-weight: 500;
}

.task-status {
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
  min-width: 70px;
  text-align: center;
}

.task-status.status-pending {
  background: #fef3c7;
  color: #92400e;
}

.task-status.status-in-progress {
  background: #dbeafe;
  color: #1e40af;
}

.task-status.status-completed {
  background: #d1fae5;
  color: #065f46;
}

.task-status.status-cancelled {
  background: #f1f5f9;
  color: #64748b;
}

.task-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  font-size: 14px;
  color: #64748b;
}

.task-actions {
  display: flex;
  align-items: center;
}

.task-view-btn {
  color: #4f46e5;
  text-decoration: none;
  font-weight: 500;
  padding: 8px 16px;
  border-radius: 8px;
  border: 1px solid #4f46e5;
  transition: all 0.2s ease;
}

.task-view-btn:hover {
  background: #4f46e5;
  color: white;
}

/* Пустое состояние */
.empty-state {
  text-align: center;
  padding: 40px;
  border: 2px dashed #e2e8f0;
  border-radius: 12px;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.empty-state h3 {
  margin: 0 0 8px 0;
  color: #1e293b;
}

.empty-state p {
  margin: 0 0 20px 0;
  color: #64748b;
}

.empty-action-btn {
  display: inline-block;
  padding: 12px 24px;
  background: #4f46e5;
  color: white;
  text-decoration: none;
  border-radius: 8px;
  font-weight: 500;
  transition: background 0.2s ease;
}

.empty-action-btn:hover {
  background: #3730a3;
}

/* Карточки проектов */
.projects-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.project-card {
  padding: 20px;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.project-header {
  display: flex;
  align-items: center;
  gap: 16px;
}

.project-icon {
  font-size: 32px;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f1f5f9;
  border-radius: 10px;
}

.project-info {
  flex: 1;
}

.project-title {
  margin: 0 0 8px 0;
  color: #1e293b;
  font-size: 18px;
}

.project-status {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
}

.project-status.status-planning {
  background: #fef3c7;
  color: #92400e;
}

.project-status.status-active {
  background: #dbeafe;
  color: #1e40af;
}

.project-status.status-on_hold {
  background: #f1f5f9;
  color: #64748b;
}

.project-status.status-completed {
  background: #d1fae5;
  color: #065f46;
}

.project-description {
  color: #64748b;
  font-size: 14px;
  line-height: 1.5;
}

/* Мета-информация проекта */
.project-meta {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #64748b;
}

.meta-icon {
  font-size: 16px;
}

/* Задачи проекта */
.project-tasks {
  margin-top: 8px;
  padding: 12px;
  background: #f8fafc;
  border-radius: 8px;
}

.tasks-title {
  font-weight: 500;
  color: #1e293b;
  margin-bottom: 8px;
  font-size: 14px;
}

.task-items {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.project-task-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
}

.task-bullet {
  color: #4f46e5;
  font-weight: bold;
}

.task-name {
  flex: 1;
  color: #475569;
}

.task-status-small {
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;
}

.task-status-small.status-pending {
  background: #fef3c7;
  color: #92400e;
}

.task-status-small.status-in-progress {
  background: #dbeafe;
  color: #1e40af;
}

.task-status-small.status-completed {
  background: #d1fae5;
  color: #065f46;
}

.task-status-small.status-cancelled {
  background: #f1f5f9;
  color: #64748b;
}

.more-tasks {
  font-size: 12px;
  color: #94a3b8;
  text-align: center;
  margin-top: 4px;
}

/* Действия проекта */
.project-actions {
  display: flex;
  gap: 12px;
  margin-top: auto;
}

.project-view-btn,
.project-add-task-btn {
  flex: 1;
  text-align: center;
  padding: 10px;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.2s ease;
}

.project-view-btn {
  background: #4f46e5;
  color: white;
}

.project-view-btn:hover {
  background: #3730a3;
}

.project-add-task-btn {
  background: #f1f5f9;
  color: #4f46e5;
  border: 1px solid #e2e8f0;
}

.project-add-task-btn:hover {
  background: #e0e7ff;
}

/* Дедлайны */
.deadlines-count {
  background: #eef2ff;
  color: #4f46e5;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
}

.deadlines-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-top: 16px;
}

.deadline-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  transition: all 0.2s ease;
}

.deadline-item.deadline-overdue {
  border-color: #fecaca;
  background: #fef2f2;
}

.deadline-item.deadline-urgent {
  border-color: #fde68a;
  background: #fffbeb;
}

.deadline-item.deadline-soon {
  border-color: #fed7aa;
  background: #fff7ed;
}

.deadline-item.deadline-far {
  border-color: #e2e8f0;
  background: #f8fafc;
}

.deadline-date {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 50px;
}

.date-day {
  font-size: 24px;
  font-weight: 700;
  color: #1e293b;
}

.date-month {
  font-size: 12px;
  color: #64748b;
  text-transform: uppercase;
}

.deadline-info {
  flex: 1;
}

.deadline-title {
  font-weight: 500;
  color: #1e293b;
  margin-bottom: 4px;
}

.deadline-meta {
  display: flex;
  gap: 16px;
  font-size: 14px;
  color: #64748b;
}

.deadline-project {
  background: #eef2ff;
  color: #4f46e5;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.deadline-time-left {
  font-weight: 500;
}

.deadline-actions {
  display: flex;
  align-items: center;
}

.deadline-view-btn {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #4f46e5;
  color: white;
  text-decoration: none;
  border-radius: 8px;
  font-weight: bold;
  transition: background 0.2s ease;
}

.deadline-view-btn:hover {
  background: #3730a3;
}

.view-more-deadlines {
  display: block;
  text-align: center;
  margin-top: 16px;
  color: #4f46e5;
  text-decoration: none;
  font-weight: 500;
  padding: 12px;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  transition: all 0.2s ease;
}

.view-more-deadlines:hover {
  background: #eef2ff;
  border-color: #4f46e5;
}

/* Отладочная информация */
.debug-section {
  background: #f1f5f9;
  padding: 20px;
  border-radius: 12px;
  margin-top: 32px;
}

.debug-section h3 {
  margin: 0 0 16px 0;
  color: #475569;
}

.debug-section pre {
  background: white;
  padding: 16px;
  border-radius: 8px;
  overflow: auto;
  font-size: 12px;
  color: #334155;
  margin-bottom: 16px;
}

.debug-actions {
  display: flex;
  gap: 12px;
}

.debug-btn {
  flex: 1;
  padding: 10px 16px;
  background: #64748b;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.debug-btn:hover {
  background: #475569;
}

/* Адаптивность */
@media (max-width: 768px) {
  .dashboard-header {
    flex-direction: column;
    gap: 20px;
    text-align: center;
  }
  
  .user-info-badge {
    width: 100%;
  }
  
  .stats-grid,
  .actions-grid {
    grid-template-columns: 1fr;
  }
  
  .projects-grid {
    grid-template-columns: 1fr;
  }
  
  .task-item {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .task-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .task-meta {
    flex-direction: column;
    gap: 8px;
  }
  
  .deadline-item {
    flex-direction: column;
    align-items: stretch;
    text-align: center;
  }
  
  .deadline-date {
    align-self: center;
  }
  
  .deadline-meta {
    flex-direction: column;
    gap: 8px;
  }
  
  .project-actions {
    flex-direction: column;
  }
  
  .debug-actions {
    flex-direction: column;
  }
}
</style>