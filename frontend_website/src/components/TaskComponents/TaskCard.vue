<template>
  <div class="task-card" :class="`task-status-${task.status}`">
    <!-- Заголовок задачи -->
    <div class="task-header">
      <h3 class="task-title">{{ task.title }}</h3>
      <div class="task-meta">
        <span class="task-status" :class="`status-${statusInfo.color}`">
          {{ statusInfo.label }}
        </span>
        <span class="task-priority" :class="`priority-${priorityInfo.color}`">
          {{ priorityInfo.label }}
        </span>
      </div>
    </div>

    <!-- Описание задачи -->
    <div class="task-body">
      <p class="task-description">{{ task.description }}</p>
      
      <!-- Прогресс выполнения -->
      <div v-if="task.progress_calculated !== undefined" class="task-progress">
        <div class="progress-bar">
          <div 
            class="progress-fill" 
            :style="{ width: `${task.progress_calculated}%` }"
          ></div>
        </div>
        <span class="progress-text">{{ task.progress_calculated }}%</span>
      </div>

      <!-- Детали задачи -->
      <div class="task-details">
        <div class="detail-item">
          <span class="detail-label">Клиент:</span>
          <span class="detail-value">{{ task.client?.name || 'Не указан' }}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">Менеджер:</span>
          <span class="detail-value">{{ task.manager?.name || 'Не назначен' }}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">Создано:</span>
          <span class="detail-value">{{ formatDate(task.created_at) }}</span>
        </div>
        <div v-if="task.deadline" class="detail-item">
          <span class="detail-label">Дедлайн:</span>
          <span class="detail-value" :class="{ 'deadline-overdue': isOverdue }">
            {{ formatDate(task.deadline) }}
          </span>
        </div>
      </div>

      <!-- Действия -->
      <div class="task-actions">
        <!-- Для клиента -->
        <template v-if="isClient && task.status === 'pending'">
          <button 
            class="btn btn-edit" 
            @click="$emit('edit', task)"
            :disabled="loading"
          >
            Редактировать
          </button>
          <button 
            class="btn btn-cancel" 
            @click="cancelTask"
            :disabled="loading"
          >
            Отменить
          </button>
        </template>

        <!-- Для менеджера -->
        <template v-if="isManager">
          <template v-if="task.status === 'pending'">
            <button 
              class="btn btn-approve" 
              @click="approveTask"
              :disabled="loading"
            >
              Одобрить
            </button>
            <button 
              class="btn btn-reject" 
              @click="rejectTask"
              :disabled="loading"
            >
              Отклонить
            </button>
          </template>
          
          <button 
            class="btn btn-assign" 
            @click="$emit('assign', task)"
            :disabled="loading || task.status !== 'pending'"
          >
            Назначить менеджера
          </button>
        </template>

        <!-- Общие действия -->
        <button 
          class="btn btn-view" 
          @click="$emit('view', task)"
          :disabled="loading"
        >
          Подробнее
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { computed, ref } from 'vue'
import taskService from '../../services/task.service'

