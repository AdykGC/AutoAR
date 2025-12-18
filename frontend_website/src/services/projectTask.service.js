import api from '@/axios'

class ProjectTaskService {
  // Получить мои подзадачи
  async getMyTasks(filters = {}) {
    try {
      const params = new URLSearchParams(filters).toString()
      const response = await api.get(`/project-tasks/my?${params}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении моих подзадач:', error)
      throw error
    }
  }

  // Создать подзадачу
  async createTask(taskData) {
    try {
      const response = await api.post('/project-tasks', taskData)
      return response.data
    } catch (error) {
      console.error('Ошибка при создании подзадачи:', error)
      throw error
    }
  }

  // Получить подзадачу по ID
  async getTask(id) {
    try {
      const response = await api.get(`/project-tasks/${id}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении подзадачи:', error)
      throw error
    }
  }

  // Обновить подзадачу
  async updateTask(id, taskData) {
    try {
      const response = await api.put(`/project-tasks/${id}`, taskData)
      return response.data
    } catch (error) {
      console.error('Ошибка при обновлении подзадачи:', error)
      throw error
    }
  }

  // Назначить подзадачу
  async assignTask(id, userId) {
    try {
      const response = await api.post(`/project-tasks/${id}/assign`, {
        user_id: userId
      })
      return response.data
    } catch (error) {
      console.error('Ошибка при назначении подзадачи:', error)
      throw error
    }
  }

  // Завершить подзадачу
  async completeTask(id) {
    try {
      const response = await api.post(`/project-tasks/${id}/complete`)
      return response.data
    } catch (error) {
      console.error('Ошибка при завершении подзадачи:', error)
      throw error
    }
  }

  // Обновить время подзадачи
  async updateTaskTime(id, timeData) {
    try {
      const response = await api.post(`/project-tasks/${id}/update-time`, timeData)
      return response.data
    } catch (error) {
      console.error('Ошибка при обновлении времени подзадачи:', error)
      throw error
    }
  }

  // Получить статусы подзадач
  getTaskStatuses() {
    return [
      { value: 'todo', label: 'К выполнению', color: 'default' },
      { value: 'in_progress', label: 'В работе', color: 'warning' },
      { value: 'review', label: 'На проверке', color: 'info' },
      { value: 'completed', label: 'Завершено', color: 'success' },
      { value: 'blocked', label: 'Заблокировано', color: 'error' }
    ]
  }

  // Получить приоритеты подзадач
  getTaskPriorities() {
    return [
      { value: '1', label: 'Высокий', color: 'error' },
      { value: '2', label: 'Средний', color: 'warning' },
      { value: '3', label: 'Низкий', color: 'success' },
      { value: '4', label: 'Обычный', color: 'default' }
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

  // Получить типы подзадач
  getTaskTypes() {
    return [
      { value: 'development', label: 'Разработка' },
      { value: 'design', label: 'Дизайн' },
      { value: 'testing', label: 'Тестирование' },
      { value: 'documentation', label: 'Документация' },
      { value: 'analysis', label: 'Анализ' },
      { value: 'meeting', label: 'Совещание' }
    ]
  }

  // Получить прогресс подзадачи
  async getTaskProgress(id) {
    try {
      const response = await api.get(`/project-tasks/${id}/progress`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении прогресса подзадачи:', error)
      return { progress: 0, hours_spent: 0, hours_estimated: 0 }
    }
  }

  // Получить историю времени
  async getTimeHistory(id) {
    try {
      const response = await api.get(`/project-tasks/${id}/time-history`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении истории времени:', error)
      return []
    }
  }
}

export default new ProjectTaskService()