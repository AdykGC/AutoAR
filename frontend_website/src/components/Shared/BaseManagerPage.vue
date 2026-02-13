<template>
  <div class="manager-page">
    <!-- Шапка -->
    <div class="page-header" style="margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-radius: 5px;">
      <div style="display: flex; justify-content: space-between; align-items: center;">
        <h1 style="margin: 0;">{{ title }}</h1>
        <div>
          <button 
            v-if="showBackButton" 
            @click="$router.back()"
            style="padding: 8px 15px; margin-right: 10px;"
          >
            ← Назад
          </button>
          <slot name="header-actions"></slot>
        </div>
      </div>
      <div v-if="subtitle" style="margin-top: 10px; color: #666;">
        {{ subtitle }}
      </div>
    </div>

    <!-- Фильтры и поиск -->
    <div v-if="showFilters" class="filters-section" style="margin-bottom: 20px;">
      <div style="display: flex; gap: 10px; align-items: center;">
        <input 
          v-if="showSearch"
          v-model="searchQuery"
          type="text" 
          placeholder="Поиск..." 
          style="padding: 8px; flex-grow: 1;"
          @input="onSearch"
        />
        
        <select 
          v-if="showStatusFilter"
          v-model="statusFilter"
          style="padding: 8px;"
          @change="onFilterChange"
        >
          <option value="">Все статусы</option>
          <option value="pending">Ожидание</option>
          <option value="in_progress">В работе</option>
          <option value="completed">Завершено</option>
          <option value="cancelled">Отменено</option>
        </select>
        
        <select 
          v-if="showDateFilter"
          v-model="dateFilter"
          style="padding: 8px;"
          @change="onFilterChange"
        >
          <option value="">Все время</option>
          <option value="today">Сегодня</option>
          <option value="week">Эта неделя</option>
          <option value="month">Этот месяц</option>
        </select>
        
        <button 
          v-if="showRefresh"
          @click="onRefresh"
          style="padding: 8px 15px;"
        >
          🔄 Обновить
        </button>
      </div>
    </div>

    <!-- Состояние загрузки -->
    <div v-if="loading" style="text-align: center; padding: 40px;">
      Загрузка...
    </div>

    <!-- Состояние ошибки -->
    <div v-if="error" style="background: #fee; padding: 20px; border-radius: 5px; margin-bottom: 20px;">
      <strong>Ошибка:</strong> {{ error }}
      <button @click="onRefresh" style="margin-left: 10px;">Повторить</button>
    </div>

    <!-- Основной контент -->
    <div v-if="!loading && !error">
      <slot name="content"></slot>
      
      <!-- Состояние пустого списка -->
      <div v-if="showEmptyState && isEmpty" style="text-align: center; padding: 40px;">
        <div style="font-size: 18px; margin-bottom: 10px;">Ничего не найдено</div>
        <div style="color: #666; margin-bottom: 20px;">{{ emptyMessage }}</div>
        <slot name="empty-actions"></slot>
      </div>
    </div>

    <!-- Пагинация -->
    <div v-if="showPagination && items && items.length > 0" style="margin-top: 20px; display: flex; justify-content: center;">
      <button 
        :disabled="!hasPrevPage"
        @click="onPrevPage"
        style="padding: 8px 15px; margin: 0 5px;"
      >
        ← Предыдущая
      </button>
      <span style="padding: 8px 15px;">
        Страница {{ currentPage }} из {{ totalPages }}
      </span>
      <button 
        :disabled="!hasNextPage"
        @click="onNextPage"
        style="padding: 8px 15px; margin: 0 5px;"
      >
        Следующая →
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BaseManagerPage',
  props: {
    title: {
      type: String,
      required: true
    },
    subtitle: {
      type: String,
      default: ''
    },
    loading: {
      type: Boolean,
      default: false
    },
    error: {
      type: String,
      default: ''
    },
    items: {
      type: Array,
      default: () => []
    },
    showFilters: {
      type: Boolean,
      default: false
    },
    showSearch: {
      type: Boolean,
      default: false
    },
    showStatusFilter: {
      type: Boolean,
      default: false
    },
    showDateFilter: {
      type: Boolean,
      default: false
    },
    showRefresh: {
      type: Boolean,
      default: false
    },
    showBackButton: {
      type: Boolean,
      default: true
    },
    showPagination: {
      type: Boolean,
      default: false
    },
    currentPage: {
      type: Number,
      default: 1
    },
    totalPages: {
      type: Number,
      default: 1
    },
    showEmptyState: {
      type: Boolean,
      default: true
    },
    emptyMessage: {
      type: String,
      default: 'Здесь пока ничего нет'
    }
  },
  data() {
    return {
      searchQuery: '',
      statusFilter: '',
      dateFilter: ''
    }
  },
  computed: {
    hasPrevPage() {
      return this.currentPage > 1
    },
    hasNextPage() {
      return this.currentPage < this.totalPages
    },
    isEmpty() {
      return this.items.length === 0
    }
  },
  methods: {
    onSearch() {
      this.$emit('search', this.searchQuery)
    },
    onFilterChange() {
      this.$emit('filter-change', {
        status: this.statusFilter,
        date: this.dateFilter
      })
    },
    onRefresh() {
      this.$emit('refresh')
    },
    onPrevPage() {
      this.$emit('page-change', this.currentPage - 1)
    },
    onNextPage() {
      this.$emit('page-change', this.currentPage + 1)
    }
  }
}
</script>