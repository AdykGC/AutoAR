import { createRouter, createWebHistory } from "vue-router";
import Profile from "../views/ProfilePage.vue";
import GeneratedCv from "../views/GeneratedCvPage.vue";
import test from "../views/Test.vue";

import Auth_Service from "../axios/index";



const routes = [
  // { path: '/', name: 'Home', component: Home },
  {
    path: "/",
    alias: "/profile",
    name: "Profile",
    component: Profile,
    meta: { requiresAuth: true },
  },
  { path: "/gen-cv", name: "GeneratedCv", component: GeneratedCv },
  { path: "/login", name: "test", component: test },
  { path: "/register", name: "test", component: test },
  { path: "/test", name: "test", component: test },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// Вот здесь подключаем guard — после создания router
router.beforeEach((to, from, next) => {
  const token = Auth_Service.getToken();

  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!token) {
      next("/test"); // Нет токена — редиректим
    } else {
      next(); // Есть токен — пускаем
    }
  } else {
    next(); // Маршрут не требует авторизации
  }
});

export default router;
