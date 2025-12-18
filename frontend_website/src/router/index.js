import { createRouter, createWebHistory } from "vue-router";
import Profile from "../views/ProfilePage.vue";
import GeneratedCv from "../views/GeneratedCvPage.vue";
import Login from "../views/AuthLoginPage.vue";
import Register from "../views/AuthRegisterPage.vue";
import TestConnection from "../views/TestConnection.vue"

// Импортируем authService
import authService from "../services/auth.service.js";

const routes = [
  // { path: '/', name: 'Home', component: Home },
  { path: "/login", name: "Login", component: Login },
  { path: "/register", name: "Register", component: Register },
  {
    path: "/",
    alias: "/profile",
    name: "Profile",
    component: Profile,
    meta: { requiresAuth: true },
  },
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
  routes,
});

// Guard для проверки аутентификации
router.beforeEach((to, from, next) => {
  const token = authService.getToken();

  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!token) { 
      next("/login"); 
    } else { 
      next(); 
    }
  } 
  else if (to.path === "/login" || to.path === "/register") {
    if (token) { 
      next("/profile"); 
    } else { 
      next(); 
    }
  } 
  else { 
    next(); 
  }
});

export default router;