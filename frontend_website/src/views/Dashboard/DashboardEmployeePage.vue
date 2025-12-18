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
        ✅ Ваша команда похвалила вашу работу над проектом "