import http from '@/axios'

class ClientTaskService {
  // Получить все задачи (для менеджера)
  getAll(params = {}) {
    return http.get('/client-tasks', { params })
  }
  
  // Получить ожидающие задачи
  getPending(params = {}) {
    return http.get('/client-tasks/pending', { params })
  }
  
  // Получить мои задачи (для клиента)
  getMyTasks(params = {}) {
    return http.get('/client-tasks/my', { params })
  }
  
  // Создать задачу (для клиента)
  create(data) {
    return http.post('/client-tasks', data)
  }
  
  // Получить задачу по ID
  getById(id) {
    return http.get(`/client-tasks/${id}`)
  }
  
  // Обновить задачу
  update(id, data) {
    return http.put(`/client-tasks/${id}`, data)
  }
  
  // Отменить задачу
  cancel(id) {
    return http.delete(`/client-tasks/${id}`)
  }
  
  // Одобрить задачу
  approve(id) {
    return http.post(`/client-tasks/${id}/approve`)
  }
  
  // Отклонить задачу
  reject(id, reason = '') {
    return http.post(`/client-tasks/${id}/reject`, { reason })
  }
  
  // Назначить менеджера
  assignManager(id, managerId) {
    return http.post(`/client-tasks/${id}/assign-manager`, { manager_id: managerId })
  }
}

export default new ClientTaskService()