<template>
  <div class="stats-cards">
    <div class="stats-grid">
      <div v-for="stat in stats" :key="stat.id" class="stat-card" :class="stat.trend">
        <div class="stat-icon" :style="{ backgroundColor: stat.color + '20', color: stat.color }">
          <span class="material-icons">{{ stat.icon }}</span>
        </div>
        
        <div class="stat-content">
          <div class="stat-value">{{ formatValue(stat.value) }}</div>
          <div class="stat-label">{{ stat.label }}</div>
        </div>
        
        <div v-if="stat.trend" class="stat-trend">
          <span class="trend-icon" :class="stat.trend">
            <span class="material-icons">
              {{ stat.trend === 'up' ? 'trending_up' : 'trending_down' }}
            </span>
          </span>
          <span class="trend-value">{{ stat.change }}%</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'StatsCards',
  props: {
    stats: {
      type: Array,
      default: () => []
    }
  },
  
  methods: {
    formatValue(value) {
      if (typeof value === 'number') {
        if (value >= 1000000) {
          return (value / 1000000).toFixed(1) + 'M'
        }
        if (value >= 1000) {
          return (value / 1000).toFixed(1) + 'K'
        }
        return value.toString()
      }
      return value
    }
  }
}
</script>

<style scoped>
.stats-cards {
  margin-bottom: 32px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 20px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  border: 1px solid #e8e8e8;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
  border-color: transparent;
}

.stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, #4f46e5, #8b5cf6);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.stat-card:hover::before {
  opacity: 1;
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: #1a1a1a;
  line-height: 1.2;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #666;
  line-height: 1.4;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
}

.trend-icon {
  display: flex;
  align-items: center;
}

.trend-icon.up {
  color: #10b981;
}

.trend-icon.down {
  color: #ef4444;
}

.trend-value.up {
  color: #10b981;
  background: #ecfdf5;
}

.trend-value.down {
  color: #ef4444;
  background: #fef2f2;
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .stat-card {
    padding: 16px;
  }
  
  .stat-value {
    font-size: 24px;
  }
}
</style>