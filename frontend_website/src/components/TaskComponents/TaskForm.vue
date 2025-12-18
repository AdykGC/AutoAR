<script setup>
import { ref } from 'vue'
import taskService from '@/services/task.service'

const loading = ref(false)
const error = ref(null)

const form = ref({
  title: '',
  description: '',
  priority: '2'
})

const submit = async () => {
  loading.value = true
  error.value = null

  try {
    await taskService.createTask(form.value)

    // очистка формы
    form.value = {
      title: '',
      description: '',
      priority: '2'
    }

    // можно эмитить событие обновления списка
    alert('Задача создана')
  } catch (e) {
    error.value = 'Ошибка при создании задачи'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <form @submit.prevent="submit" class="task-form">
    <input
      v-model="form.title"
      placeholder="Название задачи"
      required
    />

    <textarea
      v-model="form.description"
      placeholder="Описание"
    />

    <select v-model="form.priority">
      <option value="1">Высокий</option>
      <option value="2">Средний</option>
      <option value="3">Низкий</option>
    </select>

    <button :disabled="loading">
      {{ loading ? 'Создание...' : 'Создать задачу' }}
    </button>

    <p v-if="error" class="error">{{ error }}</p>
  </form>
</template>
