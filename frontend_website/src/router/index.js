import { createRouter, createWebHistory } from 'vue-router'
import Profile from '../views/ProfilePage.vue'

const routes = [
  // { path: '/', name: 'Home', component: Home },
  { path: '/profile', name: 'Profile', component: Profile },
  // { path: '/about', name: 'About', component: About },
  // { path: '/about', name: 'About', component: About },
  // { path: '/about', name: 'About', component: About },
  // { path: '/about', name: 'About', component: About },
  // { path: '/about', name: 'About', component: About },
  // { path: '/about', name: 'About', component: About },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
