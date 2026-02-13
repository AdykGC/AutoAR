// src/router/auth.router.js
export default [
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
    }
]
