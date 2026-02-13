<template>
  <BaseManagerPage
    title="Все задачи клиентов"
    subtitle="Управление всеми задачами от клиентов"
    :loading="loading"
    :error="error"
    :items="tasks"
    :show-filters="true"
    :show-search="true"
    :show-status-filter="true"
    :show-date-filter="true"
    :show-refresh="true"
    :show-pagination="true"
    :current-page="currentPage"
    :total-pages="totalPages"
  >
    <template #header-actions>
      <button @click="exportToExcel" style="margin-right: 10px;">
        📊 Экспорт
      </button>
    </template>

    <!-- Список задач -->
    <ManagerCard v-for="task in tasks" :key="task.id" :title="task.title" :subtitle="`Клиент: ${task.client?.name || 'Неизвестно'}`" :status="task.status" style="margin-bottom: 15px;">
      <div style="margin-bottom: 10px;">
        {{ task.description }}
      </div>
      
      <div style="display: flex; justify-content: space-between; color: #666; font-size: 14px;">
        <div>
          <strong>Приоритет:</strong> {{ task.priority }}
        </div>
        <div>
          <strong>Создана:</strong> {{ formatDate(task.created_at) }}
        </div>
        <div>
          <strong>Дедлайн:</strong> {{ formatDate(task.deadline) }}
        </div>
      </div>

      <template #footer>
        <div style="display: flex; gap: 10px;">
          <button @click="viewTask(task.id)" style="padding: 5px 10px;">
            👁️ Просмотр
          </button>
          <button @click="approveTask(task.id)" v-if="task.status === 'pending'" style="padding: 5px 10px; background: #28a745; color: white;">
            ✓ Одобрить
          </button>
          <button @click="rejectTask(task.id)" v-if="task.status === 'pending'" style="padding: 5px 10px; background: #dc3545; color: white;">
            ✗ Отклонить
          </button>
          <button @click="assignManager(task.id)" v-if="task.status === 'approved'" style="padding: 5px 10px;">
            👤 Назначить менеджера
          </button>
        </div>
      </template>
    </ManagerCard>

    <template #empty-actions>
      <button @click="$router.push('/client-tasks/pending')">
        Посмотреть ожидающие задачи
      </button>
    </template>
  </BaseManagerPage>
</template>

<script>
import BaseManagerPage from '@/views/Shared/BaseManagerPage.vue'
import ManagerCard from '@/components/Shared/ManagerCard.vue'
import clientTaskService from '@/services/clientTask.service.js'

export default {
  name: 'ClientTasksAllPage',
  components: {
    BaseManagerPage,
    ManagerCard
  },
  data() {
    return {
      loading: false,
      error: '',
      tasks: [],
      filters: {
        search: '',
        status: '',
        date: ''
      },
      pagination: {
        current_page: 1,
        total_pages: 1,
        per_page: 10
      }
    }
  },
  computed: {
    currentPage() {
      return this.pagination.current_page
    },
    totalPages() {
      return this.pagination.total_pages
    }
  },
  async created() {
    await this.loadTasks()
  },
  methods: {
    async loadTasks(page = 1) {
      this.loading = true
      this.error = ''
      
      try {
        const params = {
          page,
          ...this.filters
        }
        
        const response = await clientTaskService.getAll(params)
        this.tasks = response.data.data || []
        this.pagination = response.data.meta || {
          current_page: 1,
          total_pages: 1,
          per_page: 10
        }
      } catch (err) {
        this.error = err.response?.data?.message || 'Ошибка загрузки задач'
        console.error('Error loading tasks:', err)
      } finally {
        this.loading = false
      }
    },
    
    async approveTask(id) {
      if (!confirm('Одобрить эту задачу?')) return
      
      try {
        await clientTaskService.approve(id)
        await this.loadTasks(this.currentPage)
        alert('Задача одобрена!')
      } catch (err) {
        alert(err.response?.data?.message || 'Ошибка одобрения задачи')
      }
    },
    
    async rejectTask(id) {
      const reason = prompt('Причина отклонения:')
      if (reason === null) return
      
      try {
        await clientTaskService.reject(id, reason)
        await this.loadTasks(this.currentPage)
        alert('Задача отклонена!')
      } catch (err) {
        alert(err.response?.data?.message || 'Ошибка отклонения задачи')
      }
    },
    
    async assignManager(id) {
      const managerId = prompt('Введите ID менеджера:')
      if (!managerId) return
      
      try {
        await clientTaskService.assignManager(id, managerId)
        await this.loadTasks(this.currentPage)
        alert('Менеджер назначен!')
      } catch (err) {
        alert(err.response?.data?.message || 'Ошибка назначения менеджера')
      }
    },
    
    viewTask(id) {
      this.$router.push(`/client-tasks/${id}`)
    },
    
    formatDate(dateString) {
      if (!dateString) return 'Не указано'
      return new Date(dateString).toLocaleDateString('ru-RU')
    },
    
    exportToExcel() {
      // Простая реализация экспорта
      const data = this.tasks.map(task => ({
        ID: task.id,
        Название: task.title,
        Клиент: task.client?.name || '',
        Статус: task.status,
        Приоритет: task.priority,
        'Дата создания': this.formatDate(task.created_at),
        Дедлайн: this.formatDate(task.deadline)
      }))
      
      const csv = this.convertToCSV(data)
      this.downloadCSV(csv, 'client-tasks.csv')
    },
    
    convertToCSV(data) {
      const headers = Object.keys(data[0] || {}).join(',')
      const rows = data.map(row => Object.values(row).join(','))
      return [headers, ...rows].join('\n')
    },
    
    downloadCSV(csv, filename) {
      const blob = new Blob([csv], { type: 'text/csv' })
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = filename
      a.click()
      window.URL.revokeObjectURL(url)
    }
  }
}
</script>