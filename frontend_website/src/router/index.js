import { createRouter, createWebHistory } from "vue-router";
import authService from "@/services/auth.service.js";

// Импортируем маршруты из разных файлов
import authRouter from './auth.router.js'

const routes = [
  ...authRouter,
  
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
  
  // ========== МАРШРУТЫ МЕНЕДЖЕРА ==========
  
  // Задачи клиентов (Manager)
  { 
    path: "/client-tasks",
    name: "ClientTasksAll",
    component: () => import('@/views/ClientTasks/ClientTasksAllPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO']
    }
  },
  
  { 
    path: "/client-tasks/pending",
    name: "ClientTasksPending",
    component: () => import('@/views/ClientTasks/ClientTasksPendingPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO']
    }
  },
  
  { 
    path: "/client-tasks/:id",
    name: "ClientTaskDetail",
    component: () => import('@/views/ClientTasks/ClientTaskDetailPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO', 'Client', 'Client VIP']
    }
  },
  
  { 
    path: "/client-tasks/:id/edit",
    name: "ClientTaskEdit",
    component: () => import('@/views/ClientTasks/ClientTaskEditPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO']
    }
  },
  
  // Задачи клиентов (Client)
  { 
    path: "/client-tasks/create",
    name: "ClientTaskCreate",
    component: () => import('@/views/ClientTasks/ClientTaskCreatePage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Client', 'Client VIP']
    }
  },
  
  { 
    path: "/client-tasks/my",
    name: "ClientTasksMy",
    component: () => import('@/views/ClientTasks/ClientTasksMyPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Client', 'Client VIP']
    }
  },
  
  // Проекты (Manager)
  { 
    path: "/projects",
    name: "ProjectsAll",
    component: () => import('@/views/Projects/ProjectsPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO', 'Employee']
    }
  },
  
  { 
    path: "/projects/my",
    name: "ProjectsMy",
    component: () => import('@/views/Projects/ProjectsMyPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO', 'Employee']
    }
  },
  
  { 
    path: "/projects/create",
    name: "ProjectCreate",
    component: () => import('@/views/Projects/ProjectCreatePage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO']
    }
  },
  
  { 
    path: "/projects/:id",
    name: "ProjectDetail",
    component: () => import('@/views/Projects/ProjectDetailPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO', 'Employee']
    }
  },
  
  { 
    path: "/projects/:id/edit",
    name: "ProjectEdit",
    component: () => import('@/views/Projects/ProjectEditPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO']
    }
  },
  
  { 
    path: "/projects/:id/stats",
    name: "ProjectStats",
    component: () => import('@/views/Projects/ProjectStatsPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO']
    }
  },
  
  // Задачи проекта (Manager)
  { 
    path: "/project-tasks",
    name: "ProjectTasksAll",
    component: () => import('@/views/ProjectTasks/ProjectTasksMyPage.vue'), // Можно переименовать позже
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO', 'Employee']
    }
  },
  
  { 
    path: "/project-tasks/create",
    name: "ProjectTaskCreate",
    component: () => import('@/views/ProjectTasks/ProjectTaskCreatePage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO']
    }
  },
  
  { 
    path: "/project-tasks/:id",
    name: "ProjectTaskDetail",
    component: () => import('@/views/ProjectTasks/ProjectTaskDetailPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO', 'Employee']
    }
  },
  
  { 
    path: "/project-tasks/:id/edit",
    name: "ProjectTaskEdit",
    component: () => import('@/views/ProjectTasks/ProjectTaskEditPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO']
    }
  },
  
  { 
    path: "/project-tasks/:id/assign",
    name: "ProjectTaskAssign",
    component: () => import('@/views/ProjectTasks/ProjectTaskAssignPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO']
    }
  },
  
  { 
    path: "/project-tasks/:id/time",
    name: "ProjectTaskTime",
    component: () => import('@/views/ProjectTasks/ProjectTaskTimePage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO', 'Employee']
    }
  },
  
  // Команды (Manager)
  { 
    path: "/teams",
    name: "TeamsAll",
    component: () => import('@/views/Teams/TeamsPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO']
    }
  },
  
  { 
    path: "/teams/create",
    name: "TeamCreate",
    component: () => import('@/views/Teams/TeamCreatePage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO']
    }
  },
  
  { 
    path: "/teams/:id",
    name: "TeamDetail",
    component: () => import('@/views/Teams/TeamDetailPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO', 'Employee']
    }
  },
  
  { 
    path: "/teams/:id/edit",
    name: "TeamEdit",
    component: () => import('@/views/Teams/TeamEditPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO']
    }
  },
  
  { 
    path: "/teams/:id/stats",
    name: "TeamStats",
    component: () => import('@/views/Teams/TeamStatsPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO']
    }
  },
  
  { 
    path: "/teams/my",
    name: "TeamMy",
    component: () => import('@/views/Teams/TeamMyPage.vue'),
    meta: { 
      requiresAuth: true, 
      allowedRoles: ['Manager', 'Admin', 'Owner', 'CEO', 'Employee']
    }
  },
  
  // Профиль (все пользователи)
  { 
    path: "/profile",
    name: "Profile",
    component: () => import('@/views/Misc/ProfilePage.vue'),
    meta: { 
      requiresAuth: true 
    }
  },
  
  // Резюме (все пользователи)
  { 
    path: "/cv/generate",
    name: "GenerateCV",
    component: () => import('@/views/Misc/GeneratedCvPage.vue'),
    meta: { 
      requiresAuth: true 
    }
  },
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