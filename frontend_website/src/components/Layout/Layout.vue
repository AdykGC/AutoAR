<template>
  <div class="app-layout">
    <!-- Topbar -->
    <div style="background: #2c3e50; color: white; padding: 15px 20px; display: flex; justify-content: space-between; align-items: center;">
      <div style="font-size: 20px; font-weight: bold;">
        {{ appName }}
      </div>
      
      <div style="display: flex; align-items: center; gap: 20px;">
        <div>
          {{ user?.name || 'Пользователь' }}
          <span style="font-size: 12px; color: #95a5a6;">({{ userRole }})</span>
        </div>
        
        <div style="display: flex; gap: 10px;">
          <button @click="$router.push('/profile')" style="background: none; border: none; color: white; cursor: pointer;">
            👤 Профиль
          </button>
          <button @click="$router.push('/logout')" style="background: #e74c3c; border: none; color: white; padding: 5px 10px; border-radius: 3px; cursor: pointer;">
            Выйти
          </button>
        </div>
      </div>
    </div>

    <div style="display: flex;">
      <!-- Sidebar -->
      <div style="width: 250px; background: #34495e; color: white; min-height: calc(100vh - 60px);">
        <div style="padding: 20px;">
          <div style="font-weight: bold; margin-bottom: 20px; color: #ecf0f1;">
            Навигация
          </div>
          
          <!-- Dashboard Link -->
          <div style="margin-bottom: 10px;">
            <router-link 
              to="/dashboard" 
              style="display: block; padding: 10px; color: #bdc3c7; text-decoration: none; border-radius: 4px;"
              active-class="active-link"
            >
              📊 Дашборд
            </router-link>
          </div>

          <!-- Manager Links -->
          <div v-if="isManager" style="margin-top: 20px;">
            <div style="font-size: 12px; color: #7f8c8d; margin-bottom: 10px;">
              УПРАВЛЕНИЕ
            </div>
            
            <router-link 
              to="/projects" 
              style="display: block; padding: 8px 10px; color: #bdc3c7; text-decoration: none; border-radius: 4px; margin-bottom: 5px;"
              active-class="active-link"
            >
              📁 Проекты
            </router-link>
            
            <router-link 
              to="/client-tasks" 
              style="display: block; padding: 8px 10px; color: #bdc3c7; text-decoration: none; border-radius: 4px; margin-bottom: 5px;"
              active-class="active-link"
            >
              📋 Задачи клиентов
            </router-link>
            
            <router-link 
              to="/client-tasks/pending" 
              style="display: block; padding: 8px 10px; color: #bdc3c7; text-decoration: none; border-radius: 4px; margin-bottom: 5px;"
              active-class="active-link"
            >
              ⏰ Ожидающие
            </router-link>
            
            <router-link 
              to="/teams" 
              style="display: block; padding: 8px 10px; color: #bdc3c7; text-decoration: none; border-radius: 4px; margin-bottom: 5px;"
              active-class="active-link"
            >
              👥 Команды
            </router-link>
            
            <router-link 
              to="/project-tasks" 
              style="display: block; padding: 8px 10px; color: #bdc3c7; text-decoration: none; border-radius: 4px; margin-bottom: 5px;"
              active-class="active-link"
            >
              ✅ Задачи проекта
            </router-link>
          </div>

          <!-- Client Links -->
          <div v-if="isClient" style="margin-top: 20px;">
            <div style="font-size: 12px; color: #7f8c8d; margin-bottom: 10px;">
              КЛИЕНТ
            </div>
            
            <router-link 
              to="/client-tasks/my" 
              style="display: block; padding: 8px 10px; color: #bdc3c7; text-decoration: none; border-radius: 4px; margin-bottom: 5px;"
              active-class="active-link"
            >
              📋 Мои задачи
            </router-link>
            
            <router-link 
              to="/client-tasks/create" 
              style="display: block; padding: 8px 10px; color: #bdc3c7; text-decoration: none; border-radius: 4px; margin-bottom: 5px;"
              active-class="active-link"
            >
              + Новая задача
            </router-link>
          </div>

          <!-- Employee Links -->
          <div v-if="isEmployee" style="margin-top: 20px;">
            <div style="font-size: 12px; color: #7f8c8d; margin-bottom: 10px;">
              СОТРУДНИК
            </div>
            
            <router-link 
              to="/project-tasks/my" 
              style="display: block; padding: 8px 10px; color: #bdc3c7; text-decoration: none; border-radius: 4px; margin-bottom: 5px;"
              active-class="active-link"
            >
              ✅ Мои задачи
            </router-link>
            
            <router-link 
              to="/teams/my" 
              style="display: block; padding: 8px 10px; color: #bdc3c7; text-decoration: none; border-radius: 4px; margin-bottom: 5px;"
              active-class="active-link"
            >
              👥 Моя команда
            </router-link>
          </div>

          <!-- Common Links -->
          <div style="margin-top: 30px;">
            <div style="font-size: 12px; color: #7f8c8d; margin-bottom: 10px;">
              ОБЩЕЕ
            </div>
            
            <router-link 
              to="/profile" 
              style="display: block; padding: 8px 10px; color: #bdc3c7; text-decoration: none; border-radius: 4px; margin-bottom: 5px;"
              active-class="active-link"
            >
              👤 Профиль
            </router-link>
            
            <router-link 
              to="/cv/generate" 
              style="display: block; padding: 8px 10px; color: #bdc3c7; text-decoration: none; border-radius: 4px; margin-bottom: 5px;"
              active-class="active-link"
            >
              📄 Резюме
            </router-link>
            
            <router-link 
              to="/logout" 
              style="display: block; padding: 8px 10px; color: #e74c3c; text-decoration: none; border-radius: 4px; margin-bottom: 5px;"
            >
              🚪 Выход
            </router-link>
          </div>
        </div>
      </div>

      <!-- Main Content -->
      <div style="flex: 1; padding: 20px; background: #ecf0f1; min-height: calc(100vh - 60px);">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script>
import authService from '@/services/auth.service.js'

export default {
  name: 'AppLayout',
  data() {
    return {
      appName: 'Project Manager',
      user: null,
      userRole: ''
    }
  },
  computed: {
    isManager() {
      return ['Manager', 'Admin', 'Owner', 'CEO'].includes(this.userRole)
    },
    isClient() {
      return ['Client', 'Client VIP'].includes(this.userRole)
    },
    isEmployee() {
      return this.userRole === 'Employee'
    }
  },
  mounted() {
    this.user = authService.getUserData()
    this.userRole = authService.getUserRole()
  }
}
</script>

<style>
.active-link {
  background: #3498db !important;
  color: white !important;
}

.router-link-active {
  background: #3498db !important;
  color: white !important;
}
</style>