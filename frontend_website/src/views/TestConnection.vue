<template>
  <div class="p-8">
    <h1 class="text-2xl font-bold mb-6">Test API Connection</h1>
    
    <div class="space-y-4 mb-8">
      <button 
        @click="testPublicApi" 
        class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
      >
        Test Public API
      </button>
      
      <button 
        @click="testCsrf" 
        class="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600"
      >
        Test CSRF Cookie
      </button>
      
      <button 
        @click="testAuth" 
        class="bg-purple-500 text-white px-4 py-2 rounded hover:bg-purple-600"
      >
        Test Auth API
      </button>
    </div>
    
    <div v-if="loading" class="text-gray-600">Loading...</div>
    
    <div v-if="error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
      {{ error }}
    </div>
    
    <div v-if="result" class="bg-gray-100 p-4 rounded">
      <pre class="whitespace-pre-wrap">{{ JSON.stringify(result, null, 2) }}</pre>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import api from '../axios/index.js'  // Добавить .js
import axios from 'axios'  // Импортировать axios отдельно
import authService from '../services/auth.service.js'  // Использовать authService, а не AuthService

const loading = ref(false)
const error = ref('')
const result = ref(null)

const testPublicApi = async () => {
  try {
    loading.value = true
    error.value = ''
    
    const response = await api.get('/test')
    result.value = response.data
    
  } catch (err) {
    error.value = err.message
    result.value = null
  } finally {
    loading.value = false
  }
}

const testCsrf = async () => {
  try {
    loading.value = true
    error.value = ''
    
    const response = await axios.get('http://localhost:8000/sanctum/csrf-cookie', {
      withCredentials: true
    })
    
    result.value = {
      message: 'CSRF cookie получен',
      cookies: document.cookie,
      response: response.data
    }
    
  } catch (err) {
    error.value = err.message
    result.value = null
  } finally {
    loading.value = false
  }
}

const testAuth = async () => {
  try {
    loading.value = true
    error.value = ''
    
    // Сначала логинимся тестовым пользователем
    const loginResponse = await api.post('/auth/login', {
      email: 'test@example.com',
      password: 'password'
    })
    
    if (loginResponse.data.token) {
      authService.setToken(loginResponse.data.token)  // Использовать authService
    }
    
    // Тестируем защищенный маршрут
    const authResponse = await api.get('/auth-test')
    result.value = authResponse.data
    
  } catch (err) {
    error.value = err.response?.data?.message || err.message
    result.value = null
  } finally {
    loading.value = false
  }
}
</script>