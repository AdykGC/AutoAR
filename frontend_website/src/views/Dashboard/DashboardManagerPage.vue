<template>
  <div class="dashboard-manager-page">
    <div class="dashboard-header">
      <h1>📊 Дашборд Менеджера</h1>
      <div class="user-info">
        <span class="user-role">👔 {{ userRole }}</span>
        <span class="user-name">{{ userName }}</span>
      </div>
    </div>
    
    <div class="debug-info">
      <h3>🔧 Информация о пользователе:</h3>
      <pre>{{ userInfo }}</pre>
    </div>
    
    <!-- Общая статистика -->
    <div class="section">
      <h2>📈 Общая статистика</h2>
      <div class="stats-grid">
        <div class="stat-card primary">
          <div class="stat-icon">📋</div>
          <div class="stat-content">
            <div class="stat-title">Всего задач</div>
            <div class="stat-value">47</div>
            <div class="stat-trend trend-up">📈 +12%</div>
          </div>
        </div>
        
        <div class="stat-card warning">
          <div class="stat-icon">⏳</div>
          <div class="stat-content">
            <div class="stat-title">Ожидают одобрения</div>
            <div class="stat-value">8</div>
            <div class="stat-trend trend-up">⚠️ Срочно</div>
          </div>
        </div>
        
        <div class="stat-card success">
          <div class="stat-icon">🏢</div>
          <div class="stat-content">
            <div class="stat-title">Активных проектов</div>
            <div class="stat-value">15</div>
            <div class="stat-trend trend-up">📈 +3</div>
          </div>
        </div>
        
        <div class="stat-card danger">
          <div class="stat-icon">🚨</div>
          <div class="stat-content">
            <div class="stat-title">Просрочено задач</div>
            <div class="stat-value">5</div>
            <div class="stat-trend trend-down">📉 -2</div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Блоки с важной информацией -->
    <div class="dashboard-content">
      <div class="left-column">
        <!-- Задачи, требующие внимания -->
        <div class="card urgent-tasks">
          <div class="card-header">
            <h3>🚨 Срочные задачи</h3>
            <span class="badge danger">5 задач</span>
          </div>
          <div class="task-list">
            <div class="task-item" v-for="task in urgentTasks" :key="task.id">
              <div class="task-priority" :class="task.priorityClass">
                {{ task.priority }}
              </div>
              <div class="task-info">
                <div class="task-title">{{ task.title }}</div>
                <div class="task-meta">
                  <span class="client">👤 {{ task.client }}</span>
                  <span class="deadline">📅 {{ task.deadline }}</span>
                </div>
              </div>
              <div class="task-actions">
                <button class="btn-sm btn-primary">Просмотр</button>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Команды -->
        <div class="card">
          <div class="card-header">
            <h3>👥 Мои команды</h3>
            <router-link to="/teams" class="btn-link">Все команды →</router-link>
          </div>
          <div class="teams-list">
            <div class="team-item" v-for="team in teams" :key="team.id">
              <div class="team-icon">👥</div>
              <div class="team-info">
                <div class="team-name">{{ team.name }}</div>
                <div class="team-meta">
                  <span class="members">👤 {{ team.members }} участников</span>
                  <span class="projects">📁 {{ team.projects }} проектов</span>
                </div>
              </div>
              <div class="team-stats">
                <div class="progress">
                  <div class="progress-bar" :style="{ width: team.progress + '%' }"></div>
                </div>
                <span class="progress-text">{{ team.progress }}% выполнено</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div class="right-column">
        <!-- Последние задачи клиентов -->
        <div class="card">
          <div class="card-header">
            <h3>🆕 Новые задачи от клиентов</h3>
            <router-link to="/client-tasks/pending" class="btn-link">Все новые →</router-link>
          </div>
          <div class="client-tasks">
            <div class="client-task" v-for="task in newClientTasks" :key="task.id">
              <div class="task-status" :class="task.statusClass">
                {{ task.status }}
              </div>
              <div class="task-details">
                <div class="task-title">{{ task.title }}</div>
                <div class="task-client">👤 {{ task.client }}</div>
                <div class="task-date">🕐 {{ task.createdAt }}</div>
              </div>
              <div class="task-actions">
                <button class="btn-sm btn-success" @click="approveTask(task.id)">✅</button>
                <button class="btn-sm btn-danger" @click="rejectTask(task.id)">❌</button>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Быстрые действия -->
        <div class="card quick-actions-card">
          <div class="card-header">
            <h3>⚡ Быстрые действия</h3>
          </div>
          <div class="actions-grid">
            <router-link to="/client-tasks/pending" class="action-btn">
              <div class="action-icon">✅</div>
              <div class="action-text">Одобрить задачи</div>
            </router-link>
            
            <router-link to="/projects/create" class="action-btn">
              <div class="action-icon">➕</div>
              <div class="action-text">Создать проект</div>
            </router-link>
            
            <router-link to="/teams/create" class="action-btn">
              <div class="action-icon">👥</div>
              <div class="action-text">Создать команду</div>
            </router-link>
            
            <router-link to="/reports" class="action-btn">
              <div class="action-icon">📊</div>
              <div class="action-text">Отчеты</div>
            </router-link>
            
            <router-link to="/project-tasks/assign" class="action-btn">
              <div class="action-icon">🎯</div>
              <div class="action-text">Назначить задачи</div>
            </router-link>
            
            <router-link to="/projects" class="action-btn">
              <div class="action-icon">📁</div>
              <div class="action-text">Все проекты</div>
            </router-link>
          </div>
        </div>
        
        <!-- Статистика по проектам -->
        <div class="card">
          <div class="card-header">
            <h3>📊 Статус проектов</h3>
          </div>
          <div class="project-stats">
            <div class="project-stat" v-for="stat in projectStats" :key="stat.status">
              <div class="stat-label">{{ stat.label }}</div>
              <div class="stat-bar">
                <div class="bar-fill" :style="{ width: stat.percentage + '%', backgroundColor: stat.color }"></div>
              </div>
              <div class="stat-value">{{ stat.count }} ({{ stat.percentage }}%)</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Уведомления и напоминания -->
    <div class="notifications">
      <div class="notification warning">
        ⚠️ 3 задачи требуют пересмотра приоритета
      </div>
      <div class="notification info">
        ℹ️ Завтра дедлайн по проекту "Разработка CRM"
      </div>
      <div class="notification success">
        ✅ Команда "Разработчики" выполнила все задачи на этой неделе
      </div>
    </div>
  </div>
