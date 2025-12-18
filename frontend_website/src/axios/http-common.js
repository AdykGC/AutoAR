import api from './index.js'

// Экспортируем функции для работы с API
export default {
  // GET запрос
  get(url, config = {}) {
    return api.get(url, config)
  },
  
  // POST запрос
  post(url, data = {}, config = {}) {
    return api.post(url, data, config)
  },
  
  // PUT запрос
  put(url, data = {}, config = {}) {
    return api.put(url, data, config)
  },
  
  // PATCH запрос
  patch(url, data = {}, config = {}) {
    return api.patch(url, data, config)
  },
  
  // DELETE запрос
  delete(url, config = {}) {
    return api.delete(url, config)
  },
  
  // Загрузка файла
  uploadFile(url, file, onUploadProgress = null) {
    const formData = new FormData()
    formData.append('file', file)
    
    return api.post(url, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      },
      onUploadProgress
    })
  },
  
  // Множественная загрузка файлов
  uploadFiles(url, files, onUploadProgress = null) {
    const formData = new FormData()
    files.forEach(file => {
      formData.append('files[]', file)
    })
    
    return api.post(url, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      },
      onUploadProgress
    })
  }
}