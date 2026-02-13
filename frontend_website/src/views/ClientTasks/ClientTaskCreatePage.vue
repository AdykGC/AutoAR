<!-- src/views/ClientTasks/ClientTaskCreatePage.vue -->
<template>
  <div class="client-task-create-page">
    <div class="page-container">
      <!-- Кнопка назад -->
      <div class="back-nav">
        <router-link to="/dashboard/client" class="back-link">
          ← Вернуться в дашборд
        </router-link>
      </div>
      
      <!-- Заголовок страницы -->
      <div class="page-header">
        <h1>Создание новой задачи</h1>
        <p class="page-subtitle">Заполните форму, чтобы отправить задачу на выполнение</p>
      </div>
      
      <!-- Хлебные крошки -->
      <div class="breadcrumbs">
        <router-link to="/dashboard/client" class="breadcrumb">Дашборд</router-link>
        <span class="breadcrumb-separator">/</span>
        <router-link to="/client-tasks/my" class="breadcrumb">Мои задачи</router-link>
        <span class="breadcrumb-separator">/</span>
        <span class="breadcrumb active">Новая задача</span>
      </div>
      
      <!-- Компонент формы -->
      <TaskForm />
      
      <!-- Информационный блок -->
      <div class="info-section">
        <div class="info-card">
          <div class="info-icon">💡</div>
          <div class="info-content">
            <h3>Как правильно создать задачу?</h3>
            <ul class="info-list">
              <li>📌 <strong>Будьте конкретны</strong> в описании задачи</li>
              <li>⏰ <strong>Укажите реалистичный дедлайн</strong> при необходимости</li>
              <li>💰 <strong>Предварительный бюджет</strong> поможет быстрее оценить задачу</li>
              <li>📎 <strong>Прикрепите файлы</strong> если есть примеры или требования</li>
              <li>📞 <strong>Менеджер свяжется с вами</strong> для уточнения деталей</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import TaskForm from '@/components/TaskComponents/TaskForm.vue'

export default {
  name: 'ClientTaskCreatePage',
  components: {
    TaskForm
  },
  
  setup() {
    return {}
  }
}
</script>

<style scoped>
.client-task-create-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #f8fafc 0%, #eef2ff 100%);
}

.page-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px;
}

.back-nav {
  margin-bottom: 24px;
}

.back-link {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: #64748b;
  text-decoration: none;
  font-weight: 500;
  padding: 8px 16px;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.back-link:hover {
  color: #4f46e5;
  background: #eef2ff;
}

.page-header {
  text-align: center;
  margin-bottom: 32px;
}

.page-header h1 {
  margin: 0 0 8px 0;
  color: #1e293b;
  font-size: 36px;
  background: linear-gradient(90deg, #4f46e5, #7c3aed);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.page-subtitle {
  margin: 0;
  color: #64748b;
  font-size: 18px;
}

.breadcrumbs {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 32px;
  padding: 16px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.breadcrumb {
  color: #64748b;
  text-decoration: none;
  font-size: 14px;
  transition: color 0.2s ease;
}

.breadcrumb:hover {
  color: #4f46e5;
}

.breadcrumb.active {
  color: #1e293b;
  font-weight: 500;
}

.breadcrumb-separator {
  color: #cbd5e1;
}

.info-section {
  margin-top: 48px;
}

.info-card {
  display: flex;
  gap: 24px;
  padding: 32px;
  background: linear-gradient(135deg, #e0e7ff, #ede9fe);
  border-radius: 20px;
  border: 2px solid #c7d2fe;
}

.info-icon {
  font-size: 48px;
  flex-shrink: 0;
}

.info-content h3 {
  margin: 0 0 16px 0;
  color: #1e293b;
  font-size: 20px;
}

.info-list {
  margin: 0;
  padding: 0;
  list-style: none;
}

.info-list li {
  margin-bottom: 12px;
  padding-left: 8px;
  color: #475569;
}

.info-list li:last-child {
  margin-bottom: 0;
}

@media (max-width: 768px) {
  .page-container {
    padding: 16px;
  }
  
  .page-header h1 {
    font-size: 28px;
  }
  
  .breadcrumbs {
    flex-wrap: wrap;
  }
  
  .info-card {
    flex-direction: column;
    padding: 24px;
  }
}
</style>