</template>

<script>
import { computed, onMounted, ref } from 'vue'
import authService from '@/services/auth.service'

export default {
  name: 'DashboardManagerPage',
  
  setup() {
    const userInfo = computed(() => {
      return {
        isAuthenticated: authService.isAuthenticated(),
        user: authService.getUserData(),
        role: authService.getUserRole(),
        token: authService.getToken() ? 'Есть' : 'Нет'
      }
    })
    
    const userRole = computed(() => authService.getUserRole())
    const userName = computed(() => {
      const user = authService.getUserData()
      return user ? `${user.name} ${user.surname}` : 'Менеджер'
    })
    
    // Тестовые данные
    const urgentTasks = ref([
      { id: 1, title: 'Исправить критическую ошибку в API', client: 'ТехноБанк', deadline: 'Сегодня 18:00', priority: 'Высокий', priorityClass: 'high' },
      { id: 2, title: 'Согласование бюджета на Q1', client: 'Корпорация А', deadline: 'Завтра 10:00', priority: 'Высокий', priorityClass: 'high' },
      { id: 3, title: 'Подготовка отчета для инвесторов', client: 'Стартап Б', deadline: 'Вчера', priority: 'Критический', priorityClass: 'critical' },
      { id: 4, title: 'Интеграция с платежной системой', client: 'ФинТех', deadline: 'Завтра 14:00', priority: 'Средний', priorityClass: 'medium' },
      { id: 5, title: 'Обновление документации', client: 'Внутренний', deadline: 'Послезавтра', priority: 'Низкий', priorityClass: 'low' }
    ])
    
    const teams = ref([
      { id: 1, name: 'Команда разработки', members: 8, projects: 4, progress: 75 },
      { id: 2, name: 'Дизайн-команда', members: 4, projects: 3, progress: 90 },
      { id: 3, name: 'Тестировщики', members: 5, projects: 2, progress: 60 },
      { id: 4, name: 'Аналитики', members: 3, projects: 5, progress: 45 }
    ])
    
    const newClientTasks = ref([
      { id: 1, title: 'Разработка мобильного приложения', client: 'Стартап "Умный город"', createdAt: '2 часа назад', status: 'На рассмотрении', statusClass: 'pending' },
      { id: 2, title: 'Дизайн лендинга', client: 'ООО "Рога и копыта"', createdAt: '5 часов назад', status: 'На рассмотрении', statusClass: 'pending' },
      { id: 3, title: 'Оптимизация SEO', client: 'Интернет-магазин', createdAt: 'Вчера', status: 'Требует уточнений', statusClass: 'review' },
      { id: 4, title: 'Настройка серверов', client: 'ИТ компания', createdAt: 'Вчера', status: 'На рассмотрении', statusClass: 'pending' }
    ])
    
    const projectStats = ref([
      { status: 'planning', label: 'Планирование', count: 3, percentage: 20, color: '#f59e0b' },
      { status: 'in_progress', label: 'В работе', count: 8, percentage: 53, color: '#3b82f6' },
      { status: 'testing', label: 'Тестирование', count: 2, percentage: 13, color: '#8b5cf6' },
      { status: 'completed', label: 'Завершено', count: 2, percentage: 13, color: '#10b981' }
    ])
    
    // Методы
    const approveTask = (taskId) => {
      console.log('Одобрить задачу:', taskId)
      alert(`Задача ${taskId} одобрена!`)
    }
    
    const rejectTask = (taskId) => {
      console.log('Отклонить задачу:', taskId)
      alert(`Задача ${taskId} отклонена!`)
    }
    
    onMounted(() => {
      console.log('🚀 DashboardManagerPage mounted')
      console.log('👔 Manager info:', userInfo.value)
    })
    
    return {
      userInfo,
      userRole,
      userName,
      urgentTasks,
      teams,
      newClientTasks,
      projectStats,
      approveTask,
      rejectTask
    }
  }
}
</script>

