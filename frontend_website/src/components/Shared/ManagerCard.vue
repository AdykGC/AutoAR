<template>
  <div class="manager-card" :style="cardStyle">
    <!-- Заголовок карточки -->
    <div v-if="title" class="card-header" :style="headerStyle">
      <div style="display: flex; justify-content: space-between; align-items: center;">
        <h3 style="margin: 0;">{{ title }}</h3>
        <slot name="header-actions"></slot>
      </div>
      <div v-if="subtitle" style="margin-top: 5px; font-size: 14px; color: #666;">
        {{ subtitle }}
      </div>
    </div>

    <!-- Контент карточки -->
    <div class="card-content" :style="contentStyle">
      <slot></slot>
    </div>

    <!-- Футер карточки -->
    <div v-if="showFooter" class="card-footer" :style="footerStyle">
      <slot name="footer"></slot>
    </div>

    <!-- Статус карточки -->
    <div v-if="status" class="status-badge" :style="getStatusStyle(status)">
      {{ getStatusText(status) }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ManagerCard',
  props: {
    title: {
      type: String,
      default: ''
    },
    subtitle: {
      type: String,
      default: ''
    },
    status: {
      type: String,
      default: ''
    },
    showFooter: {
      type: Boolean,
      default: false
    },
    padding: {
      type: String,
      default: '20px'
    },
    margin: {
      type: String,
      default: '0 0 20px 0'
    }
  },
  computed: {
    cardStyle() {
      return {
        background: '#fff',
        border: '1px solid #ddd',
        borderRadius: '5px',
        margin: this.margin,
        position: 'relative',
        boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
      }
    },
    headerStyle() {
      return {
        padding: `${this.padding} ${this.padding} 10px ${this.padding}`,
        borderBottom: '1px solid #eee'
      }
    },
    contentStyle() {
      return {
        padding: this.padding
      }
    },
    footerStyle() {
      return {
        padding: `10px ${this.padding}`,
        borderTop: '1px solid #eee',
        background: '#f9f9f9'
      }
    }
  },
  methods: {
    getStatusStyle(status) {
      const styles = {
        pending: { background: '#fff3cd', color: '#856404', border: '1px solid #ffeaa7' },
        in_progress: { background: '#cce5ff', color: '#004085', border: '1px solid #b8daff' },
        completed: { background: '#d4edda', color: '#155724', border: '1px solid #c3e6cb' },
        cancelled: { background: '#f8d7da', color: '#721c24', border: '1px solid #f5c6cb' },
        approved: { background: '#d4edda', color: '#155724', border: '1px solid #c3e6cb' },
        rejected: { background: '#f8d7da', color: '#721c24', border: '1px solid #f5c6cb' },
        active: { background: '#d4edda', color: '#155724', border: '1px solid #c3e6cb' },
        inactive: { background: '#f8d7da', color: '#721c24', border: '1px solid #f5c6cb' }
      }
      
      return {
        position: 'absolute',
        top: '10px',
        right: '10px',
        padding: '4px 8px',
        borderRadius: '3px',
        fontSize: '12px',
        fontWeight: 'bold',
        ...(styles[status] || { background: '#e9ecef', color: '#495057', border: '1px solid #dee2e6' })
      }
    },
    getStatusText(status) {
      const texts = {
        pending: 'Ожидание',
        in_progress: 'В работе',
        completed: 'Завершено',
        cancelled: 'Отменено',
        approved: 'Одобрено',
        rejected: 'Отклонено',
        active: 'Активен',
        inactive: 'Неактивен'
      }
      
      return texts[status] || status
    }
  }
}
</script>