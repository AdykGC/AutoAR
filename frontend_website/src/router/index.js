import { createRouter, createWebHistory } from 'vue-router'
import Profile from '../views/ProfilePage.vue'
import GeneratedCv from '../views/GeneratedCvPage.vue'
import test from '../views/Test.vue'

const routes = [
  // { path: '/', name: 'Home', component: Home },
  { path: '/profile', name: 'Profile', component: Profile },
  { path: '/gen-cv', name: 'GeneratedCv', component: GeneratedCv },
  { path: '/test', name: 'test', component: test },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
