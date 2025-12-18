// Простой auth service без зависимостей
class AuthService {
  // Получить токен из localStorage
  getToken() {
    return localStorage.getItem('auth_token')
  }
  
  // Получить данные пользователя
  getUserData() {
    const userData = localStorage.getItem('user_data')
    try {
      return userData ? JSON.parse(userData) : null
    } catch {
      return null
    }
  }
  
  // Установить токен
  setToken(token) {
    localStorage.setItem('auth_token', token)
    localStorage.setItem('auth_token_timestamp', Date.now().toString())
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
    return !!token
  }
  
  // Получить роль пользователя
  getUserRole() {
    const user = this.getUserData()
    return user?.roles?.[0]?.name || null
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
  
  // Логин (исправленный под вашу структуру)
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
    
    const data = await response.json()
    
    if (!response.ok) {
      throw new Error(data.message || 'Login failed')
    }
    
    // Ваша структура: data.success, data.data.token, data.data.user
    if (data.success && data.data) {
      const token = data.data.token
      const user = data.data.user
      
      if (token) {
        this.setToken(token)
        if (user) {
          this.setUser(user)
        }
        return data
      }
    }
    
    throw new Error(data.message || 'Login failed')
  }
  
  // Регистрация
  async register(userData) {
    const response = await fetch('http://localhost:8000/api/auth/register', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify(userData),
      credentials: 'include'
    })
    
    const data = await response.json()
    
    if (!response.ok) {
      throw new Error(data.message || 'Registration failed')
    }
    
    // Та же структура: data.success, data.data.token, data.data.user
    if (data.success && data.data) {
      const token = data.data.token
      const user = data.data.user
      
      if (token) {
        this.setToken(token)
        if (user) {
          this.setUser(user)
        }
        return data
      }
    }
    
    throw new Error(data.message || 'Registration failed')
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

    // ... существующие методы ...
  
  // Получить роль пользователя
  getUserRole() {
    const user = this.getUserData()
    
    if (!user) return null
    
    // Если roles - это массив объектов
    if (Array.isArray(user.roles) && user.roles.length > 0) {
      return user.roles[0].name || null
    }
    
    // Если roles - это строка
    if (typeof user.roles === 'string') {
      return user.roles
    }
    
    // Если role - это свойство объекта user
    if (user.role) {
      return user.role
    }
    
    return null
  }
  
  // Получить все роли пользователя
  getUserRoles() {
    const user = this.getUserData()
    
    if (!user) return []
    
    if (Array.isArray(user.roles)) {
      return user.roles.map(role => role.name || role)
    }
    
    if (typeof user.roles === 'string') {
      return [user.roles]
    }
    
    return []
  }
  
  // Проверить есть ли у пользователя определенная роль
  hasRole(role) {
    const userRoles = this.getUserRoles()
    return userRoles.includes(role)
  }
  
  // Проверить является ли пользователь клиентом
  isClient() {
    const userRole = this.getUserRole()
    return userRole === 'Client' || userRole === 'Client VIP'
  }
  
  // Проверить является ли пользователь менеджером
  isManager() {
    const userRole = this.getUserRole()
    return ['Manager', 'Admin', 'Owner', 'CEO'].includes(userRole)
  }
  
  // Проверить является ли пользователь сотрудником
  isEmployee() {
    const userRole = this.getUserRole()
    return userRole === 'Employee'
  }
}

// Экспортируем экземпляр
const authService = new AuthService()

export default authService