import api from '@/axios'

import api from '@/axios'
import authService from './auth.service'

class UserService {
  // Получить информацию о текущем пользователе
  async getCurrentUser() {
    try {
      console.log('📡 Запрос данных пользователя...')
      
      // Сначала пробуем получить из authService
      const userFromAuth = authService.getUserData()
      if (userFromAuth) {
        console.log('👤 Пользователь из authService:', userFromAuth)
        return {
          success: true,
          data: userFromAuth
        }
      }
      
      // Если нет в authService, запрашиваем с API
      const response = await api.get('/auth/me')
      console.log('✅ Ответ /auth/me:', response.data)
      
      if (response.data.success) {
        // Сохраняем в authService
        authService.setUser(response.data.data.user)
        return response.data
      }
      
      return response.data
    } catch (error) {
      console.error('❌ Ошибка при получении информации о пользователе:', error)
      
      // Возвращаем мок данные для тестирования
      const mockUser = authService.getUserData() || {
        id: 1,
        name: 'Тестовый Клиент',
        email: 'client@example.com',
        role: 'Client',
        created_at: new Date().toISOString()
      }
      
      return {
        success: true,
        data: mockUser
      }
    }
  }

  // Получить всех пользователей
  async getAllUsers(filters = {}) {
    try {
      const params = new URLSearchParams(filters).toString()
      const response = await api.get(`/users?${params}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении пользователей:', error)
      throw error
    }
  }

  // Получить пользователя по ID
  async getUser(id) {
    try {
      const response = await api.get(`/users/${id}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении пользователя:', error)
      throw error
    }
  }

  // Обновить профиль пользователя
  async updateProfile(userData) {
    try {
      const response = await api.put('/profile', userData)
      return response.data
    } catch (error) {
      console.error('Ошибка при обновлении профиля:', error)
      throw error
    }
  }

  // Изменить пароль
  async changePassword(passwordData) {
    try {
      const response = await api.post('/profile/change-password', passwordData)
      return response.data
    } catch (error) {
      console.error('Ошибка при изменении пароля:', error)
      throw error
    }
  }

  // Получить роли пользователей
  getUserRoles() {
    return [
      { value: 'client', label: 'Клиент', color: 'primary' },
      { value: 'client_vip', label: 'Клиент VIP', color: 'vip' },
      { value: 'employee', label: 'Сотрудник', color: 'info' },
      { value: 'manager', label: 'Менеджер', color: 'warning' },
      { value: 'admin', label: 'Администратор', color: 'success' },
      { value: 'owner', label: 'Владелец', color: 'error' },
      { value: 'ceo', label: 'Директор', color: 'ceo' }
    ]
  }

  // Получить информацию о роли
  getRoleInfo(role) {
    const roles = this.getUserRoles()
    return roles.find(r => r.value === role) || 
           { value: role, label: role, color: 'default' }
  }

  // Получить статусы пользователей
  getUserStatuses() {
    return [
      { value: 'active', label: 'Активен', color: 'success' },
      { value: 'inactive', label: 'Неактивен', color: 'default' },
      { value: 'suspended', label: 'Приостановлен', color: 'warning' },
      { value: 'blocked', label: 'Заблокирован', color: 'error' }
    ]
  }

  // Получить пользователей по роли
  async getUsersByRole(role) {
    try {
      const response = await api.get(`/users/role/${role}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении пользователей по роли:', error)
      return []
    }
  }

  // Получить менеджеров
  async getManagers() {
    try {
      const response = await api.get('/users/managers')
      return response.data
    } catch (error) {
      console.error('Ошибка при получении менеджеров:', error)
      return []
    }
  }

  // Получить сотрудников
  async getEmployees() {
    try {
      const response = await api.get('/users/employees')
      return response.data
    } catch (error) {
      console.error('Ошибка при получении сотрудников:', error)
      return []
    }
  }

  // Получить клиентов
  async getClients() {
    try {
      const response = await api.get('/users/clients')
      return response.data
    } catch (error) {
      console.error('Ошибка при получении клиентов:', error)
      return []
    }
  }

  // Получить статистику пользователя
  async getUserStats(userId) {
    try {
      const response = await api.get(`/users/${userId}/stats`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении статистики пользователя:', error)
      return {
        tasks_completed: 0,
        tasks_in_progress: 0,
        total_hours: 0,
        projects_count: 0
      }
    }
  }
}

export default new UserService()