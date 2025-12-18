import { createRouter, createWebHistory } from "vue-router";
// import Profile from "../views/ProfilePage.vue";
import GeneratedCv from "../views/GeneratedCvPage.vue";

// API
import TestConnection from "../views/TestConnection.vue"

// Auth
import Login from "../views/Auth/AuthLoginPage.vue";
import Register from "../views/Auth/AuthRegisterPage.vue";
import Forgot from "../views/Auth/AuthForgotPage.vue";
import Logout from "../views/Auth/AuthLogoutPage.vue";

// Dashborad
import Dashborad from "../views/Dashboard/DashboardPage.vue";
import AllRequests from "../views/Dashboard/AllRequestsPage.vue";
import JobsCalendar from "../views/Dashboard/JobsCalendarPage.vue";
import NewRequest from "../views/Dashboard/NewRequestPage.vue";
import CVGeneration from "../views/Dashboard/CVGenerationPage.vue";



// Импортируем authService
import authService from "../services/auth.service.js";

const routes = [
  // { path: '/', name: 'Home', component: Home },
  // { path: "/", alias: "/profile", name: "Profile", component: Profile, meta: { requiresAuth: true }, },
  { path: "/", alias: "/login", name: "Login", component: Login, meta: { requiresAuth: false }},
  { path: "/register", name: "Register", component: Register, meta: { requiresAuth: false }},
  { path: "/forgot", name: "Forgot", component: Forgot, meta: { requiresAuth: false }},
  { path: "/logout", name: "Logout", component: Logout, meta: { requiresAuth: false }},

  { path: "/dashboard", name: "Dashborad", component: Dashborad, meta: { requiresAuth: false }},
  { path: "/requests", name: "AllRequests", component: AllRequests, meta: { requiresAuth: false }},
  { path: "/calendar", name: "JobsCalendar", component: JobsCalendar, meta: { requiresAuth: false }},
  { path: "/new-request", name: "NewRequest", component: NewRequest, meta: { requiresAuth: false }},
  { path: "/cv-generation", name: "CVGeneration", component: CVGeneration, meta: { requiresAuth: false }},

  {
    path: "/gen-cv",
    name: "GeneratedCv",
    component: GeneratedCv,
    meta: { requiresAuth: true },
  },
  { 
    path: "/test", 
    name: "TestConnection", 
    component: TestConnection, 
    meta: { requiresAuth: false },
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

// Guard для проверки аутентификации
router.beforeEach((to, from, next) => {
  const isAuthenticated = authService.isAuthenticated()
  const userData = authService.getUserData()

  console.log('🔒 Router Guard:', {
    to: to.path,
    requiresAuth: to.matched.some(record => record.meta.requiresAuth),
    isAuthenticated: isAuthenticated,
    user: userData?.email || 'No user'
  })

  // Страницы требующие авторизации
  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!isAuthenticated) {
      console.log('➡️ Redirecting to login (not authenticated)')
      next("/login")
    } else {
      console.log('✅ Access granted to protected route')
      next()
    }
  } 
  // Страницы логина/регистрации - если уже авторизован, перенаправляем
  else if (to.path === "/login" || to.path === "/register" || to.path === "/forgot") {
    if (isAuthenticated) {
      console.log('➡️ Already authenticated, redirecting to dashboard')
      next("/dashboard")
    } else {
      next()
    }
  } 
  else {
    next()
  }
})

export default router