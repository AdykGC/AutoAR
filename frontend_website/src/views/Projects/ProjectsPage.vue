<template>
  <BaseManagerPage
    title="Все проекты"
    subtitle="Управление всеми проектами"
    :loading="loading"
    :error="error"
    :items="projects"
    :show-filters="true"
    :show-search="true"
    :show-status-filter="true"
    :show-refresh="true"
    :show-pagination="true"
    :current-page="currentPage"
    :total-pages="totalPages"
  >
    <template #header-actions>
      <button @click="$router.push('/projects/create')" style="margin-right: 10px;">
        + Новый проект
      </button>
    </template>

    <!-- Список проектов -->
    <ManagerCard 
      v-for="project in projects" 
      :key="project.id" 
      :title="project.name" 
      :subtitle="`Менеджер: ${project.manager?.name || 'Не назначен'}`" 
      :status="project.status"
    >
      <div style="margin-bottom: 15px;">
        {{ project.description }}
      </div>
      
      <div style="display: flex; justify-content: space-between; color: #666; font-size: 14px;">
        <div>
          <strong>Клиент:</strong> {{ project.client_task?.client?.name || 'Не привязан' }}
        </div>
        <div>
          <strong>Бюджет:</strong> ${{ project.budget || 0 }}
        </div>
        <div>
          <strong>Дедлайн:</strong> {{ formatDate(project.deadline) }}
        </div>
      </div>
      
      <div style="margin-top: 10px; display: flex; gap: 10px; font-size: 14px;">
        <span>Задачи: {{ project.tasks_count || 0 }}</span>
        <span>Участники: {{ project.members_count || 0 }}</span>
        <span>Прогресс: {{ project.progress || 0 }}%</span>
      </div>

      <template #footer>
        <div style="display: flex; gap: 10px;">
          <button @click="viewProject(project.id)">
            👁️ Просмотр
          </button>
          <button @click="editProject(project.id)">
            ✏️ Редактировать
          </button>
          <button @click="viewStats(project.id)">
            📊 Статистика
          </button>
          <button @click="startProject(project.id)" v-if="project.status === 'pending'" style="background: #28a745; color: white;">
            ▶️ Запустить
          </button>
          <button @click="completeProject(project.id)" v-if="project.status === 'in_progress'" style="background: #17a2b8; color: white;">
            ✓ Завершить
          </button>
        </div>
      </template>
    </ManagerCard>

    <template #empty-actions>
      <button @click="$router.push('/projects/create')">
        Создать первый проект
      </button>
    </template>
  </BaseManagerPage>
</template>

<script>
import BaseManagerPage from '@/views/Shared/BaseManagerPage.vue'
import ManagerCard from '@/components/Shared/ManagerCard.vue'
import projectService from '@/services/project.service.js'

export default {
  name: 'ProjectsPage',
  components: {
    BaseManagerPage,
    ManagerCard
  },
  data() {
    return {
      loading: false,
      error: '',
      projects: [],
      filters: {
        search: '',
        status: ''
      },
      pagination: {
        current_page: 1,
        total_pages: 1
      }
    }
  },
  computed: {
    currentPage() {
      return this.pagination.current_page
    },
    totalPages() {
      return this.pagination.total_pages
    }
  },
  async created() {
    await this.loadProjects()
  },
  methods: {
    async loadProjects(page = 1) {
      this.loading = true
      this.error = ''
      
      try {
        const params = {
          page,
          ...this.filters
        }
        
        const response = await projectService.getAll(params)
        this.projects = response.data.data || []
        this.pagination = response.data.meta || {
          current_page: 1,
          total_pages: 1
        }
      } catch (err) {
        this.error = err.response?.data?.message || 'Ошибка загрузки проектов'
        console.error('Error loading projects:', err)
      } finally {
        this.loading = false
      }
    },
    
    viewProject(id) {
      this.$router.push(`/projects/${id}`)
    },
    
    editProject(id) {
      this.$router.push(`/projects/${id}/edit`)
    },
    
    viewStats(id) {
      this.$router.push(`/projects/${id}/stats`)
    },
    
    async startProject(id) {
      if (!confirm('Запустить проект?')) return
      
      try {
        await projectService.start(id)
        await this.loadProjects(this.currentPage)
        alert('Проект запущен!')
      } catch (err) {
        alert(err.response?.data?.message || 'Ошибка запуска проекта')
      }
    },
    
    async completeProject(id) {
      if (!confirm('Завершить проект?')) return
      
      try {
        await projectService.complete(id)
        await this.loadProjects(this.currentPage)
        alert('Проект завершен!')
      } catch (err) {
        alert(err.response?.data?.message || 'Ошибка завершения проекта')
      }
    },
    
    formatDate(dateString) {
      if (!dateString) return 'Не указано'
      return new Date(dateString).toLocaleDateString('ru-RU')
    }
  }
}
</script>