<template>
  <div class="dashboard-card" :class="[size, { 'no-padding': noPadding }]">
    <div v-if="title || $slots.header" class="card-header">
      <slot name="header">
        <h3 class="card-title">{{ title }}</h3>
        <div v-if="$slots.actions" class="card-actions">
          <slot name="actions"></slot>
        </div>
      </slot>
    </div>
    
    <div class="card-body">
      <slot></slot>
    </div>
    
    <div v-if="$slots.footer" class="card-footer">
      <slot name="footer"></slot>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DashboardCard',
  props: {
    title: {
      type: String,
      default: ''
    },
    size: {
      type: String,
      default: 'medium',
      validator: (value) => ['small', 'medium', 'large', 'full'].includes(value)
    },
    noPadding: {
      type: Boolean,
      default: false
    }
  }
}
</script>

<style scoped>
.dashboard-card {
  background: white;
  border-radius: 12px;
  border: 1px solid #e8e8e8;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  transition: all 0.3s ease;
  overflow: hidden;
}

.dashboard-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-1px);
}

.dashboard-card.small {
  min-height: 150px;
}

.dashboard-card.medium {
  min-height: 200px;
}

.dashboard-card.large {
  min-height: 300px;
}

.dashboard-card.full {
  min-height: 400px;
}

.card-header {
  padding: 20px 24px 0;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.card-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #1a1a1a;
  line-height: 1.4;
}

.card-actions {
  display: flex;
  gap: 8px;
}

.card-body {
  padding: 0 24px 24px;
}

.card-body.no-padding {
  padding: 0;
}

.card-footer {
  padding: 16px 24px;
  border-top: 1px solid #f0f0f0;
  background: #fafafa;
}

@media (max-width: 768px) {
  .card-header {
    padding: 16px 16px 0;
  }
  
  .card-body {
    padding: 0 16px 16px;
  }
  
  .card-footer {
    padding: 12px 16px;
  }
}
</style>