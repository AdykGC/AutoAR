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
    return !!this.getToken()
  }
  
  // Получить роль пользователя
  getUserRole() {
    const user = this.getUserData()
    return user?.role || null
  }
  
  // Проверить роль
  hasRole(role) {
    return this.getUserRole() === role
  }
}

// Экспортируем экземпляр
const authService = new AuthService()
export default authService