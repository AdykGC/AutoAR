<template>
  <BaseManagerPage 
    title="Дашборд менеджера"
    subtitle="Обзор всех проектов, задач и команд"
    :loading="loading"
    :error="error"
    :items="recentActivities"
    show-filters
    show-search
    show-refresh
    :show-back-button="false"
  >
    <template #header-actions>
      <button @click="showCreateModal = true" style="padding: 8px 15px;">
        + Создать проект
      </button>
    </template>

    <!-- Статистика -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 30px;">
      <ManagerCard title="Проекты" :subtitle="`Всего: ${stats.totalProjects || 0}`">
        <div style="font-size: 24px; font-weight: bold;">
          {{ stats.activeProjects || 0 }} активных
        </div>
        <div style="margin-top: 10px; color: #666;">
          <div>В работе: {{ stats.inProgressProjects || 0 }}</div>
          <div>Завершено: {{ stats.completedProjects || 0 }}</div>
        </div>
      </ManagerCard>

      <ManagerCard title="Задачи клиентов" :subtitle="`Всего: ${stats.totalClientTasks || 0}`">
        <div style="font-size: 24px; font-weight: bold; color: #e74c3c;">
          {{ stats.pendingClientTasks || 0 }} ожидают
        </div>
        <div style="margin-top: 10px; color: #666;">
          <div>Одобрено: {{ stats.approvedClientTasks || 0 }}</div>
          <div>В работе: {{ stats.inProgressClientTasks || 0 }}</div>
        </div>
      </ManagerCard>

      <ManagerCard title="Команды" :subtitle="`Всего: ${stats.totalTeams || 0}`">
        <div style="font-size: 24px; font-weight: bold;">
          {{ stats.activeTeams || 0 }} активных
        </div>
        <div style="margin-top: 10px; color: #666;">
          <div>Участников: {{ stats.totalMembers || 0 }}</div>
          <div>Менеджеров: {{ stats.totalManagers || 0 }}</div>
        </div>
      </ManagerCard>

      <ManagerCard title="Активность" :subtitle="`За последние 7 дней`">
        <div style="font-size: 24px; font-weight: bold;">
          {{ stats.recentActivitiesCount || 0 }} событий
        </div>
        <div style="margin-top: 10px; color: #666;">
          <div>Новые задачи: {{ stats.newTasksCount || 0 }}</div>
          <div>Обновления: {{ stats.updatesCount || 0 }}</div>
        </div>
      </ManagerCard>
    </div>

    <!-- Быстрые ссылки -->
    <ManagerCard title="Быстрый доступ" style="margin-bottom: 30px;">
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 15px;">
        <button 
          v-for="link in quickLinks" 
          :key="link.route"
          @click="$router.push(link.route)"
          style="padding: 15px; text-align: left; background: #f8f9fa; border: 1px solid #ddd; border-radius: 5px; cursor: pointer;"
        >
          <div style="font-weight: bold; margin-bottom: 5px;">{{ link.title }}</div>
          <div style="font-size: 12px; color: #666;">{{ link.description }}</div>
        </button>
      </div>
    </ManagerCard>

    <!-- Недавняя активность -->
    <ManagerCard 
      v-if="recentActivities.length > 0"
      title="Недавняя активность"
      :subtitle="`Последние ${recentActivities.length} событий`"
    >
      <div style="max-height: 400px; overflow-y: auto;">
        <div 
          v-for="activity in recentActivities" 
          :key="activity.id"
          style="padding: 10px 0; border-bottom: 1px solid #eee;"
        >
          <div style="display: flex; justify-content: space-between; align-items: start;">
            <div>
              <strong>{{ activity.user?.name || 'Система' }}</strong>
              {{ getActivityText(activity) }}
            </div>
            <div style="font-size: 12px; color: #666;">
              {{ formatDate(activity.created_at) }}
            </div>
          </div>
          <div v-if="activity.details" style="font-size: 12px; color: #666; margin-top: 5px;">
            {{ activity.details }}
          </div>
        </div>
      </div>
    </ManagerCard>

    <!-- Модальное окно создания проекта -->
    <div v-if="showCreateModal" style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1000;">
      <ManagerCard title="Создать новый проект" style="width: 500px; max-width: 90%;">
        <form @submit.prevent="createProject">
          <div style="margin-bottom: 15px;">
            <label style="display: block; margin-bottom: 5px; font-weight: bold;">Название проекта</label>
            <input v-model="newProject.name" type="text" required style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
          </div>
          
          <div style="margin-bottom: 15px;">
            <label style="display: block; margin-bottom: 5px; font-weight: bold;">Описание</label>
            <textarea v-model="newProject.description" rows="3" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;"></textarea>
          </div>
          
          <div style="margin-bottom: 15px;">
            <label style="display: block; margin-bottom: 5px; font-weight: bold;">Клиентская задача</label>
            <select v-model="newProject.client_task_id" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
              <option value="">Не привязана</option>
              <option v-for="task in availableClientTasks" :key="task.id" :value="task.id">
                {{ task.title }} ({{ task.client?.name || 'Без клиента' }})
              </option>
            </select>
          </div>
          
          <div style="margin-bottom: 20px;">
            <label style="display: block; margin-bottom: 5px; font-weight: bold;">Срок выполнения</label>
            <input v-model="newProject.deadline" type="date" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
          </div>
          
          <div style="display: flex; gap: 10px;">
            <button type="submit" style="padding: 10px 20px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer;">
              Создать
            </button>
            <button type="button" @click="showCreateModal = false" style="padding: 10px 20px; background: #6c757d; color: white; border: none; border-radius: 4px; cursor: pointer;">
              Отмена
            </button>
          </div>
        </form>
      </ManagerCard>
    </div>
  </BaseManagerPage>
