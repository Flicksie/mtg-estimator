<template>
  <div>
    <!-- Floating Collection Icon -->
    <router-link 
      to="/collection" 
      class="collection-icon floating" 
      ref="iconRef"
      title="View your collection">
      <span class="icon is-large collection-icon-content">
        <i class="fas fa-book-open"></i>
      </span>
      <span v-if="collectionCount > 0" class="collection-badge" :key="collectionCount">
        {{ collectionCount }}
      </span>
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
        <i class="fas fa-sparkles"></i>
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

watch(collectionCount, (newCount) => {
  console.log('Collection count updated:', newCount)
})

onMounted(async () => {
  try {
    const stats = await api.getStats()
    setCount(stats.total_cards)
  } catch (error) {
    console.error('Failed to load collection count:', error)
  }
})

const getCardStyle = (animation: any) => {
  if (!animation.sourceElement || !iconRef.value) {
    return {}
  }

  const sourceRect = animation.sourceElement.getBoundingClientRect()
  const iconElement = (iconRef.value as any).$el || iconRef.value
  const iconRect = iconElement.getBoundingClientRect()

  return {
    '--start-x': `${sourceRect.left + sourceRect.width / 2}px`,
    '--start-y': `${sourceRect.top + sourceRect.height / 2}px`,
    '--end-x': `${iconRect.left + iconRect.width / 2}px`,
    '--end-y': `${iconRect.top + iconRect.height / 2}px`,
  }
}
</script>

<style scoped>
.collection-icon {
  position: fixed !important;
  top: 100px;
  right: 25px;
  z-index: 1000;
  width: 80px;
  height: 80px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: white;
  background: linear-gradient(135deg, #667EEA 0%, #764BA2 100%);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  text-decoration: none;
  position: relative;
}

.collection-icon:hover {
  transform: scale(1.15) translateY(-4px);
  box-shadow: 0 12px 32px rgba(102, 126, 234, 0.4);
}

.collection-icon-content {
  font-size: 2rem;
  font-weight: 700;
}

.collection-badge {
  position: absolute;
  top: -10px;
  right: -10px;
  background: linear-gradient(135deg, #FF6B9D 0%, #C06BFF 100%);
  color: white;
  border-radius: 50%;
  min-width: 35px;
  height: 35px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.85rem;
  font-weight: 900;
  border: 3px solid white;
  box-shadow: 0 4px 12px rgba(255, 107, 157, 0.4);
  animation: badge-pop 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes badge-pop {
  0% {
    transform: scale(0) rotate(-45deg);
  }
  50% {
    transform: scale(1.25) rotate(10deg);
  }
  100% {
    transform: scale(1) rotate(0deg);
  }
}

.flying-card {
  position: fixed;
  width: 90px;
  height: 126px;
  pointer-events: none;
  z-index: 9999;
  left: var(--start-x);
  top: var(--start-y);
  transform: translate(-50%, -50%);
  animation: fly-to-collection 1.2s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
  filter: drop-shadow(0 4px 12px rgba(255, 107, 157, 0.3));
}

@keyframes fly-to-collection {
  0% {
    left: var(--start-x);
    top: var(--start-y);
    transform: translate(-50%, -50%) scale(1.1) rotate(0deg);
    opacity: 1;
  }
  30% {
    transform: translate(-50%, -50%) scale(0.9) rotate(5deg);
  }
  70% {
    transform: translate(-50%, -50%) scale(0.5) rotate(15deg);
  }
  100% {
    left: var(--end-x);
    top: var(--end-y);
    transform: translate(-50%, -50%) scale(0) rotate(25deg);
    opacity: 0;
  }
}

.card-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 12px;
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.25);
}

.card-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #FF6B9D 0%, #C06BFF 50%, #5B61FF 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 2.5rem;
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.3);
}

@media screen and (min-width: 769px) {
  .collection-icon {
    top: 100px;
    bottom: auto;
  }
}

@media screen and (max-width: 768px) {
  .collection-icon {
    top: auto;
    bottom: 25px;
  }
}
</style>
