<template>
  <div>
    <!-- Sticky Collection Icon -->
    <router-link 
      to="/collection" 
      class="collection-icon" 
      ref="iconRef"
      title="View Collection">
      <span class="icon is-large">
        <i class="fas fa-book-open"></i>
      </span>
      <span v-if="collectionCount > 0" class="badge" :key="collectionCount">{{ collectionCount }}</span>
    </router-link>

    <!-- Animated Cards -->
    <div 
      v-for="animation in pendingAnimations" 
      :key="animation.id"
      class="flying-card"
      :style="getCardStyle(animation)">
      <img 
        v-if="animation.card.image_uri" 
        :src="animation.card.image_uri" 
        :alt="animation.card.name"
        class="card-image">
      <div v-else class="card-placeholder">
        <i class="fas fa-magic"></i>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useCollection } from '../composables/useCollection'
import api from '../services/api'

const { collectionCount, pendingAnimations, setCount } = useCollection()
const iconRef = ref<HTMLElement | null>(null)

// Watch for new animations and log for debugging
watch(pendingAnimations, (newAnimations) => {
  console.log('Pending animations updated:', newAnimations.length, newAnimations)
}, { deep: true })

watch(collectionCount, (newCount) => {
  console.log('Collection count updated in icon:', newCount)
})

onMounted(async () => {
  // Load initial count
  try {
    const stats = await api.getStats()
    setCount(stats.total_cards)
    console.log('Initial collection count loaded:', stats.total_cards)
  } catch (error) {
    console.error('Failed to load collection count:', error)
  }
})

const getCardStyle = (animation: any) => {
  if (!animation.sourceElement || !iconRef.value) {
    console.warn('Missing source element or icon ref for animation')
    return {}
  }

  const sourceRect = animation.sourceElement.getBoundingClientRect()
  
  // Handle both native elements and Vue component refs
  const iconElement = (iconRef.value as any).$el || iconRef.value
  const iconRect = iconElement.getBoundingClientRect()

  const style = {
    '--start-x': `${sourceRect.left + sourceRect.width / 2}px`,
    '--start-y': `${sourceRect.top + sourceRect.height / 2}px`,
    '--end-x': `${iconRect.left + iconRect.width / 2}px`,
    '--end-y': `${iconRect.top + iconRect.height / 2}px`,
  }
  
  console.log('Animation style calculated:', style)
  return style
}
</script>

<style scoped>
.collection-icon {
  position: fixed;
  top: 80px;
  right: 20px;
  z-index: 1000;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  width: 70px;
  height: 70px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transition: all 0.3s ease;
  cursor: pointer;
  color: white;
}

.collection-icon:hover {
  transform: scale(1.1);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.25);
}

.collection-icon .icon {
  font-size: 1.8rem;
}

.badge {
  position: absolute;
  top: -5px;
  right: -5px;
  background: #ff3860;
  color: white;
  border-radius: 50%;
  min-width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  font-weight: bold;
  border: 3px solid white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
  animation: badge-pop 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}

@keyframes badge-pop {
  0% {
    transform: scale(0);
  }
  50% {
    transform: scale(1.2);
  }
  100% {
    transform: scale(1);
  }
}

.flying-card {
  position: fixed;
  width: 80px;
  height: 112px;
  pointer-events: none;
  z-index: 9999;
  left: var(--start-x);
  top: var(--start-y);
  transform: translate(-50%, -50%);
  animation: fly-to-collection 1s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}

@keyframes fly-to-collection {
  0% {
    left: var(--start-x);
    top: var(--start-y);
    transform: translate(-50%, -50%) scale(1) rotate(0deg);
    opacity: 1;
  }
  50% {
    transform: translate(-50%, -50%) scale(0.8) rotate(10deg);
  }
  100% {
    left: var(--end-x);
    top: var(--end-y);
    transform: translate(-50%, -50%) scale(0.2) rotate(20deg);
    opacity: 0;
  }
}

.card-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.card-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 2rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}
</style>
