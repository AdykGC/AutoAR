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
              <div class="stat-value">{{ dashboardData?.stats?.total_tasks || 0 }}</div>
              <div class="stat-subtitle">за все время</div>
            </div>
          </div>

          <div class="stat-card" :class="getStatCardClass('active')">
            <div class="stat-icon">⚡</div>
            <div class="stat-content">
              <div class="stat-title">Активные</div>
              <div class="stat-value">{{ dashboardData?.stats?.in_progress_tasks || 0 }}</div>
              <div class="stat-subtitle">в работе сейчас</div>
            </div>
          </div>

          <div class="stat-card" :class="getStatCardClass('completed')">
            <div class="stat-icon">✅</div>
            <div class="stat-content">
              <div class="stat-title">Завершено</div>
              <div class="stat-value">{{ dashboardData?.stats?.completed_tasks || 0 }}</div>
              <div class="stat-subtitle">успешно выполнено</div>
            </div>
          </div>

          <div class="stat-card" :class="getStatCardClass('pending')">
            <div class="stat-icon">⏳</div>
            <div class="stat-content">
              <div class="stat-title">Ожидают</div>
              <div class="stat-value">{{ dashboardData?.stats?.pending_tasks || 0 }}</div>
              <div class="stat-subtitle">на рассмотрении</div>
            </div>
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

      <!-- Последние задачи -->
      <div class="recent-tasks-section" v-if="dashboardData?.recent_tasks?.length > 0">
        <div class="section-header">
          <h2>📝 Последние задачи</h2>
          <router-link to="/client-tasks/my" class="view-all-link">Все задачи →</router-link>
        </div>
        <div class="tasks-list">
          <div v-for="task in dashboardData.recent_tasks.slice(0, 5)" :key="task.id" class="task-item">
            <div class="task-status" :class="getTaskStatusClass(task.status)">
              {{ getStatusText(task.status) }}
            </div>
            <div class="task-content">
              <h4 class="task-title">{{ task.title }}</h4>
              <div class="task-meta">
                <span class="task-project" v-if="task.project">📁 {{ task.project.name }}</span>
                <span class="task-date">📅 {{ formatDate(task.created_at) }}</span>
              </div>
            </div>
            <router-link :to="`/client-tasks/${task.id}`" class="task-view-btn">
              Просмотр →
            </router-link>
          </div>
        </div>
      </div>

      <!-- Активные проекты -->
      <div class="projects-section" v-if="dashboardData?.active_projects?.length > 0">
        <div class="section-header">
          <h2>🏢 Активные проекты</h2>
          <router-link to="/projects" class="view-all-link">Все проекты →</router-link>
        </div>
        <div class="projects-grid">
          <div v-for="project in dashboardData.active_projects.slice(0, 3)" :key="project.id" class="project-card">
            <div class="project-header">
              <div class="project-icon">📁</div>
              <div class="project-info">
                <h3 class="project-title">{{ project.name }}</h3>
                <div class="project-status" :class="getProjectStatusClass(project.status)">
                  {{ getProjectStatusText(project.status) }}
                </div>
              </div>
            </div>
            <div class="project-description">
              {{ project.description || 'Описание проекта отсутствует' }}
            </div>
            <div class="project-stats">
              <div class="stat">
                <div class="stat-label">Задачи</div>
                <div class="stat-value">{{ project.tasks?.length || 0 }}</div>
              </div>
              <div class="stat">
                <div class="stat-label">Прогресс</div>
                <div class="stat-value">{{ project.progress || 0 }}%</div>
              </div>
            </div>
            <router-link :to="`/projects/${project.id}`" class="project-view-btn">
              Открыть проект
            </router-link>
          </div>
        </div>
      </div>

      <!-- Отладочная информация (только в development) -->
      <div v-if="showDebug" class="debug-section">
        <h3 @click="toggleDebug" style="cursor: pointer">🔧 Отладочная информация</h3>
        <div v-if="debugExpanded">
          <pre>{{ debugInfo }}</pre>
          <button @click="refreshDashboard" class="debug-btn">🔄 Обновить данные</button>
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
    const userToken = computed(() => authService.getToken())

    // Форматированные данные пользователя
    const userName = computed(() => {
      const user = userData.value
      return user ? `${user.name} ${user.surname}` : 'Клиент'
    })

    const userSince = computed(() => {
      if (dashboardData.value?.user?.created_at) {
        return dashboardData.value.user.created_at
      }
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
      token: userToken.value ? 'Присутствует' : 'Отсутствует'
    }))

    // Метод загрузки данных
    const loadDashboardData = async () => {
      try {
        loading.value = true
        error.value = null
        console.log('🔄 Загрузка данных дашборда...')
        
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
        
        // Если нет данных, используем тестовые
        if (!dashboardData.value) {
          dashboardData.value = {
            stats: {
              total_tasks: 0,
              pending_tasks: 0,
              in_progress_tasks: 0,
              completed_tasks: 0,
              cancelled_tasks: 0,
              avg_completion_hours: 0
            },
            active_projects: [],
            recent_tasks: [],
            user: {
              name: userName.value,
              role: userRole.value,
              created_at: userSince.value
            }
          }
        }
      } finally {
        loading.value = false
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
        'pending': 'Ожидает',
        'in_progress': 'В работе',
        'completed': 'Завершено',
        'cancelled': 'Отменено',
        'approved': 'Одобрено',
        'rejected': 'Отклонено'
      }
      return texts[status] || status
    }

    const getProjectStatusClass = (status) => {
      const classes = {
        'planning': 'status-planning',
        'in_progress': 'status-in-progress',
        'on_hold': 'status-on-hold',
        'completed': 'status-completed',
        'cancelled': 'status-cancelled'
      }
      return classes[status] || 'status-unknown'
    }

    const getProjectStatusText = (status) => {
      const texts = {
        'planning': 'Планирование',
        'in_progress': 'В работе',
        'on_hold': 'Приостановлен',
        'completed': 'Завершен',
        'cancelled': 'Отменен'
      }
      return texts[status] || status
    }

    const formatDate = (dateString) => {
      if (!dateString) return ''
      try {
        const date = new Date(dateString)
        return date.toLocaleDateString('ru-RU')
      } catch {
        return dateString
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
      getProjectStatusClass,
      getProjectStatusText,
      formatDate,
      toggleDebug,
      refreshDashboard
    }
  }
}
</script>