</template>

<script>
import BaseManagerPage from '@/views/Shared/BaseManagerPage.vue'
import ManagerCard from '@/components/Shared/ManagerCard.vue'
import dashboardService from '@/services/dashboard.service.js'
import projectService from '@/services/project.service.js'
import clientTaskService from '@/services/clientTask.service.js'

export default {
  name: 'DashboardManagerPage',
  components: {
    BaseManagerPage,
    ManagerCard
  },
  data() {
    return {
      loading: false,
      error: '',
      stats: {},
      recentActivities: [],
      quickLinks: [
        { title: 'Все проекты', route: '/projects', description: 'Управление проектами' },
        { title: 'Задачи клиентов', route: '/client-tasks', description: 'Одобрение и управление' },
        { title: 'Просроченные', route: '/client-tasks/pending', description: 'Ожидающие задачи' },
        { title: 'Мои команды', route: '/teams/my', description: 'Мои команды' },
        { title: 'Создать команду', route: '/teams/create', description: 'Новая команда' },
        { title: 'Статистика', route: '/projects/stats', description: 'Аналитика' }
      ],
      showCreateModal: false,
      newProject: {
        name: '',
        description: '',
        client_task_id: '',
        deadline: ''
      },
      availableClientTasks: []
    }
  },
  async created() {
    await this.loadDashboardData()
  },
  methods: {
    async loadDashboardData() {
      this.loading = true
      this.error = ''
      
      try {
        // Загружаем данные дашборда
        const response = await dashboardService.getManagerDashboard()
        this.stats = response.data.stats || {}
        this.recentActivities = response.data.recentActivities || []
        
        // Загружаем доступные клиентские задачи
        const tasksResponse = await clientTaskService.getAll({ status: 'approved' })
        this.availableClientTasks = tasksResponse.data.data || []
      } catch (err) {
        this.error = err.response?.data?.message || 'Ошибка загрузки данных'
        console.error('Error loading dashboard:', err)
      } finally {
        this.loading = false
      }
    },
    
    async createProject() {
      try {
        await projectService.create(this.newProject)
        this.showCreateModal = false
        this.newProject = {
          name: '',
          description: '',
          client_task_id: '',
          deadline: ''
        }
        await this.loadDashboardData()
        alert('Проект успешно создан!')
      } catch (err) {
        alert(err.response?.data?.message || 'Ошибка создания проекта')
      }
    },
    
    getActivityText(activity) {
      const texts = {
        task_created: 'создал(а) задачу',
        task_updated: 'обновил(а) задачу',
        task_completed: 'завершил(а) задачу',
        project_created: 'создал(а) проект',
        project_started: 'запустил(а) проект',
        project_completed: 'завершил(а) проект'
      }
      
      return texts[activity.type] || 'выполнил(а) действие'
    },
    
    formatDate(dateString) {
      return new Date(dateString).toLocaleString('ru-RU')
    }
  }
}
</script>