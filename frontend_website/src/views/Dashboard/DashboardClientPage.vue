<template>
  <div class="dashboard-client-page">
    <h1>Дашборд Клиента</h1>
    
    <div class="debug-info">
      <h3>Информация о пользователе:</h3>
      <pre>{{ userInfo }}</pre>
    </div>
    
    <div class="stats">
      <div class="stat-card">
        <h3>Активные задачи</h3>
        <div class="stat-value">3</div>
      </div>
      <div class="stat-card">
        <h3>Проекты в работе</h3>
        <div class="stat-value">2</div>
      </div>
      <div class="stat-card">
        <h3>Завершено задач</h3>
        <div class="stat-value">12</div>
      </div>
    </div>
    
    <div class="quick-actions">
      <router-link to="/client-tasks/my" class="action-btn">
        📋 Мои задачи
      </router-link>
      <router-link to="/client-tasks/create" class="action-btn">
        ➕ Создать задачу
      </router-link>
      <router-link to="/projects" class="action-btn">
        📁 Проекты
      </router-link>
    </div>
  </div>
</template>

<script>
import { computed, onMounted } from 'vue'
import authService from '@/services/auth.service'

export default {
  name: 'DashboardClientPage',
  
  setup() {
    const userInfo = computed(() => {
      return {
        isAuthenticated: authService.isAuthenticated(),
        user: authService.getUserData(),
        role: authService.getUserRole(),
        token: authService.getToken() ? 'Есть' : 'Нет'
      }
    })
    
    onMounted(() => {
      console.log('🚀 DashboardClientPage mounted')
      console.log('👤 User info:', userInfo.value)
    })
    
    return {
      userInfo
    }
  }
}
</script>

<style scoped>
.dashboard-client-page {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

h1 {
  color: #333;
  margin-bottom: 30px;
}

.debug-info {
  background: #f5f5f5;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.debug-info h3 {
  margin-top: 0;
}

.debug-info pre {
  background: white;
  padding: 10px;
  border-radius: 4px;
  overflow: auto;
  font-size: 12px;
}

.stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin: 30px 0;
}

.stat-card {
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 20px;
  text-align: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.stat-card h3 {
  margin: 0 0 10px 0;
  color: #666;
  font-size: 14px;
  text-transform: uppercase;
}

.stat-value {
  font-size: 36px;
  font-weight: bold;
  color: #4f46e5;
}

.quick-actions {
  display: flex;
  gap: 15px;
  margin-top: 30px;
}

.action-btn {
  display: inline-block;
  padding: 15px 25px;
  background: #4f46e5;
  color: white;
  text-decoration: none;
  border-radius: 8px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.action-btn:hover {
  background: #4338ca;
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.2);
}
</style>