<style scoped>
.dashboard-manager-page {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
  background: #f8fafc;
  min-height: 100vh;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.dashboard-header h1 {
  margin: 0;
  color: #1e293b;
  font-size: 24px;
}

.user-info {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 5px;
}

.user-role {
  background: #4f46e5;
  color: white;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
}

.user-name {
  color: #64748b;
  font-size: 14px;
}

.debug-info {
  background: #f1f5f9;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
  border-left: 4px solid #94a3b8;
}

.debug-info h3 {
  margin: 0 0 10px 0;
  color: #475569;
}

.debug-info pre {
  background: white;
  padding: 10px;
  border-radius: 6px;
  overflow: auto;
  font-size: 12px;
  color: #334155;
}

.section {
  background: white;
  padding: 24px;
  border-radius: 12px;
  margin-bottom: 24px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.section h2 {
  margin: 0 0 20px 0;
  color: #1e293b;
  font-size: 18px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 20px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  border: 1px solid #e2e8f0;
  transition: transform 0.2s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
}

.stat-card.primary {
  border-left: 4px solid #4f46e5;
}

.stat-card.success {
  border-left: 4px solid #10b981;
}

.stat-card.warning {
  border-left: 4px solid #f59e0b;
}

.stat-card.danger {
  border-left: 4px solid #ef4444;
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
  margin-bottom: 5px;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: #0f172a;
}

.stat-trend {
  font-size: 12px;
  margin-top: 5px;
}

.trend-up {
  color: #10b981;
}

.trend-down {
  color: #ef4444;
}

.dashboard-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
  margin-bottom: 24px;
}

.card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  margin-bottom: 24px;
}

.card.urgent-tasks {
  border: 2px solid #fecaca;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #e2e8f0;
}

