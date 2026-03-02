<template>
  <div class="dashboard-employee-page">
    <div class="dashboard-header">
      <h1>👨‍💻 Дашборд Сотрудника</h1>
      <div class="user-info">
        <span class="user-role">💼 {{ userRole }}</span>
        <span class="user-name">{{ userName }}</span>
      </div>
    </div>
    
    <div class="debug-info">
      <h3>🔧 Информация о пользователе:</h3>
      <pre>{{ userInfo }}</pre>
    </div>
    
    <!-- Мои задачи и прогресс -->
    <div class="section">
      <h2>🎯 Мои задачи</h2>
      <div class="stats-grid">
        <div class="stat-card primary">
          <div class="stat-icon">📝</div>
          <div class="stat-content">
            <div class="stat-title">Текущие задачи</div>
            <div class="stat-value">7</div>
            <div class="stat-trend">⚡ Активно</div>
          </div>
        </div>
        
        <div class="stat-card warning">
          <div class="stat-icon">⏰</div>
          <div class="stat-content">
            <div class="stat-title">Затрачено времени</div>
            <div class="stat-value">42ч</div>
            <div class="stat-trend">📅 На этой неделе</div>
          </div>
        </div>
        
        <div class="stat-card success">
          <div class="stat-icon">✅</div>
          <div class="stat-content">
            <div class="stat-title">Выполнено задач</div>
            <div class="stat-value">23</div>
            <div class="stat-trend trend-up">📈 +5 на этой неделе</div>
          </div>
        </div>
        
        <div class="stat-card danger">
          <div class="stat-icon">🚨</div>
          <div class="stat-content">
            <div class="stat-title">Дедлайн</div>
            <div class="stat-value">2</div>
            <div class="stat-trend">📅 На завтра</div>
          </div>
        </div>
      </div>
    </div>
    
    <div class="dashboard-content">
      <div class="left-column">
        <!-- Активные задачи -->
        <div class="card">
          <div class="card-header">
            <h3>🔥 Активные задачи</h3>
            <router-link to="/project-tasks/my" class="btn-link">Все задачи →</router-link>
          </div>
          <div class="active-tasks">
            <div class="task-item" v-for="task in activeTasks" :key="task.id">
              <div class="task-status" :class="task.statusClass">
                {{ task.status }}
              </div>
              <div class="task-info">
                <div class="task-title">{{ task.title }}</div>
                <div class="task-project">📁 {{ task.project }}</div>
                <div class="task-progress">
                  <div class="progress">
                    <div class="progress-bar" :style="{ width: task.progress + '%' }"></div>
                  </div>
                  <span class="progress-text">{{ task.progress }}%</span>
                </div>
                <div class="task-time">
                  <span class="time-spent">🕐 {{ task.timeSpent }}</span>
                  <span class="deadline">📅 {{ task.deadline }}</span>
                </div>
              </div>
              <div class="task-actions">
                <button class="btn-sm btn-primary" @click="startTask(task.id)" v-if="task.status === 'Ожидает'">
                  ▶️ Старт
                </button>
                <button class="btn-sm btn-warning" @click="pauseTask(task.id)" v-if="task.status === 'В работе'">
                  ⏸️ Пауза
                </button>
                <button class="btn-sm btn-success" @click="completeTask(task.id)" v-if="task.status === 'В работе'">
                  ✅ Готово
                </button>
                <div class="timer" v-if="task.status === 'В работе'">
                  ⏱️ {{ task.timer }}
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Моя команда -->
        <div class="card">
          <div class="card-header">
            <h3>👥 Моя команда</h3>
            <router-link to="/teams/my" class="btn-link">Подробнее →</router-link>
          </div>
          <div class="team-info-card">
            <div class="team-header">
              <div class="team-icon">👥</div>
              <div>
                <div class="team-name">Команда разработки</div>
                <div class="team-lead">👑 Менеджер: Иван Петров</div>
              </div>
            </div>
            <div class="team-members">
              <h4>Участники ({{ teamMembers.length }})</h4>
              <div class="members-list">
                <div class="member" v-for="member in teamMembers" :key="member.id">
                  <div class="member-avatar">{{ member.avatar }}</div>
                  <div class="member-info">
                    <div class="member-name">{{ member.name }}</div>
                    <div class="member-role">{{ member.role }}</div>
                  </div>
                  <div class="member-status" :class="member.statusClass">
                    {{ member.status }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div class="right-column">
        <!-- Предстоящие дедлайны -->
        <div class="card deadlines-card">
          <div class="card-header">
            <h3>📅 Ближайшие дедлайны</h3>
            <span class="badge warning">{{ upcomingDeadlines.length }} задач</span>
          </div>
          <div class="deadlines-list">
            <div class="deadline-item" v-for="deadline in upcomingDeadlines" :key="deadline.id" :class="deadline.priority">
              <div class="deadline-date">
                <div class="date-day">{{ deadline.day }}</div>
                <div class="date-month">{{ deadline.month }}</div>
              </div>
              <div class="deadline-info">
                <div class="deadline-title">{{ deadline.title }}</div>
                <div class="deadline-project">{{ deadline.project }}</div>
                <div class="deadline-time">⏰ Осталось: {{ deadline.timeLeft }}</div>
              </div>
              <div class="deadline-actions">
                <router-link :to="'/project-tasks/' + deadline.id" class="btn-sm btn-outline">
                  Перейти
                </router-link>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Быстрые действия для сотрудника -->
        <div class="card quick-actions-card">
          <div class="card-header">
            <h3>⚡ Быстрые действия</h3>
          </div>
          <div class="actions-grid">
            <button class="action-btn" @click="startTimer">
              <div class="action-icon">⏱️</div>
              <div class="action-text">Запустить таймер</div>
            </button>
            
            <router-link to="/project-tasks/create" class="action-btn">
              <div class="action-icon">📝</div>
              <div class="action-text">Создать задачу</div>
            </router-link>
            
            <button class="action-btn" @click="reportProgress">
              <div class="action-icon">📊</div>
              <div class="action-text">Отчет о прогрессе</div>
            </button>
            
            <router-link to="/profile" class="action-btn">
              <div class="action-icon">👤</div>
              <div class="action-text">Мой профиль</div>
            </router-link>
            
            <button class="action-btn" @click="requestHelp">
              <div class="action-icon">🆘</div>
              <div class="action-text">Запросить помощь</div>
            </button>
            
            <router-link to="/cv" class="action-btn">
              <div class="action-icon">📄</div>
              <div class="action-text">Мое резюме</div>
            </router-link>
          </div>
        </div>
        
        <!-- Продуктивность -->
        <div class="card productivity-card">
          <div class="card-header">
            <h3>📈 Моя продуктивность</h3>
          </div>
          <div class="productivity-stats">
            <div class="productivity-item">
              <div class="productivity-label">Задачи на этой неделе:</div>
              <div class="productivity-value">12/15</div>
              <div class="productivity-bar">
                <div class="bar-fill" style="width: 80%"></div>
              </div>
            </div>
            <div class="productivity-item">
              <div class="productivity-label">Среднее время на задачу:</div>
              <div class="productivity-value">4.2ч</div>
              <div class="productivity-bar">
                <div class="bar-fill" style="width: 70%"></div>
              </div>
            </div>
            <div class="productivity-item">
              <div class="productivity-label">Оценка качества:</div>
              <div class="productivity-value">⭐ 4.8/5</div>
              <div class="productivity-bar">
                <div class="bar-fill" style="width: 96%"></div>
              </div>
            </div>
            <div class="productivity-item">
              <div class="productivity-label">Дедлайны выполнены:</div>
              <div class="productivity-value">95%</div>
              <div class="productivity-bar">
                <div class="bar-fill" style="width: 95%"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Ежедневные уведомления -->
    <div class="notifications">
      <div class="notification info">
        ℹ️ Сегодня у вас запланировано 3 встречи
      </div>
      <div class="notification warning">
        ⚠️ По задаче "Интеграция API" требуются уточнения
      </div>
      <div class="notification success">
        ✅ Ваша команда похвалила вашу работу над проектом "Разработка CRM"
      </div>
    </div>
  </div>
</template>

<script>
import { computed, onMounted, ref } from 'vue'
import authService from '@/services/auth.service'

export default {
  name: 'DashboardEmployeePage',
  
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
      return user ? `${user.name} ${user.surname}` : 'Сотрудник'
    })
    
    // Тестовые данные для сотрудника
    const activeTasks = ref([
      { 
        id: 1, 
        title: 'Разработка модуля авторизации', 
        project: 'CRM System', 
        status: 'В работе', 
        statusClass: 'in-progress',
        progress: 75,
        timeSpent: '8ч 30м',
        deadline: 'Завтра 18:00',
        timer: '02:45:12'
      },
      { 
        id: 2, 
        title: 'Тестирование API endpoints', 
        project: 'Payment Gateway', 
        status: 'Ожидает', 
        statusClass: 'pending',
        progress: 0,
        timeSpent: '0ч',
        deadline: 'Послезавтра 12:00'
      },
      { 
        id: 3, 
        title: 'Исправление багов в UI', 
        project: 'Client Portal', 
        status: 'В работе', 
        statusClass: 'in-progress',
        progress: 40,
        timeSpent: '3ч 15м',
        deadline: 'Сегодня 20:00',
        timer: '00:45:30'
      },
      { 
        id: 4, 
        title: 'Документация по модулю', 
        project: 'CRM System', 
        status: 'На паузе', 
        statusClass: 'paused',
        progress: 20,
        timeSpent: '1ч 45м',
        deadline: '28.12.2025'
      }
    ])
    
    const teamMembers = ref([
      { id: 1, name: 'Иван Петров', role: 'Менеджер проекта', status: 'В офисе', statusClass: 'online', avatar: '👑' },
      { id: 2, name: 'Анна Сидорова', role: 'Frontend разработчик', status: 'Удаленно', statusClass: 'remote', avatar: '👩‍💻' },
      { id: 3, name: 'Михаил Иванов', role: 'Backend разработчик', status: 'На встрече', statusClass: 'meeting', avatar: '👨‍💻' },
      { id: 4, name: 'Екатерина Смирнова', role: 'Дизайнер', status: 'В офисе', statusClass: 'online', avatar: '🎨' },
      { id: 5, name: 'Алексей Козлов', role: 'Тестировщик', status: 'Отпуск', statusClass: 'vacation', avatar: '🧪' }
    ])
    
    const upcomingDeadlines = ref([
      { id: 1, title: 'Разработка модуля авторизации', project: 'CRM System', day: '18', month: 'Дек', timeLeft: '1 день', priority: 'high' },
      { id: 2, title: 'Тестирование API endpoints', project: 'Payment Gateway', day: '19', month: 'Дек', timeLeft: '2 дня', priority: 'medium' },
      { id: 3, title: 'Презентация проекта', project: 'Client Meeting', day: '20', month: 'Дек', timeLeft: '3 дня', priority: 'high' },
      { id: 4, title: 'Отчет о проделанной работе', project: 'Еженедельный', day: '22', month: 'Дек', timeLeft: '5 дней', priority: 'low' }
    ])
    
    // Методы сотрудника
    const startTask = (taskId) => {
      console.log('Начать задачу:', taskId)
      alert(`Задача ${taskId} начата! Таймер запущен.`)
    }
    
    const pauseTask = (taskId) => {
      console.log('Приостановить задачу:', taskId)
      alert(`Задача ${taskId} приостановлена.`)
    }
    
    const completeTask = (taskId) => {
      console.log('Завершить задачу:', taskId)
      alert(`Задача ${taskId} завершена! Отличная работа!`)
    }
    
    const startTimer = () => {
      console.log('Запуск таймера работы')
      alert('Таймер работы запущен! Не забывайте делать перерывы.')
    }
    
    const reportProgress = () => {
      console.log('Отчет о прогрессе')
      alert('Отчет о прогрессе отправлен менеджеру.')
    }
    
    const requestHelp = () => {
      console.log('Запрос помощи')
      alert('Запрос помощи отправлен команде.')
    }
    
    onMounted(() => {
      console.log('🚀 DashboardEmployeePage mounted')
      console.log('👨‍💻 Employee info:', userInfo.value)
    })
    
    return {
      userInfo,
      userRole,
      userName,
      activeTasks,
      teamMembers,
      upcomingDeadlines,
      startTask,
      pauseTask,
      completeTask,
      startTimer,
      reportProgress,
      requestHelp
    }
  }
}
</script>