<style scoped>
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
.projects-section {
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
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
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

.task-status {
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
  min-width: 90px;
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

.task-status.status-approved {
  background: #dcfce7;
  color: #166534;
}

.task-status.status-rejected {
  background: #fee2e2;
  color: #991b1b;
}

.task-content {
  flex: 1;
}

.task-title {
  margin: 0 0 8px 0;
  color: #1e293b;
  font-size: 16px;
  font-weight: 500;
}

.task-meta {
  display: flex;
  gap: 16px;
  font-size: 14px;
  color: #64748b;
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

.project-status.status-in-progress {
  background: #dbeafe;
  color: #1e40af;
}

.project-status.status-on-hold {
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
  flex: 1;
}

.project-stats {
  display: flex;
  gap: 24px;
}

.project-stats .stat {
  text-align: center;
}

.project-stats .stat-label {
  font-size: 12px;
  color: #94a3b8;
  margin-bottom: 4px;
}

.project-stats .stat-value {
  font-size: 20px;
  font-weight: 700;
  color: #1e293b;
}

.project-view-btn {
  background: #4f46e5;
  color: white;
  text-decoration: none;
  text-align: center;
  padding: 12px;
  border-radius: 8px;
  font-weight: 500;
  transition: background 0.2s ease;
}

.project-view-btn:hover {
  background: #3730a3;
}

/* Отладочная секция */
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

.debug-btn {
  background: #64748b;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s ease;
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
  
  .task-status {
    align-self: flex-start;
  }
}
</style>