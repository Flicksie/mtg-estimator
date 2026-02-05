<template>
  <div>
    <h1 class="title">📖 My Collection</h1>
    <p class="subtitle">Manage and track your Magic: The Gathering cards</p>

    <!-- Collection Stats -->
    <div class="collection-stats">
      <div class="stat-box stat-cards">
        <div class="stat-icon">📚</div>
        <div class="stat-content">
          <p class="stat-label">Total Cards</p>
          <p class="stat-value">{{ collection.length }}</p>
        </div>
      </div>

      <div class="stat-box stat-value">
        <div class="stat-icon">💰</div>
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
        <p class="empty-icon">✨</p>
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
    <div v-else class="columns is-multiline collection-grid">
      <div 
        v-for="(card, index) in collection" 
        :key="card.id" 
        class="column is-one-quarter-desktop is-one-third-tablet is-full-mobile"
        :style="{ 'animation-delay': `${index * 0.05}s` }"
      >
        <div class="card collection-card">
          <!-- Card Image -->
          <div class="card-image" v-if="card.image_uri">
            <figure class="image is-4by3">
              <img :src="card.image_uri" :alt="card.name" class="collection-card-img">
            </figure>
            <div class="card-rarity-badge">✨</div>
          </div>

          <!-- Card Content -->
          <div class="card-content">
            <p class="title is-6 card-name">{{ card.name }}</p>
            <p class="subtitle is-7 card-set" v-if="card.set">{{ card.set }}</p>
            <div class="price-display">
              <p class="price-label">Estimated Value</p>
              <p class="price-amount">${{ (card.price || 0).toFixed(2) }}</p>
            </div>
            <p class="is-size-7 date-added">
              📅 {{ formatDate(card.added_date) }}
            </p>
          </div>

          <!-- Card Footer -->
          <footer class="card-footer">
            <a 
              @click.prevent="card.id && removeCard(card.id)" 
              class="card-footer-item remove-btn"
            >
              <span class="icon">
                <i class="fas fa-trash-alt"></i>
              </span>
              <span>Remove</span>
            </a>
          </footer>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
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
  if (!confirm('Remove this card from your collection?')) {
    return
  }

  try {
    await api.removeFromCollection(cardId)
    collection.value = collection.value.filter(c => c.id !== cardId)
  } catch (err) {
    alert('Error removing card: ' + (err instanceof Error ? err.message : 'Unknown error'))
  }
}

const clearCollection = async () => {
  if (!confirm('Are you sure? This will clear your entire collection!')) {
    return
  }

  try {
    await api.clearCollection()
    collection.value = []
  } catch (err) {
    alert('Error clearing collection: ' + (err instanceof Error ? err.message : 'Unknown error'))
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
  } catch (err) {
    alert('Error exporting collection: ' + (err instanceof Error ? err.message : 'Unknown error'))
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

.stat-value {
  background: var(--success-gradient);
  color: white;
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
  animation: fadeInUp 0.6s ease;
}

.collection-card {
  position: relative;
  border-radius: 20px;
  overflow: hidden;
  animation: slideIn 0.6s ease both;
  box-shadow: var(--shadow-md);
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fadeInUp {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.collection-card-img {
  transition: transform 0.4s ease;
  object-fit: cover;
}

.collection-card:hover .collection-card-img {
  transform: scale(1.08) rotate(1deg);
}

.card-image {
  position: relative;
  border-radius: 20px 20px 0 0;
  overflow: hidden;
}

.card-rarity-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  font-size: 1.5rem;
  background: rgba(255, 255, 255, 0.9);
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.card-content {
  padding: 1.5rem;
}

.card-name {
  color: #2C2C7C;
  font-weight: 800;
  margin-bottom: 0.5rem;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-set {
  color: #888899;
  font-weight: 600;
}

.price-display {
  background: linear-gradient(135deg, #FFB347 0%, #FF8C47 100%);
  color: white;
  border-radius: 12px;
  padding: 1rem;
  margin: 1rem 0;
}

.price-label {
  font-size: 0.75rem;
  font-weight: 700;
  opacity: 0.9;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin: 0;
}

.price-amount {
  font-size: 1.5rem;
  font-weight: 900;
  margin: 0.25rem 0 0 0;
}

.date-added {
  color: #888899;
  margin-top: 0.75rem;
}

.card-footer {
  background: transparent;
  border-top: 1px solid #F0F0F0;
  padding: 0.75rem;
}

.remove-btn {
  color: #FF6B9D;
  font-weight: 700;
  transition: all 0.3s ease;
  border-radius: var(--border-radius-sm);
  text-transform: uppercase;
  font-size: 0.85rem;
}

.remove-btn:hover {
  background: rgba(255, 107, 157, 0.1);
  color: #EE5A6F;
}

@media screen and (max-width: 768px) {
  .collection-stats {
    grid-template-columns: 1fr;
  }

  .stat-box {
    flex-direction: column;
    text-align: center;
  }

  .collection-grid {
    grid-template-columns: 1fr;
  }
}
</style>