<style scoped>
.dashboard-employee-page {
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
  background: #10b981;
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
  color: #64748b;
}

.trend-up {
  color: #10b981;
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

.badge.warning {
  background: #fef3c7;
  color: #92400e;
  border: 1px solid #fde68a;
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

.active-tasks, .deadlines-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.task-item, .deadline-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  transition: background-color 0.2s ease;
}

.task-item:hover, .deadline-item:hover {
  background: #f8fafc;
}

.task-status {
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
  min-width: 70px;
  text-align: center;
}

.task-status.in-progress {
  background: #dbeafe;
  color: #1e40af;
}

.task-status.pending {
  background: #fef3c7;
  color: #92400e;
}

.task-status.paused {
  background: #f1f5f9;
  color: #64748b;
}

.task-info {
  flex: 1;
}

.task-title {
  font-weight: 500;
  color: #1e293b;
  margin-bottom: 4px;
}

.task-project {
  font-size: 12px;
  color: #64748b;
  margin-bottom: 8px;
}

.task-progress {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}

.progress {
  flex: 1;
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
  min-width: 40px;
}

.task-time {
  display: flex;
  gap: 15px;
  font-size: 12px;
  color: #64748b;
}

.task-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
  align-items: center;
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

.btn-sm.btn-warning {
  background: #f59e0b;
  color: white;
}

.btn-sm.btn-warning:hover {
  background: #d97706;
}

.btn-sm.btn-success {
  background: #10b981;
  color: white;
}

.btn-sm.btn-success:hover {
  background: #059669;
}

.btn-sm.btn-outline {
  background: transparent;
  border: 1px solid #4f46e5;
  color: #4f46e5;
}

.btn-sm.btn-outline:hover {
  background: #4f46e5;
  color: white;
}

.timer {
  font-size: 12px;
  color: #10b981;
  font-weight: 600;
  background: #d1fae5;
  padding: 4px 8px;
  border-radius: 4px;
}

.team-info-card {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.team-header {
  display: flex;
  align-items: center;
  gap: 15px;
}

.team-icon {
  font-size: 32px;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f1f5f9;
  border-radius: 10px;
}

.team-name {
  font-weight: 600;
  color: #1e293b;
  font-size: 18px;
}

.team-lead {
  font-size: 14px;
  color: #64748b;
  margin-top: 4px;
}

.team-members h4 {
  margin: 0 0 15px 0;
  color: #475569;
  font-size: 14px;
}

.members-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.member {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
}

.member-avatar {
  font-size: 20px;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f1f5f9;
  border-radius: 8px;
}

.member-info {
  flex: 1;
}

.member-name {
  font-weight: 500;
  color: #1e293b;
  margin-bottom: 2px;
}

.member-role {
  font-size: 12px;
  color: #64748b;
}

.member-status {
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
}

.member-status.online {
  background: #d1fae5;
  color: #065f46;
}

.member-status.remote {
  background: #dbeafe;
  color: #1e40af;
}

.member-status.meeting {
  background: #fef3c7;
  color: #92400e;
}

.member-status.vacation {
  background: #f1f5f9;
  color: #64748b;
}

.deadlines-card {
  border: 2px solid #fef3c7;
}

.deadline-item {
  align-items: flex-start;
}

.deadline-item.high {
  border-left: 4px solid #ef4444;
}

.deadline-item.medium {
  border-left: 4px solid #f59e0b;
}

.deadline-item.low {
  border-left: 4px solid #64748b;
}

.deadline-date {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 50px;
}

.date-day {
  font-size: 20px;
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

.deadline-project {
  font-size: 12px;
  color: #64748b;
  margin-bottom: 4px;
}

.deadline-time {
  font-size: 12px;
  color: #ef4444;
  font-weight: 500;
}

.quick-actions-card {
  background: linear-gradient(135deg, #10b981, #059669);
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
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
  font-family: inherit;
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

.productivity-card {
  background: linear-gradient(135deg, #f8fafc, #e2e8f0);
}

.productivity-stats {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.productivity-item {
  display: flex;
  align-items: center;
  gap: 12px;
}

.productivity-label {
  flex: 1;
  font-size: 14px;
  color: #475569;
}

.productivity-value {
  width: 80px;
  text-align: right;
  font-weight: 600;
  color: #1e293b;
  font-size: 14px;
}

.productivity-bar {
  width: 100px;
  height: 6px;
  background: #e2e8f0;
  border-radius: 3px;
  overflow: hidden;
}

.bar-fill {
  height: 100%;
  background: linear-gradient(90deg, #10b981, #34d399);
  border-radius: 3px;
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

.notification.info {
  background: #dbeafe;
  color: #1e40af;
  border: 1px solid #bfdbfe;
}

.notification.warning {
  background: #fef3c7;
  color: #92400e;
  border: 1px solid #fde68a;
}

.notification.success {
  background: #d1fae5;
  color: #065f46;
  border: 1px solid #a7f3d0;
}
</style>