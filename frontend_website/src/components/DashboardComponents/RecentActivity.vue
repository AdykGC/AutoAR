<template>
  <DashboardCard title="Последняя активность">
    <div class="activity-list">
      <div v-if="loading" class="loading">
        <span class="material-icons spin">refresh</span>
        Загрузка активности...
      </div>
      
      <div v-else-if="activities.length === 0" class="empty">
        <span class="material-icons">notifications_none</span>
        Активности пока нет
      </div>
      
      <div v-else>
        <div v-for="activity in activities" :key="activity.id" class="activity-item">
          <div class="activity-icon" :class="activity.type">
            <span class="material-icons">{{ getActivityIcon(activity.type) }}</span>
          </div>
          
          <div class="activity-content">
            <div class="activity-text">
              <span class="user-name">{{ activity.user.name }}</span>
              {{ activity.description }}
            </div>
            <div class="activity-meta">
              <span class="activity-time">{{ formatTime(activity.created_at) }}</span>
              <span v-if="activity.entity" class="activity-entity">
                • {{ activity.entity }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <template #footer v-if="activities.length > 0">
      <button class="view-all-btn" @click="$emit('view-all')">
        Показать все
        <span class="material-icons">chevron_right</span>
      </button>
    </template>
  </DashboardCard>
</template>

<script>
import DashboardCard from './DashboardCard.vue'
import { computed } from 'vue'

export default {
  name: 'RecentActivity',
  components: {
    DashboardCard
  },
  props: {
    activities: {
      type: Array,
      default: () => []
    },
    loading: {
      type: Boolean,
      default: false
    }
  },
  emits: ['view-all'],
  
  setup(props) {
    const getActivityIcon = (type) => {
      const icons = {
        'create': 'add_circle',
        'update': 'edit',
        'delete': 'delete',
        'approve': 'check_circle',
        'reject': 'cancel',
        'complete': 'done_all',
        'assign': 'person_add',
        'comment': 'comment',
        'default': 'notifications'
      }
      return icons[type] || icons.default
    }

    const formatTime = (dateString) => {
      const date = new Date(dateString)
      const now = new Date()
      const diffMs = now - date
      const diffMins = Math.floor(diffMs / 60000)
      const diffHours = Math.floor(diffMs / 3600000)
      const diffDays = Math.floor(diffMs / 86400000)

      if (diffMins < 1) return 'только что'
      if (diffMins < 60) return `${diffMins} мин назад`
      if (diffHours < 24) return `${diffHours} ч назад`
      if (diffDays === 1) return 'вчера'
      if (diffDays < 7) return `${diffDays} дн назад`
      
      return date.toLocaleDateString('ru-RU', {
        day: '2-digit',
        month: 'short'
      })
    }

    return {
      getActivityIcon,
      formatTime
    }
  }
}
</script>

<style scoped>
.activity-list {
  max-height: 400px;
  overflow-y: auto;
  padding-right: 8px;
}

.activity-item {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  padding: 16px 0;
  border-bottom: 1px solid #f5f5f5;
}

.activity-item:last-child {
  border-bottom: none;
}

.activity-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.activity-icon.create { background: #10b981; }
.activity-icon.update { background: #0ea5e9; }
.activity-icon.delete { background: #ef4444; }
.activity-icon.approve { background: #10b981; }
.activity-icon.reject { background: #f59e0b; }
.activity-icon.complete { background: #8b5cf6; }
.activity-icon.assign { background: #6366f1; }
.activity-icon.comment { background: #64748b; }
.activity-icon.default { background: #94a3b8; }

.activity-content {
  flex: 1;
  min-width: 0;
}

.activity-text {
  margin: 0 0 6px 0;
  font-size: 14px;
  line-height: 1.5;
  color: #475569;
}

.user-name {
  font-weight: 600;
  color: #1e293b;
  margin-right: 4px;
}

.activity-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #94a3b8;
}

.activity-entity {
  color: #6366f1;
  font-weight: 500;
}

.loading, .empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  color: #94a3b8;
  text-align: center;
}

.loading .material-icons {
  font-size: 48px;
  margin-bottom: 16px;
  color: #6366f1;
}

.empty .material-icons {
  font-size: 48px;
  margin-bottom: 16px;
  color: #cbd5e1;
}

.spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.view-all-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  width: 100%;
  padding: 12px;
  background: transparent;
  border: none;
  color: #6366f1;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  border-radius: 8px;
}

.view-all-btn:hover {
  background: #f8fafc;
  color: #4f46e5;
}

.view-all-btn .material-icons {
  font-size: 18px;
  transition: transform 0.2s ease;
}

.view-all-btn:hover .material-icons {
  transform: translateX(2px);
}

/* Scrollbar styling */
.activity-list::-webkit-scrollbar {
  width: 4px;
}

.activity-list::-webkit-scrollbar-track {
  background: #f1f5f9;
  border-radius: 4px;
}

.activity-list::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 4px;
}

.activity-list::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}
</style>