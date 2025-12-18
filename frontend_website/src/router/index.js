import { createRouter, createWebHistory } from "vue-router";
import authService from "@/services/auth.service.js";

const routes = [
  // Auth
  { 
    path: "/", 
    alias: "/login", 
    name: "Login", 
    component: () => import('@/views/Auth/AuthLoginPage.vue'), 
    meta: { requiresAuth: false }
  },
  { 
    path: "/register", 
    name: "Register", 
    component: () => import('@/views/Auth/AuthRegisterPage.vue'), 
    meta: { requiresAuth: false }
  },
  { 
    path: "/forgot", 
    name: "Forgot", 
    component: () => import('@/views/Auth/AuthForgotPage.vue'), 
    meta: { requiresAuth: false }
  },
  { 
    path: "/logout", 
    name: "Logout", 
    component: () => import('@/views/Auth/AuthLogoutPage.vue'), 
    meta: { requiresAuth: true }
  },
  
  // Тестовая страница
  { 
    path: "/test", 
    name: "TestConnection", 
    component: () => import('@/views/TestConnection.vue'), 
    meta: { requiresAuth: false }
  },

  // Дашборды
  { 
    path: '/dashboard', 
    redirect: (to) => {
      // Определяем дашборд по роли
      const userRole = authService.getUserRole()
      
      if (userRole === 'Client' || userRole === 'Client VIP') {
        return '/dashboard/client'
      } else if (userRole === 'Manager' || userRole === 'Admin' || userRole === 'Owner' || userRole === 'CEO') {
        return '/dashboard/manager'
      } else if (userRole === 'Employee') {
        return '/dashboard/employee'
      }
      
      return '/dashboard/client' // По умолчанию
    },
    meta: { requiresAuth: true }
  },
  { 
    path: '/dashboard/client', 
    name: 'DashboardClient',
    component: () => import('@/views/Dashboard/DashboardClientPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Client', 'Client VIP']
    }
  },
  { 
    path: '/dashboard/manager', 
    name: 'DashboardManager',
    component: () => import('@/views/Dashboard/DashboardManagerPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO']
    }
  },
  { 
    path: '/dashboard/employee', 
    name: 'DashboardEmployee',
    component: () => import('@/views/Dashboard/DashboardEmployeePage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Employee']
    }
  },
  
  // Остальные маршруты остаются как есть...
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

// Функция для проверки доступа по ролям
const checkRoleAccess = (allowedRoles, userRole) => {
  if (!allowedRoles || allowedRoles.length === 0) {
    return true // Если роли не указаны, доступ открыт
  }
  
  if (!userRole) {
    return false // Если у пользователя нет роли, доступ запрещен
  }
  
  // Проверяем совпадение роли
  return allowedRoles.includes(userRole)
}

// Guard для проверки аутентификации и ролей
router.beforeEach((to, from, next) => {
  const isAuthenticated = authService.isAuthenticated()
  const userData = authService.getUserData()
  const userRole = authService.getUserRole()

  console.log('🔒 Router Guard:', {
    to: to.path,
    requiresAuth: to.meta.requiresAuth || false,
    allowedRoles: to.meta.allowedRoles || [],
    isAuthenticated: isAuthenticated,
    userRole: userRole,
    user: userData?.email || 'No user'
  })

  // Страницы требующие авторизации
  if (to.meta.requiresAuth) {
    if (!isAuthenticated) {
      console.log('➡️ Redirecting to login (not authenticated)')
      next("/login")
    } else {
      // Проверяем доступ по ролям
      const allowedRoles = to.meta.allowedRoles || []
      
      if (checkRoleAccess(allowedRoles, userRole)) {
        console.log('✅ Access granted to protected route')
        next()
      } else {
        console.log('⛔ Access denied: role mismatch')
        
        // Перенаправляем на правильный дашборд по роли
        let redirectPath = '/dashboard'
        
        if (userRole === 'Client' || userRole === 'Client VIP') {
          redirectPath = '/dashboard/client'
        } else if (['Manager', 'Admin', 'Owner', 'CEO'].includes(userRole)) {
          redirectPath = '/dashboard/manager'
        } else if (userRole === 'Employee') {
          redirectPath = '/dashboard/employee'
        }
        
        next(redirectPath)
      }
    }
  } 
  // Страницы логина/регистрации - если уже авторизован, перенаправляем
  else if (to.path === "/login" || to.path === "/register" || to.path === "/forgot") {
    if (isAuthenticated) {
      console.log('➡️ Already authenticated, redirecting to dashboard')
      
      // Перенаправляем на правильный дашборд по роли
      let redirectPath = '/dashboard'
      
      if (userRole === 'Client' || userRole === 'Client VIP') {
        redirectPath = '/dashboard/client'
      } else if (['Manager', 'Admin', 'Owner', 'CEO'].includes(userRole)) {
        redirectPath = '/dashboard/manager'
      } else if (userRole === 'Employee') {
        redirectPath = '/dashboard/employee'
      }
      
      next(redirectPath)
    } else {
      next()
    }
  } 
  // Тестовая страница - доступ для всех
  else if (to.path === "/test") {
    next()
  }
  // Все остальные маршруты
  else {
    next()
  }
})

export default router