export default {
  name: 'TaskCard',
  props: {
    task: {
      type: Object,
      required: true
    }
  },
  emits: ['edit', 'view', 'assign', 'update'],
  
  setup(props, { emit }) {
    const loading = ref(false)

    const statusInfo = computed(() => 
      taskService.getStatusInfo(props.task.status)
    )

    const priorityInfo = computed(() => 
      taskService.getPriorityInfo(props.task.priority)
    )

    const isClient = computed(() => {
      // Предполагаем, что роли хранятся в localStorage или Vuex
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      return user.roles?.some(role => ['Client', 'Client VIP'].includes(role))
    })

    const isManager = computed(() => {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      return user.roles?.some(role => 
        ['Manager', 'Admin', 'Owner', 'CEO'].includes(role)
      )
    })

    const isOverdue = computed(() => {
      if (!props.task.deadline) return false
      return new Date(props.task.deadline) < new Date()
    })

    const formatDate = (dateString) => {
      if (!dateString) return 'Не указано'
      const date = new Date(dateString)
      return date.toLocaleDateString('ru-RU', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
      })
    }

    const approveTask = async () => {
      if (!confirm('Вы уверены, что хотите одобрить эту задачу?')) return
      
      loading.value = true
      try {
        await taskService.approveTask(props.task.id)
        emit('update')
      } catch (error) {
        alert(error.response?.data?.message || 'Ошибка при одобрении задачи')
      } finally {
        loading.value = false
      }
    }

    const rejectTask = async () => {
      const reason = prompt('Укажите причину отклонения:')
      if (reason === null) return
      
      loading.value = true
      try {
        await taskService.rejectTask(props.task.id, reason)
        emit('update')
      } catch (error) {
        alert(error.response?.data?.message || 'Ошибка при отклонении задачи')
      } finally {
        loading.value = false
      }
    }

    const cancelTask = async () => {
      if (!confirm('Вы уверены, что хотите отменить эту задачу?')) return
      
      loading.value = true
      try {
        await taskService.cancelTask(props.task.id)
        emit('update')
      } catch (error) {
        alert(error.response?.data?.message || 'Ошибка при отмене задачи')
      } finally {
        loading.value = false
      }
    }

    return {
      loading,
      statusInfo,
      priorityInfo,
      isClient,
      isManager,
      isOverdue,
      formatDate,
      approveTask,
      rejectTask,
      cancelTask
    }
  }
}
</script>

<style scoped>
.task-card {
  background: white;
  border-radius: 8px;
  border: 1px solid #e0e0e0;
  padding: 16px;
  margin-bottom: 16px;
  transition: box-shadow 0.3s;
}

.task-card:hover {
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.task-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.task-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #333;
  flex: 1;
}

.task-meta {
  display: flex;
  gap: 8px;
}

.task-status, .task-priority {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.status-warning { background: #fff3cd; color: #856404; }
.status-success { background: #d4edda; color: #155724; }
.status-info { background: #d1ecf1; color: #0c5460; }
.status-error { background: #f8d7da; color: #721c24; }

.priority-error { background: #f8d7da; color: #721c24; }
.priority-warning { background: #fff3cd; color: #856404; }
.priority-success { background: #d4edda; color: #155724; }

.task-body {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.task-description {
  margin: 0;
  color: #666;
  font-size: 14px;
  line-height: 1.5;
}

.task-progress {
  display: flex;
  align-items: center;
  gap: 12px;
}

.progress-bar {
  flex: 1;
  height: 8px;
  background: #e0e0e0;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: #4caf50;
  transition: width 0.3s;
}

.progress-text {
  font-size: 12px;
  color: #666;
  min-width: 40px;
}

.task-details {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 8px;
  font-size: 13px;
}

.detail-item {
  display: flex;
  gap: 4px;
}

.detail-label {
  font-weight: 600;
  color: #555;
}

.detail-value {
  color: #333;
}

.deadline-overdue {
  color: #f44336;
  font-weight: 600;
}

.task-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  padding-top: 12px;
  border-top: 1px solid #eee;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s;
}

.btn:hover:not(:disabled) {
  opacity: 0.9;
  transform: translateY(-1px);
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-edit { background: #2196f3; color: white; }
.btn-cancel { background: #f44336; color: white; }
.btn-approve { background: #4caf50; color: white; }
.btn-reject { background: #ff9800; color: white; }
.btn-assign { background: #9c27b0; color: white; }
.btn-view { background: #607d8b; color: white; }

@media (max-width: 768px) {
  .task-header {
    flex-direction: column;
    gap: 8px;
  }
  
  .task-details {
    grid-template-columns: 1fr;
  }
  
  .task-actions {
    flex-direction: column;
  }
  
  .btn {
    width: 100%;
  }
}
</style>