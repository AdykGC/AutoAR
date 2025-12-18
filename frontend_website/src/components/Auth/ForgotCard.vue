<template>
  <div class="relative flex min-h-screen w-full flex-col items-center justify-center overflow-x-hidden p-4">
    <div class="flex w-full max-w-md flex-col items-center space-y-8 py-10">
      <!-- Logo -->
      <div class="flex flex-col items-center space-y-2">
        <div class="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10 dark:bg-primary/20">
          <span class="material-symbols-outlined text-3xl text-primary">
            autorenew
          </span>
        </div>
        <h2 class="text-2xl font-bold text-slate-800 dark:text-slate-200">AutoAr</h2>
      </div>

      <!-- Card -->
      <div class="w-full rounded-xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-background-dark/50 md:p-8">
        <div class="flex flex-col items-center">
          <!-- HeadlineText -->
          <h1 class="pb-2 pt-2 text-center text-[28px] font-bold leading-tight tracking-tight text-[#0d121b] dark:text-white">
            Forgot Your Password?
          </h1>
          
          <!-- BodyText -->
          <p class="px-4 pb-6 pt-1 text-center text-base font-normal leading-normal text-slate-600 dark:text-slate-400">
            No problem. Enter the email address associated with your AutoAr account, and we'll send you a link to reset your password.
          </p>

          <!-- Сообщение об успехе/ошибке -->
          <div v-if="message" 
            :class="`mb-4 w-full p-3 rounded-lg text-sm ${message.type === 'success' ? 'bg-green-50 text-green-700 dark:bg-green-900/30 dark:text-green-300' : 'bg-red-50 text-red-700 dark:bg-red-900/30 dark:text-red-300'}`"
          >
            {{ message.text }}
          </div>

          <div class="flex w-full flex-col items-stretch space-y-4">
            <!-- TextField -->
            <div class="flex w-full flex-wrap items-end">
              <label class="flex w-full flex-1 flex-col">
                <p class="pb-2 text-sm font-medium leading-normal text-[#0d121b] dark:text-slate-300">
                  Email Address
                </p>
                <div class="group/input flex w-full flex-1 items-stretch rounded-lg border border-slate-300 bg-background-light focus-within:border-primary dark:border-slate-700 dark:bg-background-dark">
                  <div class="flex items-center justify-center pl-4 pr-2">
                    <span class="material-symbols-outlined text-slate-400 group-focus-within/input:text-primary dark:text-slate-500">
                      mail
                    </span>
                  </div>
                  <input 
                    v-model="email"
                    class="form-input flex min-w-0 flex-1 resize-none overflow-hidden border-0 bg-transparent p-3 text-base font-normal leading-normal text-[#0d121b] placeholder:text-slate-400 focus:outline-0 focus:ring-0 dark:text-white dark:placeholder:text-slate-500"
                    placeholder="Enter your email address"
                    type="email"
                    required
                  />
                </div>
              </label>
            </div>

            <!-- SingleButton -->
            <div class="flex w-full justify-center pt-2">
              <button 
                @click="handleSubmit"
                :disabled="loading"
                class="flex h-11 min-w-[84px] max-w-[480px] flex-1 cursor-pointer items-center justify-center overflow-hidden rounded-lg bg-primary px-5 text-base font-bold leading-normal tracking-[0.015em] text-white transition-colors hover:bg-primary/90 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span class="truncate">
                  <span v-if="loading">Sending...</span>
                  <span v-else>Send Instructions</span>
                </span>
              </button>
            </div>
          </div>

          <!-- MetaText -->
          <p class="pt-6 text-center text-sm font-normal leading-normal text-slate-600 dark:text-slate-400">
            Remember your password? 
            <router-link class="font-medium text-primary hover:text-primary/80" to="/login">
              Back to Login
            </router-link>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import api from '../../axios/index.js'

const router = useRouter()

const email = ref('')
const loading = ref(false)
const message = ref(null)

const handleSubmit = async () => {
  if (!email.value) {
    message.value = { type: 'error', text: 'Please enter your email address' }
    return
  }

  if (!email.value.includes('@')) {
    message.value = { type: 'error', text: 'Please enter a valid email address' }
    return
  }

  try {
    loading.value = true
    message.value = null

    // В реальном приложении здесь будет вызов API
    // const response = await api.post('/auth/forgot-password', { email: email.value })
    
    // Имитация задержки API
    await new Promise(resolve => setTimeout(resolve, 1500))

    // Успешное сообщение
    message.value = {
      type: 'success',
      text: `Password reset instructions have been sent to ${email.value}. Please check your email.`
    }

    // Очистить поле ввода
    email.value = ''

    // Через 5 секунд перенаправить на логин
    setTimeout(() => {
      router.push('/login')
    }, 5000)

  } catch (error) {
    console.error('Password reset error:', error)
    message.value = {
      type: 'error',
      text: error.response?.data?.message || 'Failed to send reset instructions. Please try again.'
    }
  } finally {
    loading.value = false
  }
}
</script>