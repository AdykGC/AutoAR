<!-- components/LogoutButton.vue -->
<template>
  <button
    @click="handleLogout"
    class="logout-button"
    :disabled="loading"
  >
    <span v-if="loading">Logging out...</span>
    <span v-else>Logout</span>
  </button>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import authService from '../../services/auth.service.js'

const router = useRouter()
const loading = ref(false)

const handleLogout = async () => {
  try {
    loading.value = true
    
    if (confirm('Are you sure you want to logout?')) {
      await authService.logout()
      console.log('✅ Logout successful')
      router.push('/login')
    }
  } catch (err) {
    console.error('❌ Logout error:', err)
    alert('Logout failed: ' + err.message)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.logout-button {
  padding: 0.5rem 1rem;
  background-color: #dc2626;
  color: white;
  border-radius: 0.375rem;
  font-weight: 500;
  transition: background-color 0.2s;
}

.logout-button:hover:not(:disabled) {
  background-color: #b91c1c;
}

.logout-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>