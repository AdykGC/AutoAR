// Простой auth service без зависимостей
class AuthService {
  // Получить токен из localStorage
  getToken() {
    return localStorage.getItem('auth_token')
  }
  
  // Получить данные пользователя
  getUserData() {
    const userData = localStorage.getItem('user_data')
    return userData ? JSON.parse(userData) : null
  }
  
  // Установить токен
  setToken(token) {
    localStorage.setItem('auth_token', token)
  }
  
  // Установить данные пользователя
  setUser(user) {
    localStorage.setItem('user_data', JSON.stringify(user))
  }
  
  // Удалить токен
  removeToken() {
    localStorage.removeItem('auth_token')
  }
  
  // Удалить данные пользователя
  removeUser() {
    localStorage.removeItem('user_data')
  }
  
  // Проверить аутентификацию
  isAuthenticated() {
    const token = this.getToken()
    if (!token) return false
    
    // Простая проверка срока действия (24 часа)
    const tokenAge = localStorage.getItem('auth_token_timestamp')
    if (tokenAge) {
      const age = Date.now() - parseInt(tokenAge)
      const twentyFourHours = 24 * 60 * 60 * 1000
      if (age > twentyFourHours) {
        this.removeToken()
        this.removeUser()
        return false
      }
    }
    
    return !!token
  }
  
  // Получить роль пользователя
  getUserRole() {
    const user = this.getUserData()
    return user?.role || null
  }
  
  // Проверить роль
  hasRole(role) {
    const userRole = this.getUserRole()
    return userRole === role
  }
  
  // Получить полное имя
  getFullName() {
    const user = this.getUserData()
    if (!user) return ''
    return `${user.name || ''} ${user.surname || ''}`.trim()
  }
  
  // Получить email
  getEmail() {
    const user = this.getUserData()
    return user?.email || ''
  }
  
  // Логин (альтернативный метод)
  async login(email, password) {
    const response = await fetch('http://localhost:8000/api/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({ email, password }),
      credentials: 'include'
    })
    
    if (!response.ok) {
      throw new Error('Login failed')
    }
    
    const data = await response.json()
    
    if (data.token) {
      this.setToken(data.token)
      if (data.user) {
        this.setUser(data.user)
      }
      // Сохраняем время создания токена
      localStorage.setItem('auth_token_timestamp', Date.now().toString())
    }
    
    return data
  }
  
  // Выход
  async logout() {
    const token = this.getToken()
    
    try {
      await fetch('http://localhost:8000/api/auth/logout', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        credentials: 'include'
      })
    } catch (error) {
      console.error('Logout error:', error)
    } finally {
      this.removeToken()
      this.removeUser()
      localStorage.removeItem('auth_token_timestamp')
    }
  }
}

// Экспортируем экземпляр
const authService = new AuthService()

// Инициализация при загрузке
if (typeof window !== 'undefined') {
  // Проверяем аутентификацию при загрузке
  if (authService.isAuthenticated()) {
    console.log('User is authenticated')
  }
}

export default authService