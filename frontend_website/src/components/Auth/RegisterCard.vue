<template>
  <div class="relative flex min-h-screen w-full flex-col overflow-x-hidden">
    <div class="layout-container flex h-full grow flex-col">
      <main class="flex flex-1 items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div class="w-full max-w-md space-y-8">
          <div class="flex flex-col gap-3 text-center">
            <p class="text-[#0d121b] dark:text-white text-3xl sm:text-4xl font-black leading-tight tracking-[-0.033em]">
              Create your Employee Account
            </p>
            <p class="text-gray-600 dark:text-gray-400 text-base font-normal leading-normal">
              Join AutoAr to streamline approvals and automate your workflow.
            </p>
          </div>

          <div class="bg-white dark:bg-background-dark/50 rounded-xl shadow-lg p-6 sm:p-8 border border-gray-200 dark:border-gray-800">
            <!-- Табы для переключения -->
            <div class="flex h-10 flex-1 items-center justify-center rounded-lg bg-[#e7ebf3] dark:bg-gray-800 p-1 mb-6">
              <router-link 
                to="/login"
                class="flex cursor-pointer h-full grow items-center justify-center overflow-hidden rounded-lg px-2 text-sm font-medium leading-normal transition-all"
                :class="{
                  'bg-white dark:bg-gray-700 text-[#0d121b] dark:text-white shadow-[0_1px_3px_rgba(0,0,0,0.1)]': $route.path === '/login',
                  'text-gray-500 dark:text-gray-400 hover:bg-white dark:hover:bg-gray-700 hover:text-[#0d121b] dark:hover:text-white': $route.path !== '/login'
                }"
              >
                <span class="truncate">Sign In</span>
              </router-link>

              <router-link 
                to="/register"
                class="flex cursor-pointer h-full grow items-center justify-center overflow-hidden rounded-lg px-2 text-sm font-medium leading-normal transition-all"
                :class="{
                  'bg-white dark:bg-gray-700 text-[#0d121b] dark:text-white shadow-[0_1px_3px_rgba(0,0,0,0.1)]': $route.path === '/register',
                  'text-gray-500 dark:text-gray-400 hover:bg-white dark:hover:bg-gray-700 hover:text-[#0d121b] dark:hover:text-white': $route.path !== '/register'
                }"
              >
                <span class="truncate">Register</span>
              </router-link>
            </div>

            <!-- Сообщение об ошибке -->
            <div v-if="error" class="mb-4 p-3 bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-800 rounded-lg">
              <p class="text-red-700 dark:text-red-300 text-sm">{{ error }}</p>
            </div>

            <!-- Форма регистрации -->
            <form @submit.prevent="handleRegister" class="space-y-6">
              <div class="space-y-4">
                <!-- Имя и Фамилия -->
                <div class="flex flex-col sm:flex-row gap-4">
                  <label class="flex flex-col flex-1">
                    <p class="text-[#0d121b] dark:text-gray-200 text-sm font-medium leading-normal pb-2">
                      Name
                    </p>
                    <div class="relative flex w-full flex-1 items-stretch">
                      <div class="text-gray-400 dark:text-gray-500 pointer-events-none absolute inset-y-0 left-0 flex items-center justify-center pl-4">
                        <span class="material-symbols-outlined text-xl">person</span>
                      </div>
                      <input 
                        v-model="registerForm.name"
                        class="form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden rounded-lg text-[#0d121b] dark:text-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/50 border border-gray-300 dark:border-gray-700 bg-background-light dark:bg-gray-800 focus:border-primary h-12 placeholder:text-gray-400 dark:placeholder:text-gray-500 pl-12 pr-4 text-base font-normal leading-normal"
                        placeholder="John"
                        type="text"
                        required
                      />
                    </div>
                  </label>
                  
                  <label class="flex flex-col flex-1">
                    <p class="text-[#0d121b] dark:text-gray-200 text-sm font-medium leading-normal pb-2">
                      Surname
                    </p>
                    <div class="relative flex w-full flex-1 items-stretch">
                      <div class="text-gray-400 dark:text-gray-500 pointer-events-none absolute inset-y-0 left-0 flex items-center justify-center pl-4">
                        <span class="material-symbols-outlined text-xl">person</span>
                      </div>
                      <input 
                        v-model="registerForm.surname"
                        class="form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden rounded-lg text-[#0d121b] dark:text-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/50 border border-gray-300 dark:border-gray-700 bg-background-light dark:bg-gray-800 focus:border-primary h-12 placeholder:text-gray-400 dark:placeholder:text-gray-500 pl-12 pr-4 text-base font-normal leading-normal"
                        placeholder="Doe"
                        type="text"
                        required
                      />
                    </div>
                  </label>
                </div>

                <!-- Email -->
                <label class="flex flex-col flex-1">
                  <p class="text-[#0d121b] dark:text-gray-200 text-sm font-medium leading-normal pb-2">
                    Email
                  </p>
                  <div class="relative flex w-full flex-1 items-stretch">
                    <div class="text-gray-400 dark:text-gray-500 pointer-events-none absolute inset-y-0 left-0 flex items-center justify-center pl-4">
                      <span class="material-symbols-outlined text-xl">mail</span>
                    </div>
                    <input 
                      v-model="registerForm.email"
                      class="form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden rounded-lg text-[#0d121b] dark:text-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/50 border border-gray-300 dark:border-gray-700 bg-background-light dark:bg-gray-800 focus:border-primary h-12 placeholder:text-gray-400 dark:placeholder:text-gray-500 pl-12 pr-4 text-base font-normal leading-normal"
                      placeholder="you@yourcompany.com"
                      type="email"
                      required
                    />
                  </div>
                </label>

                <!-- Phone (необязательный) -->
                <label class="flex flex-col flex-1">
                  <p class="text-[#0d121b] dark:text-gray-200 text-sm font-medium leading-normal pb-2">
                    Phone (optional)
                  </p>
                  <div class="relative flex w-full flex-1 items-stretch">
                    <div class="text-gray-400 dark:text-gray-500 pointer-events-none absolute inset-y-0 left-0 flex items-center justify-center pl-4">
                      <span class="material-symbols-outlined text-xl">phone</span>
                    </div>
                    <input 
                      v-model="registerForm.phone"
                      class="form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden rounded-lg text-[#0d121b] dark:text-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/50 border border-gray-300 dark:border-gray-700 bg-background-light dark:bg-gray-800 focus:border-primary h-12 placeholder:text-gray-400 dark:placeholder:text-gray-500 pl-12 pr-4 text-base font-normal leading-normal"
                      placeholder="+1 (555) 123-4567"
                      type="tel"
                    />
                  </div>
                </label>

                <!-- Role (обязательный) -->
                <label class="flex flex-col flex-1">
                  <p class="text-[#0d121b] dark:text-gray-200 text-sm font-medium leading-normal pb-2">
                    Role *
                  </p>
                  <div class="relative flex w-full flex-1 items-stretch">
                    <div class="text-gray-400 dark:text-gray-500 pointer-events-none absolute inset-y-0 left-0 flex items-center justify-center pl-4">
                      <span class="material-symbols-outlined text-xl">badge</span>
                    </div>
                    <select 
                      v-model="registerForm.role"
                      class="form-select flex w-full min-w-0 flex-1 resize-none overflow-hidden rounded-lg text-[#0d121b] dark:text-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/50 border border-gray-300 dark:border-gray-700 bg-background-light dark:bg-gray-800 focus:border-primary h-12 placeholder:text-gray-400 dark:placeholder:text-gray-500 pl-12 pr-10 text-base font-normal leading-normal appearance-none"
                      required
                    >
                      <option value="" disabled selected>Select your role</option>
                      <option value="Client">Client</option>
                      <option value="Client VIP">Client VIP</option>
                      <option value="Employee">Employee</option>
                      <option value="Manager">Manager</option>
                    </select>
                    <div class="text-gray-400 dark:text-gray-500 pointer-events-none absolute inset-y-0 right-0 flex items-center justify-center pr-4">
                      <span class="material-symbols-outlined text-xl">arrow_drop_down</span>
                    </div>
                  </div>
                  <p class="text-gray-500 dark:text-gray-400 text-xs mt-1">
                    Available roles: Client, Client VIP, Employee, Manager
                  </p>
                </label>

                <!-- Password -->
                <div class="flex flex-col flex-1">
                  <label>
                    <p class="text-[#0d121b] dark:text-gray-200 text-sm font-medium leading-normal pb-2">
                      Create Password
                    </p>
                    <div class="relative flex w-full flex-1 items-stretch">
                      <div class="text-gray-400 dark:text-gray-500 pointer-events-none absolute inset-y-0 left-0 flex items-center justify-center pl-4">
                        <span class="material-symbols-outlined text-xl">lock</span>
                      </div>
                      <input 
                        v-model="registerForm.password"
                        :type="showPassword ? 'text' : 'password'"
                        class="form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden rounded-lg text-[#0d121b] dark:text-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/50 border border-gray-300 dark:border-gray-700 bg-background-light dark:bg-gray-800 focus:border-primary h-12 placeholder:text-gray-400 dark:placeholder:text-gray-500 pl-12 pr-12 text-base font-normal leading-normal"
                        placeholder="Enter a strong password"
                        required
                      />
                      <button 
                        @click="showPassword = !showPassword"
                        type="button"
                        class="text-gray-400 dark:text-gray-500 absolute inset-y-0 right-0 flex cursor-pointer items-center justify-center pr-4"
                      >
                        <span class="material-symbols-outlined text-xl">
                          {{ showPassword ? 'visibility_off' : 'visibility' }}
                        </span>
                      </button>
                    </div>
                  </label>
                </div>

                <!-- Confirm Password -->
                <div class="flex flex-col flex-1">
                  <label>
                    <p class="text-[#0d121b] dark:text-gray-200 text-sm font-medium leading-normal pb-2">
                      Confirm Password
                    </p>
                    <div class="relative flex w-full flex-1 items-stretch">
                      <div class="text-gray-400 dark:text-gray-500 pointer-events-none absolute inset-y-0 left-0 flex items-center justify-center pl-4">
                        <span class="material-symbols-outlined text-xl">lock</span>
                      </div>
                      <input 
                        v-model="registerForm.password_confirmation"
                        :type="showConfirmPassword ? 'text' : 'password'"
                        class="form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden rounded-lg text-[#0d121b] dark:text-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/50 border border-gray-300 dark:border-gray-700 bg-background-light dark:bg-gray-800 focus:border-primary h-12 placeholder:text-gray-400 dark:placeholder:text-gray-500 pl-12 pr-12 text-base font-normal leading-normal"
                        placeholder="Confirm your password"
                        required
                      />
                      <button 
                        @click="showConfirmPassword = !showConfirmPassword"
                        type="button"
                        class="text-gray-400 dark:text-gray-500 absolute inset-y-0 right-0 flex cursor-pointer items-center justify-center pr-4"
                      >
                        <span class="material-symbols-outlined text-xl">
                          {{ showConfirmPassword ? 'visibility_off' : 'visibility' }}
                        </span>
                      </button>
                    </div>
                  </label>
                </div>
              </div>

              <button 
                :disabled="loading"
                class="group relative flex w-full justify-center rounded-lg bg-primary py-3 px-4 text-sm font-semibold text-white hover:bg-primary/90 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 dark:focus:ring-offset-background-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                type="submit"
              >
                <span v-if="loading">Creating Account...</span>
                <span v-else>Create Account</span>
              </button>

              <div class="text-center text-sm text-gray-500 dark:text-gray-400 pt-2">
                Already have an account? Click the Sign In button above.
              </div>
            </form>
          </div>
        </div>
      </main>

      <footer class="w-full mt-auto px-4 sm:px-6 lg:px-8 py-5">
        <div class="text-center text-sm text-gray-500 dark:text-gray-400 space-x-4">
          <span>© 2025 AutoAr.</span>
          <router-link to="/test" class="text-primary hover:text-primary/80">
            API Test
          </router-link>
        </div>
      </footer>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import authService from '../../services/auth.service.js' // Используем ваш authService

