import api from '@/axios'

class DashboardService {
  // Дашборд клиента - временная заглушка
  async getClientDashboard() {
    try {
      const response = await api.get('/dashboard/client')
      return response.data
    } catch (error) {
      console.error(' Ошибка дашборда клиента:', error)
      throw error
    }
  }

  // Дашборд менеджера
  async getManagerDashboard() {
    try {
      const response = await api.get('/dashboard/manager')
      return response.data
    } catch (error) {
      console.error('Ошибка при получении дашборда менеджера:', error)
      throw error
    }
  }

  // Дашборд сотрудника
  async getEmployeeDashboard() {
    try {
      const response = await api.get('/dashboard/employee')
      return response.data
    } catch (error) {
      console.error('Ошибка при получении дашборда сотрудника:', error)
      throw error
    }
  }

  // Получить дашборд по роли
  async getDashboardByRole(role) {
    switch (role) {
      case 'client':
      case 'Client':
      case 'Client VIP':
        return this.getClientDashboard()
      case 'manager':
      case 'Manager':
      case 'Admin':
      case 'Owner':
      case 'CEO':
        return this.getManagerDashboard()
      case 'employee':
      case 'Employee':
        return this.getEmployeeDashboard()
      default:
        return this.getClientDashboard()
    }
  }

  // Получить статистику
  async getStats() {
    try {
      const response = await api.get('/dashboard/stats')
      return response.data
    } catch (error) {
      console.error('Ошибка при получении статистики:', error)
      throw error
    }
  }

  // Получить недавнюю активность
  async getRecentActivity(limit = 10) {
    try {
      const response = await api.get(`/dashboard/activity?limit=${limit}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении активности:', error)
      throw error
    }
  }
}

export default new DashboardService()