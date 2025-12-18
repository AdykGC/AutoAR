import api from '@/axios'

class ClientTaskService {
  // Получить задачи текущего клиента
  async getMyTasks(filters = {}) {
    try {
      const params = new URLSearchParams(filters).toString()
      const response = await api.get(`/client-tasks/my?${params}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении задач клиента:', error)
      throw error
    }
  }

  // Создать новую задачу
  async createTask(taskData) {
    try {
      const response = await api.post('/client-tasks', taskData)
      return response.data
    } catch (error) {
      console.error('Ошибка при создании задачи:', error)
      throw error
    }
  }

  // Получить все задачи (для менеджеров)
  async getAllTasks(filters = {}) {
    try {
      const params = new URLSearchParams(filters).toString()
      const response = await api.get(`/client-tasks?${params}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении всех задач:', error)
      throw error
    }
  }

  // Получить задачи на рассмотрении (для менеджеров)
  async getPendingTasks(filters = {}) {
    try {
      const params = new URLSearchParams(filters).toString()
      const response = await api.get(`/client-tasks/pending?${params}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении задач на рассмотрении:', error)
      throw error
    }
  }

  // Получить задачу по ID
  async getTask(id) {
    try {
      const response = await api.get(`/client-tasks/${id}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении задачи:', error)
      throw error
    }
  }

  // Обновить задачу
  async updateTask(id, taskData) {
    try {
      const response = await api.put(`/client-tasks/${id}`, taskData)
      return response.data
    } catch (error) {
      console.error('Ошибка при обновлении задачи:', error)
      throw error
    }
  }

  // Отменить задачу
  async cancelTask(id) {
    try {
      const response = await api.delete(`/client-tasks/${id}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при отмене задачи:', error)
      throw error
    }
  }

  // Одобрить задачу (для менеджеров)
  async approveTask(id) {
    try {
      const response = await api.post(`/client-tasks/${id}/approve`)
      return response.data
    } catch (error) {
      console.error('Ошибка при одобрении задачи:', error)
      throw error
    }
  }

  // Отклонить задачу (для менеджеров)
  async rejectTask(id, reason = null) {
    try {
      const response = await api.post(`/client-tasks/${id}/reject`, { reason })
      return response.data
    } catch (error) {
      console.error('Ошибка при отклонении задачи:', error)
      throw error
    }
  }

  // Назначить менеджера (для менеджеров)
  async assignManager(id, managerId) {
    try {
      const response = await api.post(`/client-tasks/${id}/assign-manager`, {
        manager_id: managerId
      })
      return response.data
    } catch (error) {
      console.error('Ошибка при назначении менеджера:', error)
      throw error
    }
  }

  // Получить статусы задач
  getTaskStatuses() {
    return [
      { value: 'pending', label: 'На рассмотрении', color: 'warning' },
      { value: 'approved', label: 'Одобрено', color: 'success' },
      { value: 'in_progress', label: 'В работе', color: 'info' },
      { value: 'completed', label: 'Завершено', color: 'success' },
      { value: 'cancelled', label: 'Отменено', color: 'error' },
      { value: 'rejected', label: 'Отклонено', color: 'error' }
    ]
  }

  // Получить приоритеты задач
  getTaskPriorities() {
    return [
      { value: '1', label: 'Высокий', color: 'error' },
      { value: '2', label: 'Средний', color: 'warning' },
      { value: '3', label: 'Низкий', color: 'success' }
    ]
  }

  // Получить статус по значению
  getStatusInfo(status) {
    return this.getTaskStatuses().find(s => s.value === status) || 
           { value: status, label: status, color: 'default' }
  }

  // Получить приоритет по значению
  getPriorityInfo(priority) {
    return this.getTaskPriorities().find(p => p.value === priority) || 
           { value: priority, label: priority, color: 'default' }
  }

  // Получить количество задач по статусам
  async getTasksCount() {
    try {
      const response = await api.get('/client-tasks/count')
      return response.data
    } catch (error) {
      console.error('Ошибка при получении количества задач:', error)
      return {
        pending: 0,
        approved: 0,
        in_progress: 0,
        completed: 0,
        cancelled: 0,
        rejected: 0
      }
    }
  }
}

export default new ClientTaskService()