.card-header h3 {
  margin: 0;
  color: #1e293b;
  font-size: 16px;
}

.badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
}

.badge.danger {
  background: #fef2f2;
  color: #dc2626;
  border: 1px solid #fecaca;
}

.btn-link {
  color: #4f46e5;
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
  transition: color 0.2s ease;
}

.btn-link:hover {
  color: #3730a3;
}

.task-list, .teams-list, .client-tasks {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.task-item, .team-item, .client-task {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  transition: background-color 0.2s ease;
}

.task-item:hover, .team-item:hover, .client-task:hover {
  background: #f8fafc;
}

.task-priority {
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  min-width: 70px;
  text-align: center;
}

.task-priority.high {
  background: #fef3c7;
  color: #92400e;
}

.task-priority.critical {
  background: #fee2e2;
  color: #991b1b;
}

.task-priority.medium {
  background: #dbeafe;
  color: #1e40af;
}

.task-priority.low {
  background: #f0f9ff;
  color: #0c4a6e;
}

.task-info, .team-info, .task-details {
  flex: 1;
}

.task-title {
  font-weight: 500;
  color: #1e293b;
  margin-bottom: 4px;
}

.task-meta, .team-meta {
  display: flex;
  gap: 12px;
  font-size: 12px;
  color: #64748b;
}

.team-icon {
  font-size: 24px;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f1f5f9;
  border-radius: 8px;
}

.team-name {
  font-weight: 500;
  color: #1e293b;
  margin-bottom: 4px;
}

.team-stats {
  display: flex;
  flex-direction: column;
  gap: 8px;
  align-items: flex-end;
}

.progress {
  width: 100px;
  height: 6px;
  background: #e2e8f0;
  border-radius: 3px;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  background: #4f46e5;
  border-radius: 3px;
}

.progress-text {
  font-size: 12px;
  color: #64748b;
}

.btn-sm {
  padding: 6px 12px;
  border-radius: 6px;
  border: none;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-sm.btn-primary {
  background: #4f46e5;
  color: white;
}

.btn-sm.btn-primary:hover {
  background: #4338ca;
}

.btn-sm.btn-success {
  background: #10b981;
  color: white;
}

.btn-sm.btn-success:hover {
  background: #059669;
}

.btn-sm.btn-danger {
  background: #ef4444;
  color: white;
}

.btn-sm.btn-danger:hover {
  background: #dc2626;
}

.task-status {
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
  min-width: 80px;
  text-align: center;
}

.task-status.pending {
  background: #fef3c7;
  color: #92400e;
}

.task-status.review {
  background: #dbeafe;
  color: #1e40af;
}

.quick-actions-card {
  background: linear-gradient(135deg, #4f46e5, #7c3aed);
  color: white;
}

.quick-actions-card .card-header h3 {
  color: white;
}

.actions-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.action-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 16px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  text-decoration: none;
  color: white;
  transition: all 0.2s ease;
}

.action-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
}

.action-icon {
  font-size: 24px;
}

.action-text {
  font-size: 12px;
  text-align: center;
}

.project-stats {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.project-stat {
  display: flex;
  align-items: center;
  gap: 12px;
}

.stat-label {
  width: 120px;
  font-size: 14px;
  color: #64748b;
}

.stat-bar {
  flex: 1;
  height: 8px;
  background: #e2e8f0;
  border-radius: 4px;
  overflow: hidden;
}

.bar-fill {
  height: 100%;
  border-radius: 4px;
}

.stat-value {
  width: 70px;
  text-align: right;
  font-size: 14px;
  font-weight: 500;
  color: #1e293b;
}

.notifications {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.notification {
  padding: 12px 16px;
  border-radius: 8px;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.notification.warning {
  background: #fef3c7;
  color: #92400e;
  border: 1px solid #fde68a;
}

.notification.info {
  background: #dbeafe;
  color: #1e40af;
  border: 1px solid #bfdbfe;
}

.notification.success {
  background: #d1fae5;
  color: #065f46;
  border: 1px solid #a7f3d0;
}
</style>