const router = useRouter()

// Состояния
const loading = ref(false)
const error = ref('')
const showPassword = ref(false)
const showConfirmPassword = ref(false)

// Правильная форма регистрации
const registerForm = reactive({
  name: '',
  surname: '',
  email: '',
  phone: '',
  password: '',
  password_confirmation: '',
  role: ''
})

// Автозаполнение для тестирования
onMounted(() => {
  const randomNum = Math.floor(Math.random() * 10000)
  registerForm.name = 'John'
  registerForm.surname = 'Doe'
  registerForm.email = `test${randomNum}@example.com`
  registerForm.phone = ''
  registerForm.password = 'password123'
  registerForm.password_confirmation = 'password123'
  registerForm.role = 'Employee'
})

// Регистрация с использованием authService
const handleRegister = async () => {
  try {
    loading.value = true
    error.value = ''

    // Валидация
    if (!registerForm.name || !registerForm.email || !registerForm.password || !registerForm.role) {
      error.value = 'Please fill all required fields'
      loading.value = false
      return
    }

    if (registerForm.password !== registerForm.password_confirmation) {
      error.value = 'Passwords do not match'
      loading.value = false
      return
    }

    if (registerForm.password.length < 8) {
      error.value = 'Password must be at least 8 characters'
      loading.value = false
      return
    }

    // Подготовка данных для отправки
    const requestData = {
      name: registerForm.name,
      surname: registerForm.surname || null,
      email: registerForm.email,
      phone: registerForm.phone || null,
      password: registerForm.password,
      password_confirmation: registerForm.password_confirmation,
      role: registerForm.role
    }

    console.log('📤 Attempting registration...')

    // Используем authService для регистрации
    const response = await authService.register(requestData)
    
    console.log('✅ Registration successful via authService')
    
    // Проверяем, что пользователь сохранен
    const userData = authService.getUserData()
    const token = authService.getToken()
    
    if (token && userData) {
      console.log('✅ Token and user data saved after registration')
      console.log('- User:', userData.email)
      console.log('- Role:', userData.roles?.[0]?.name)
      
      alert('Registration successful!')
      
      // Перенаправляем на дашборд
      router.push('/dashboard')
    } else {
      error.value = 'Registration successful but data not saved properly'
    }
    
  } catch (err) {
    console.error('❌ Registration error:', err.message)
    error.value = err.message || 'Registration failed. Please try again.'
  } finally {
    loading.value = false
  }
}
</script>