import axios from 'axios'

// Базовый URL API
const API_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000'

// Создаем основной экземпляр axios для API
const api = axios.create({
  baseURL: `${API_URL}/api`,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest'
  },
  withCredentials: true, // ВАЖНО для работы с cookies
})

// Интерсептор для обработки запросов
api.interceptors.request.use(
  (config) => {
    // Добавляем токен авторизации из localStorage
    const token = localStorage.getItem('auth_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Интерсептор для обработки ответов
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config
    
    // Если ошибка 401 (не авторизован) и мы еще не пытались обновить запрос
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true
      
      try {
        // Очищаем старый токен
        localStorage.removeItem('auth_token')
        localStorage.removeItem('user_data')
        
        // Перенаправляем на страницу логина
        if (window.location.pathname !== '/login') {
          window.location.href = '/login'
        }
      } catch (refreshError) {
        console.error('Token refresh error:', refreshError)
      }
    }
    
    return Promise.reject(error)
  }
)

// Экспортируем экземпляр api по умолчанию
export default api