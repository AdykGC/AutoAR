import http from '@/axios'

class ProjectService {
  // Получить все проекты
  getAll(params = {}) {
    return http.get('/projects', { params })
  }
  
  // Получить мои проекты
  getMyProjects(params = {}) {
    return http.get('/projects/my', { params })
  }
  
  // Создать проект
  create(data) {
    return http.post('/projects', data)
  }
  
  // Получить проект по ID
  getById(id) {
    return http.get(`/projects/${id}`)
  }
  
  // Обновить проект
  update(id, data) {
    return http.put(`/projects/${id}`, data)
  }
  
  // Запустить проект
  start(id) {
    return http.post(`/projects/${id}/start`)
  }
  
  // Завершить проект
  complete(id) {
    return http.post(`/projects/${id}/complete`)
  }
  
  // Получить статистику проекта
  getStats(id) {
    return http.get(`/projects/${id}/stats`)
  }
}

export default new ProjectService()