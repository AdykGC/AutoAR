import api from '@/axios'

class TeamService {
  // Получить все команды
  async getAllTeams(filters = {}) {
    try {
      const params = new URLSearchParams(filters).toString()
      const response = await api.get(`/teams?${params}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении команд:', error)
      throw error
    }
  }

  // Получить команду по ID
  async getTeam(id) {
    try {
      const response = await api.get(`/teams/${id}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении команды:', error)
      throw error
    }
  }

  // Получить мою команду
  async getMyTeam() {
    try {
      const response = await api.get('/teams/my/team')
      return response.data
    } catch (error) {
      console.error('Ошибка при получении моей команды:', error)
      throw error
    }
  }

  // Создать команду
  async createTeam(teamData) {
    try {
      const response = await api.post('/teams', teamData)
      return response.data
    } catch (error) {
      console.error('Ошибка при создании команды:', error)
      throw error
    }
  }

  // Обновить команду
  async updateTeam(id, teamData) {
    try {
      const response = await api.put(`/teams/${id}`, teamData)
      return response.data
    } catch (error) {
      console.error('Ошибка при обновлении команды:', error)
      throw error
    }
  }

  // Удалить команду
  async deleteTeam(id) {
    try {
      const response = await api.delete(`/teams/${id}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при удалении команды:', error)
      throw error
    }
  }

  // Добавить участника в команду
  async addTeamMember(teamId, userId, role = 'member') {
    try {
      const response = await api.post(`/teams/${teamId}/members`, {
        user_id: userId,
        role: role
      })
      return response.data
    } catch (error) {
      console.error('Ошибка при добавлении участника:', error)
      throw error
    }
  }

  // Удалить участника из команды
  async removeTeamMember(teamId, userId) {
    try {
      const response = await api.delete(`/teams/${teamId}/members/${userId}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при удалении участника:', error)
      throw error
    }
  }

  // Получить статистику команды
  async getTeamStats(id) {
    try {
      const response = await api.get(`/teams/${id}/stats`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении статистики команды:', error)
      throw error
    }
  }

  // Получить участников команды
  async getTeamMembers(id) {
    try {
      const response = await api.get(`/teams/${id}/members`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении участников команды:', error)
      return []
    }
  }

  // Получить проекты команды
  async getTeamProjects(id) {
    try {
      const response = await api.get(`/teams/${id}/projects`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении проектов команды:', error)
      return []
    }
  }

  // Получить типы команд
  getTeamTypes() {
    return [
      { value: 'development', label: 'Разработка' },
      { value: 'design', label: 'Дизайн' },
      { value: 'qa', label: 'Тестирование' },
      { value: 'management', label: 'Менеджмент' },
      { value: 'sales', label: 'Продажи' },
      { value: 'support', label: 'Поддержка' }
    ]
  }

  // Получить роли в команде
  getTeamRoles() {
    return [
      { value: 'leader', label: 'Лидер', color: 'primary' },
      { value: 'senior', label: 'Сеньор', color: 'success' },
      { value: 'middle', label: 'Мидл', color: 'warning' },
      { value: 'junior', label: 'Джун', color: 'info' },
      { value: 'intern', label: 'Стажер', color: 'default' },
      { value: 'member', label: 'Участник', color: 'default' }
    ]
  }

  // Получить отделы
  getDepartments() {
    return [
      { value: 'it', label: 'IT отдел' },
      { value: 'development', label: 'Разработка' },
      { value: 'design', label: 'Дизайн' },
      { value: 'marketing', label: 'Маркетинг' },
      { value: 'sales', label: 'Продажи' },
      { value: 'support', label: 'Поддержка' },
      { value: 'hr', label: 'HR' },
      { value: 'finance', label: 'Финансы' }
    ]
  }
}

export default new TeamService()