import api from '@/axios'

class ProjectService {
  // Получить все проекты
  async getAllProjects(filters = {}) {
    try {
      const params = new URLSearchParams(filters).toString()
      const response = await api.get(`/projects?${params}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении проектов:', error)
      throw error
    }
  }

  // Создать проект
  async createProject(projectData) {
    try {
      const response = await api.post('/projects', projectData)
      return response.data
    } catch (error) {
      console.error('Ошибка при создании проекта:', error)
      throw error
    }
  }

  // Получить мои проекты
  async getMyProjects(filters = {}) {
    try {
      const params = new URLSearchParams(filters).toString()
      const response = await api.get(`/projects/my?${params}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении моих проектов:', error)
      throw error
    }
  }

  // Получить проект по ID
  async getProject(id) {
    try {
      const response = await api.get(`/projects/${id}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении проекта:', error)
      throw error
    }
  }

  // Обновить проект
  async updateProject(id, projectData) {
    try {
      const response = await api.put(`/projects/${id}`, projectData)
      return response.data
    } catch (error) {
      console.error('Ошибка при обновлении проекта:', error)
      throw error
    }
  }

  // Начать проект
  async startProject(id) {
    try {
      const response = await api.post(`/projects/${id}/start`)
      return response.data
    } catch (error) {
      console.error('Ошибка при старте проекта:', error)
      throw error
    }
  }

  // Завершить проект
  async completeProject(id) {
    try {
      const response = await api.post(`/projects/${id}/complete`)
      return response.data
    } catch (error) {
      console.error('Ошибка при завершении проекта:', error)
      throw error
    }
  }

  // Получить статистику проекта
  async getProjectStats(id) {
    try {
      const response = await api.get(`/projects/${id}/stats`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении статистики проекта:', error)
      throw error
    }
  }

  // Получить статусы проектов
  getProjectStatuses() {
    return [
      { value: 'planning', label: 'Планирование', color: 'info' },
      { value: 'in_progress', label: 'В работе', color: 'warning' },
      { value: 'on_hold', label: 'Приостановлен', color: 'default' },
      { value: 'completed', label: 'Завершен', color: 'success' },
      { value: 'cancelled', label: 'Отменен', color: 'error' }
    ]
  }

  // Получить статус по значению
  getStatusInfo(status) {
    return this.getProjectStatuses().find(s => s.value === status) || 
           { value: status, label: status, color: 'default' }
  }

  // Получить приоритеты проектов
  getProjectPriorities() {
    return [
      { value: 'high', label: 'Высокий', color: 'error' },
      { value: 'medium', label: 'Средний', color: 'warning' },
      { value: 'low', label: 'Низкий', color: 'success' }
    ]
  }

  // Получить прогресс проекта
  async getProjectProgress(id) {
    try {
      const response = await api.get(`/projects/${id}/progress`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении прогресса проекта:', error)
      return { progress: 0, completed_tasks: 0, total_tasks: 0 }
    }
  }

  // Получить участников проекта
  async getProjectMembers(id) {
    try {
      const response = await api.get(`/projects/${id}/members`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении участников проекта:', error)
      return []
    }
  }
}

export default new ProjectService()