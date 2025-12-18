import api from '@/axios'

class NotificationService {
  // Получить уведомления
  async getNotifications(limit = 50) {
    try {
      const response = await api.get(`/notifications?limit=${limit}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении уведомлений:', error)
      throw error
    }
  }

  // Получить непрочитанные уведомления
  async getUnreadNotifications() {
    try {
      const response = await api.get('/notifications/unread')
      return response.data
    } catch (error) {
      console.error('Ошибка при получении непрочитанных уведомлений:', error)
      throw error
    }
  }

  // Отметить уведомление как прочитанное
  async markAsRead(id) {
    try {
      const response = await api.post(`/notifications/${id}/read`)
      return response.data
    } catch (error) {
      console.error('Ошибка при отметке уведомления как прочитанного:', error)
      throw error
    }
  }

  // Отметить все уведомления как прочитанные
  async markAllAsRead() {
    try {
      const response = await api.post('/notifications/read-all')
      return response.data
    } catch (error) {
      console.error('Ошибка при отметке всех уведомлений как прочитанных:', error)
      throw error
    }
  }

  // Удалить уведомление
  async deleteNotification(id) {
    try {
      const response = await api.delete(`/notifications/${id}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при удалении уведомления:', error)
      throw error
    }
  }

  // Удалить все уведомления
  async deleteAllNotifications() {
    try {
      const response = await api.delete('/notifications')
      return response.data
    } catch (error) {
      console.error('Ошибка при удалении всех уведомлений:', error)
      throw error
    }
  }

  // Получить количество непрочитанных
  async getUnreadCount() {
    try {
      const response = await api.get('/notifications/unread-count')
      return response.data
    } catch (error) {
      console.error('Ошибка при получении количества непрочитанных:', error)
      return { count: 0 }
    }
  }

  // Получить типы уведомлений
  getNotificationTypes() {
    return [
      { value: 'task', label: 'Задача', icon: 'assignment', color: 'primary' },
      { value: 'project', label: 'Проект', icon: 'folder', color: 'success' },
      { value: 'team', label: 'Команда', icon: 'group', color: 'warning' },
      { value: 'system', label: 'Система', icon: 'settings', color: 'default' },
      { value: 'message', label: 'Сообщение', icon: 'message', color: 'info' },
      { value: 'alert', label: 'Оповещение', icon: 'warning', color: 'error' }
    ]
  }

  // Форматировать дату уведомления
  formatNotificationDate(dateString) {
    const date = new Date(dateString)
    const now = new Date()
    const diffMs = now - date
    const diffMins = Math.floor(diffMs / 60000)
    const diffHours = Math.floor(diffMs / 3600000)
    const diffDays = Math.floor(diffMs / 86400000)

    if (diffMins < 1) {
      return 'только что'
    } else if (diffMins < 60) {
      return `${diffMins} мин. назад`
    } else if (diffHours < 24) {
      return `${diffHours} ч. назад`
    } else if (diffDays === 1) {
      return 'вчера'
    } else if (diffDays < 7) {
      return `${diffDays} дн. назад`
    } else {
      return date.toLocaleDateString('ru-RU')
    }
  }
}

export default new NotificationService()