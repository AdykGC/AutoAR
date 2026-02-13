import api from '@/axios'

class ActivityService {
  // Получить последнюю активность
  async getRecentActivity(limit = 20) {
    try {
      const response = await api.get(`/activity?limit=${limit}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении активности:', error)
      throw error
    }
  }

  // Получить активность пользователя
  async getUserActivity(userId, limit = 20) {
    try {
      const response = await api.get(`/activity/user/${userId}?limit=${limit}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении активности пользователя:', error)
      throw error
    }
  }

  // Получить активность по типу
  async getActivityByType(type, limit = 20) {
    try {
      const response = await api.get(`/activity/type/${type}?limit=${limit}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении активности по типу:', error)
      throw error
    }
  }

  // Получить активность проекта
  async getProjectActivity(projectId, limit = 20) {
    try {
      const response = await api.get(`/activity/project/${projectId}?limit=${limit}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении активности проекта:', error)
      throw error
    }
  }

  // Получить активность задачи
  async getTaskActivity(taskId, limit = 20) {
    try {
      const response = await api.get(`/activity/task/${taskId}?limit=${limit}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении активности задачи:', error)
      throw error
    }
  }

  // Получить типы активности
  getActivityTypes() {
    return [
      { value: 'all', label: 'Все' },
      { value: 'create', label: 'Создание' },
      { value: 'update', label: 'Обновление' },
      { value: 'delete', label: 'Удаление' },
      { value: 'approve', label: 'Одобрение' },
      { value: 'reject', label: 'Отклонение' },
      { value: 'complete', label: 'Завершение' },
      { value: 'assign', label: 'Назначение' },
      { value: 'comment', label: 'Комментарий' }
    ]
  }

  // Форматировать дату активности
  formatActivityDate(dateString) {
    const date = new Date(dateString)
    const now = new Date()
    const diffMs = now - date
    const diffMins = Math.floor(diffMs / 60000)
    const diffHours = Math.floor(diffMs / 3600000)
    const diffDays = Math.floor(diffMs / 86400000)

    if (diffMins < 1) {
      return 'только что'
    } else if (diffMins < 60) {
      return `${diffMins} минут назад`
    } else if (diffHours < 24) {
      return `${diffHours} часов назад`
    } else if (diffDays < 7) {
      return `${diffDays} дней назад`
    } else {
      return date.toLocaleDateString('ru-RU', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
      })
    }
  }

  // Получить иконку для типа активности
  getActivityIcon(type) {
    const icons = {
      create: 'add',
      update: 'edit',
      delete: 'delete',
      approve: 'check',
      reject: 'close',
      complete: 'done_all',
      assign: 'person_add',
      comment: 'comment',
      default: 'notifications'
    }
    return icons[type] || icons.default
  }

  // Получить цвет для типа активности
  getActivityColor(type) {
    const colors = {
      create: 'success',
      update: 'info',
      delete: 'error',
      approve: 'success',
      reject: 'warning',
      complete: 'success',
      assign: 'info',
      comment: 'default',
      default: 'default'
    }
    return colors[type] || colors.default
  }
}

export default new ActivityService()