import api from '@/axios'

class ReportService {
  // Получить отчет по задачам
  async getTaskReport(filters = {}) {
    try {
      const params = new URLSearchParams(filters).toString()
      const response = await api.get(`/reports/tasks?${params}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении отчета по задачам:', error)
      throw error
    }
  }

  // Получить отчет по проектам
  async getProjectReport(filters = {}) {
    try {
      const params = new URLSearchParams(filters).toString()
      const response = await api.get(`/reports/projects?${params}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении отчета по проектам:', error)
      throw error
    }
  }

  // Получить отчет по времени
  async getTimeReport(filters = {}) {
    try {
      const params = new URLSearchParams(filters).toString()
      const response = await api.get(`/reports/time?${params}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении отчета по времени:', error)
      throw error
    }
  }

  // Получить отчет по командам
  async getTeamReport(filters = {}) {
    try {
      const params = new URLSearchParams(filters).toString()
      const response = await api.get(`/reports/teams?${params}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении отчета по командам:', error)
      throw error
    }
  }

  // Получить отчет по пользователям
  async getUserReport(filters = {}) {
    try {
      const params = new URLSearchParams(filters).toString()
      const response = await api.get(`/reports/users?${params}`)
      return response.data
    } catch (error) {
      console.error('Ошибка при получении отчета по пользователям:', error)
      throw error
    }
  }

  // Экспортировать отчет в Excel
  async exportReport(reportType, filters = {}) {
    try {
      const params = new URLSearchParams({
        ...filters,
        format: 'excel'
      }).toString()
      
      const response = await api.get(`/reports/${reportType}/export?${params}`, {
        responseType: 'blob'
      })
      
      return response.data
    } catch (error) {
      console.error('Ошибка при экспорте отчета:', error)
      throw error
    }
  }

  // Скачать экспортированный файл
  downloadFile(blob, filename) {
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', filename)
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
  }

  // Получить периоды для отчетов
  getReportPeriods() {
    return [
      { value: 'today', label: 'Сегодня' },
      { value: 'yesterday', label: 'Вчера' },
      { value: 'week', label: 'Неделя' },
      { value: 'month', label: 'Месяц' },
      { value: 'quarter', label: 'Квартал' },
      { value: 'year', label: 'Год' },
      { value: 'custom', label: 'Произвольный' }
    ]
  }

  // Получить типы отчетов
  getReportTypes() {
    return [
      { value: 'tasks', label: 'По задачам' },
      { value: 'projects', label: 'По проектам' },
      { value: 'time', label: 'По времени' },
      { value: 'teams', label: 'По командам' },
      { value: 'users', label: 'По пользователям' },
      { value: 'financial', label: 'Финансовый' }
    ]
  }
}

export default new ReportService()