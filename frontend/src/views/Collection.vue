<template>
  <div>
    <h1 class="title">My Collection</h1>
    <p class="subtitle">Manage your Magic: The Gathering card collection</p>

    <div class="level">
      <div class="level-left">
        <div class="level-item">
          <div>
            <p class="heading">Total Cards</p>
            <p class="title">{{ collection.length }}</p>
          </div>
        </div>
        <div class="level-item">
          <div>
            <p class="heading">Total Value</p>
            <p class="title has-text-success">${{ totalValue.toFixed(2) }}</p>
          </div>
        </div>
      </div>
      <div class="level-right">
        <div class="level-item">
          <div class="buttons">
            <button @click="exportCollection" class="button is-info">
              <span class="icon">
                <i class="fas fa-download"></i>
              </span>
              <span>Export</span>
            </button>
            <button @click="clearCollection" class="button is-danger" v-if="collection.length > 0">
              <span class="icon">
                <i class="fas fa-trash"></i>
              </span>
              <span>Clear All</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="collection.length === 0" class="notification is-info">
      <p>Your collection is empty. Add cards from the <router-link to="/search">Search</router-link> or <router-link to="/scanner">Scanner</router-link> pages.</p>
    </div>

    <div v-else class="columns is-multiline">
      <div v-for="card in collection" :key="card.id" class="column is-one-quarter">
        <div class="card">
          <div class="card-image" v-if="card.image_uri">
            <figure class="image is-4by3">
              <img :src="card.image_uri" :alt="card.name">
            </figure>
          </div>
          <div class="card-content">
            <p class="title is-6">{{ card.name }}</p>
            <p class="subtitle is-7" v-if="card.set">{{ card.set }}</p>
            <p class="has-text-weight-bold has-text-success">
              ${{ (card.price || 0).toFixed(2) }}
            </p>
            <p class="is-size-7 has-text-grey">
              Added: {{ formatDate(card.added_date) }}
            </p>
          </div>
          <footer class="card-footer">
            <a @click.prevent="card.id && removeCard(card.id)" class="card-footer-item has-text-danger">
              <span class="icon">
                <i class="fas fa-trash"></i>
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
  if (!confirm('Are you sure you want to remove this card from your collection?')) {
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
  if (!confirm('Are you sure you want to clear your entire collection? This cannot be undone.')) {
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
