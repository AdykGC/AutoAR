<template>
  <div class="welcome-header">
    <div class="welcome-text">
      <h1 class="greeting">{{ greeting }}, {{ user.name }}!</h1>
      <p class="subtitle" v-if="subtitle">{{ subtitle }}</p>
      <p class="date-info">{{ currentDate }}</p>
    </div>
    
    <div class="user-info">
      <div class="user-avatar" :style="{ backgroundColor: avatarColor }">
        {{ user.initials || user.name.charAt(0) }}
      </div>
      <div class="user-details">
        <span class="user-role">{{ roleLabel }}</span>
        <span class="user-status">{{ statusText }}</span>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue'

export default {
  name: 'WelcomeHeader',
  props: {
    user: {
      type: Object,
      default: () => ({
        name: 'Гость',
        role: 'guest',
        status: 'active'
      })
    },
    subtitle: {
      type: String,
      default: ''
    }
  },
  
  setup(props) {
    const greeting = computed(() => {
      const hour = new Date().getHours()
      if (hour < 12) return 'Доброе утро'
      if (hour < 18) return 'Добрый день'
      return 'Добрый вечер'
    })

    const currentDate = computed(() => {
      const now = new Date()
      const options = { 
        weekday: 'long', 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
      }
      return now.toLocaleDateString('ru-RU', options)
    })

    const roleLabel = computed(() => {
      const roles = {
        'client': 'Клиент',
        'client_vip': 'VIP Клиент',
        'employee': 'Сотрудник',
        'manager': 'Менеджер',
        'admin': 'Администратор',
        'owner': 'Владелец',
        'ceo': 'Директор'
      }
      return roles[props.user.role] || props.user.role
    })

    const statusText = computed(() => {
      const statuses = {
        'active': 'Активен',
        'inactive': 'Неактивен',
        'suspended': 'Приостановлен',
        'blocked': 'Заблокирован'
      }
      return statuses[props.user.status] || props.user.status
    })

    const avatarColor = computed(() => {
      const colors = ['#4f46e5', '#0ea5e9', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6']
      const hash = props.user.name.split('').reduce((acc, char) => char.charCodeAt(0) + acc, 0)
      return colors[hash % colors.length]
    })

    return {
      greeting,
      currentDate,
      roleLabel,
      statusText,
      avatarColor
    }
  }
}
</script>

<style scoped>
.welcome-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 0;
  margin-bottom: 32px;
  border-bottom: 1px solid #f0f0f0;
}

.welcome-text {
  flex: 1;
}

.greeting {
  margin: 0 0 8px 0;
  font-size: 32px;
  font-weight: 700;
  color: #1a1a1a;
  line-height: 1.2;
}

.subtitle {
  margin: 0 0 12px 0;
  font-size: 16px;
  color: #666;
  line-height: 1.5;
}

.date-info {
  margin: 0;
  font-size: 14px;
  color: #999;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 12px 20px;
  background: white;
  border-radius: 12px;
  border: 1px solid #e8e8e8;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
}

.user-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  font-weight: 600;
  color: white;
  text-transform: uppercase;
}

.user-details {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.user-role {
  font-size: 16px;
  font-weight: 600;
  color: #1a1a1a;
}

.user-status {
  font-size: 12px;
  color: #10b981;
  padding: 2px 8px;
  background: #ecfdf5;
  border-radius: 12px;
  display: inline-block;
}

@media (max-width: 768px) {
  .welcome-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 20px;
    padding: 16px 0;
  }
  
  .greeting {
    font-size: 24px;
  }
  
  .user-info {
    align-self: stretch;
  }
}
</style>