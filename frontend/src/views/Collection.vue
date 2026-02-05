<template>
  <div>
    <h1 class="title"><i class="fas fa-book"></i> My Collection</h1>
    <p class="subtitle">Manage and track your Magic: The Gathering cards</p>

    <!-- Collection Stats -->
    <div class="collection-stats">
      <div class="stat-box stat-cards">
        <div class="stat-icon"><i class="fas fa-layer-group"></i></div>
        <div class="stat-content">
          <p class="stat-label">Total Cards</p>
          <p class="stat-value">{{ collection.length }}</p>
        </div>
      </div>

      <div class="stat-box stat-value">
        <div class="stat-icon"><i class="fas fa-coins"></i></div>
        <div class="stat-content">
          <p class="stat-label">Total Value</p>
          <p class="stat-value">${{ totalValue.toFixed(2) }}</p>
        </div>
      </div>

      <div class="stat-box stat-actions">
        <div class="buttons">
          <button 
            @click="exportCollection" 
            class="button is-info"
            v-if="collection.length > 0">
            <span class="icon">
              <i class="fas fa-download"></i>
            </span>
            <span>Export</span>
          </button>
          <button 
            @click="clearCollection" 
            class="button is-danger" 
            v-if="collection.length > 0">
            <span class="icon">
              <i class="fas fa-trash-alt"></i>
            </span>
            <span>Clear All</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-if="collection.length === 0" class="empty-state-container">
      <div class="empty-state">
        <p class="empty-icon"><i class="fas fa-box-open"></i></p>
        <p class="title is-4">Your collection is empty!</p>
        <p class="subtitle">Start adding cards from the <router-link to="/search">Search</router-link> or <router-link to="/scanner">Scanner</router-link> pages.</p>
        <router-link to="/search" class="button is-primary is-large mt-4">
          <span class="icon">
            <i class="fas fa-plus"></i>
          </span>
          <span>Add Your First Card</span>
        </router-link>
      </div>
    </div>

    <!-- Collection Grid -->
    <div v-else class="collection-grid">
      <CollectionCardItem 
        v-for="(card, index) in collection" 
        :key="card.id" 
        :card="card"
        :index="index"
        @remove="removeCard"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import Swal from 'sweetalert2'
import CollectionCardItem from '../components/CollectionCardItem.vue'
import api from '../services/api'
import type { Card } from '../types'

const collection = ref<Card[]>([])

const totalValue = computed(() => {
  return collection.value.reduce((sum, card) => {
    return sum + (card.price || 0)
  }, 0)
})

const loadCollection = async () => {
  try {
    collection.value = await api.getCollection()
  } catch (error) {
    console.error('Failed to load collection:', error)
  }
}

const removeCard = async (cardId: number) => {
  const result = await Swal.fire({
    title: 'Remove Card?',
    text: 'This card will be removed from your collection',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#FF6B9D',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Remove',
    cancelButtonText: 'Cancel'
  })

  if (!result.isConfirmed) return

  try {
    await api.removeFromCollection(cardId)
    collection.value = collection.value.filter(c => c.id !== cardId)
    
    await Swal.fire({
      title: 'Removed!',
      text: 'Card removed from collection',
      icon: 'success',
      timer: 1500,
      timerProgressBar: true
    })
  } catch (err) {
    await Swal.fire({
      title: 'Error',
      text: 'Error removing card: ' + (err instanceof Error ? err.message : 'Unknown error'),
      icon: 'error',
      confirmButtonColor: '#FF6B9D'
    })
  }
}

const clearCollection = async () => {
  const result = await Swal.fire({
    title: 'Clear Collection?',
    text: 'This will remove all cards from your collection. This cannot be undone!',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#FF6B6B',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Clear All',
    cancelButtonText: 'Cancel'
  })

  if (!result.isConfirmed) return

  try {
    await api.clearCollection()
    collection.value = []
    
    await Swal.fire({
      title: 'Cleared!',
      text: 'Your collection has been cleared',
      icon: 'success',
      timer: 1500,
      timerProgressBar: true
    })
  } catch (err) {
    await Swal.fire({
      title: 'Error',
      text: 'Error clearing collection: ' + (err instanceof Error ? err.message : 'Unknown error'),
      icon: 'error',
      confirmButtonColor: '#FF6B9D'
    })
  }
}

const exportCollection = async () => {
  try {
    const data = await api.exportCollection()
    const dataStr = JSON.stringify(data, null, 2)
    const dataBlob = new Blob([dataStr], { type: 'application/json' })
    
    const url = URL.createObjectURL(dataBlob)
    const link = document.createElement('a')
    link.href = url
    link.download = `mtg-collection-${new Date().toISOString().split('T')[0]}.json`
    link.click()
    
    URL.revokeObjectURL(url)
    
    await Swal.fire({
      title: 'Exported!',
      text: 'Your collection has been exported',
      icon: 'success',
      timer: 1500,
      timerProgressBar: true
    })
  } catch (err) {
    await Swal.fire({
      title: 'Error',
      text: 'Error exporting collection: ' + (err instanceof Error ? err.message : 'Unknown error'),
      icon: 'error',
      confirmButtonColor: '#FF6B9D'
    })
  }
}

const formatDate = (dateStr?: string) => {
  if (!dateStr) return 'Unknown'
  const date = new Date(dateStr)
  return date.toLocaleDateString()
}

onMounted(() => {
  loadCollection()
})
</script>

<style scoped>
.collection-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.stat-box {
  background: white;
  border-radius: 20px;
  padding: 1.5rem;
  box-shadow: var(--shadow-sm);
  display: flex;
  align-items: center;
  gap: 1.5rem;
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.stat-box:hover {
  transform: translateY(-8px);
  box-shadow: var(--shadow-md);
}

.stat-cards {
  background: var(--primary-gradient);
  color: white;
}

.stat-box.stat-value {
  background: var(--success-gradient);
  color: white;
}

.stat-value {
  color: inherit;
  background: transparent;
}

.stat-actions {
  background: white;
  border: 2px solid #F0F0F0;
}

.stat-icon {
  font-size: 2.5rem;
  min-width: 60px;
  text-align: center;
}

.stat-content {
  flex: 1;
}

.stat-label {
  font-size: 0.85rem;
  font-weight: 700;
  opacity: 0.9;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin: 0;
}

.stat-value {
  font-size: 1.75rem;
  font-weight: 900;
  margin: 0.25rem 0 0 0;
}

.empty-state-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 500px;
}

.empty-state {
  text-align: center;
  padding: 2rem;
  background: linear-gradient(135deg, rgba(255, 107, 157, 0.05) 0%, rgba(192, 107, 255, 0.05) 100%);
  border-radius: 24px;
  border: 2px dashed #FF6B9D;
}

.empty-icon {
  font-size: 4rem;
  margin: 0;
  animation: float 3s ease-in-out infinite;
}

.collection-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 0.75rem;
  animation: fadeInUp 0.6s ease;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@media screen and (max-width: 768px) {
  .collection-stats {
    grid-template-columns: 1fr;
  }

  .stat-box {
    flex-direction: column;
    text-align: center;
  }
}

@media screen and (min-width: 769px) and (max-width: 1024px) {
  .collection-grid {
    grid-template-columns: repeat(4, 1fr);
  }
}

@media screen and (min-width: 1025px) {
  .collection-grid {
    grid-template-columns: repeat(5, 1fr);
  }
}
</style>
