<template>
  <div>
    <h1 class="title"><i class="fas fa-search"></i> Card Search</h1>
    <p class="subtitle">Find any Magic: The Gathering card and add it to your collection</p>

    <div class="box search-container">
      <div class="field has-addons">
        <div class="control is-expanded">
          <input 
            v-model="query" 
            @keyup.enter="searchCard"
            class="input is-large search-input" 
            type="text" 
            placeholder="Try: Lightning Bolt, Black Lotus, Shock...">
        </div>
        <div class="control">
          <button 
            @click="searchCard" 
            :class="['button', 'is-primary', 'is-large', { 'is-loading': loading }]"
            :disabled="!query || loading">
            <span class="icon">
              <i class="fas fa-search"></i>
            </span>
            <span>Search</span>
          </button>
        </div>
      </div>

      <div v-if="error" class="notification is-danger mt-4">
        <button @click="error = ''" class="delete"></button>
        {{ error }}
      </div>

      <div v-if="card" class="columns mt-5">
        <!-- Card Image Column -->
        <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
          <figure class="image card-image-container">
            <img 
              v-if="card.image_uri" 
              :src="card.image_uri" 
              :alt="card.name"
              class="card-display-image"
            >
            <div v-else class="no-image-placeholder">
              <span class="icon is-large">
                <i class="fas fa-image" style="font-size: 3rem;"></i>
              </span>
              <p class="mt-3">No image available</p>
            </div>
          </figure>
        </div>

        <!-- Card Details Column -->
        <div class="column is-two-thirds-desktop is-half-tablet is-full-mobile card-details">
          <div class="card-header-info">
            <h2 class="title is-3-mobile is-2-tablet is-1-desktop">{{ card.name }}</h2>
            <p class="subtitle is-5-mobile is-4-tablet is-4-desktop">
              <span class="set-badge">{{ card.set }}</span>
              <span class="set-code">({{ card.set_code }})</span>
            </p>
          </div>

          <!-- Card Properties -->
          <div class="card-properties">
            <div class="property" v-if="card.mana_cost">
              <span class="property-label">Mana Cost:</span>
              <span class="property-value">{{ card.mana_cost }}</span>
            </div>
            <div class="property" v-if="card.type_line">
              <span class="property-label">Type:</span>
              <span class="property-value">{{ card.type_line }}</span>
            </div>
          </div>

          <!-- Oracle Text -->
          <div v-if="card.oracle_text" class="oracle-box">
            <p class="oracle-text">{{ card.oracle_text }}</p>
          </div>

          <!-- Prices Section -->
          <div class="prices-section" v-if="Object.keys(card.prices).length > 0">
            <h4 class="title is-5">💰 Market Prices</h4>
            <div class="price-grid">
              <div 
                v-for="(price, currency) in card.prices" 
                :key="currency"
                class="price-card"
              >
                <p class="price-currency">{{ currency.toString().toUpperCase() }}</p>
                <p class="price-value">${{ (price ?? 0).toFixed(2) }}</p>
              </div>
            </div>
          </div>
          <div class="notification is-warning" v-else>
            <p>Price information not available for this card</p>
          </div>

          <!-- Action Buttons -->
          <div class="buttons mt-5">
            <button 
              @click="addToCollection" 
              class="button is-success is-large"
              ref="addButton">
              <span class="icon">
                <i class="fas fa-plus-circle"></i>
              </span>
              <span>Add to Collection</span>
            </button>
            <a :href="card.scryfall_uri" target="_blank" class="button is-info is-large">
              <span class="icon">
                <i class="fas fa-external-link-alt"></i>
              </span>
              <span>View on Scryfall</span>
            </a>
          </div>

          <div v-if="addedMessage" class="notification is-success mt-4">
            <button @click="addedMessage = ''" class="delete"></button>
            <p><strong>Success!</strong> {{ addedMessage }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import api from '../services/api'
import type { SearchResult } from '../types'
import { useCollection } from '../composables/useCollection'

const query = ref('')
const card = ref<SearchResult | null>(null)
const loading = ref(false)
const error = ref('')
const addedMessage = ref('')
const addButton = ref<HTMLButtonElement | null>(null)

const { addAnimation, incrementCount } = useCollection()

const searchCard = async () => {
  if (!query.value.trim()) return
  
  loading.value = true
  error.value = ''
  card.value = null
  addedMessage.value = ''

  try {
    card.value = await api.searchCard(query.value)
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Failed to search for card'
  } finally {
    loading.value = false
  }
}

const addToCollection = async () => {
  if (!card.value || !addButton.value) return

  try {
    const price = card.value.prices.usd || 0
    
    addAnimation(addButton.value, {
      name: card.value.name,
      set: card.value.set,
      price: price,
      image_uri: card.value.image_uri
    })
    
    await api.addToCollection({
      name: card.value.name,
      set: card.value.set,
      price: price,
      image_uri: card.value.image_uri
    })

    incrementCount()
    addedMessage.value = `${card.value.name} added to collection!`
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Failed to add card to collection'
  }
}
</script>

<style scoped>
.search-container {
  border-radius: 24px;
  border: 2px solid #F0F0F0;
}

.search-input {
  border-radius: 16px;
  font-size: 1.1rem;
}

.search-input::placeholder {
  color: #B0B0B0;
  font-style: italic;
}

.card-image-container {
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 12px 40px rgba(102, 126, 234, 0.25);
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.card-image-container:hover {
  transform: translateY(-8px);
  box-shadow: 0 16px 48px rgba(255, 107, 157, 0.3);
}

.card-display-image {
  width: 100%;
  height: auto;
  display: block;
  border-radius: 20px;
}

.no-image-placeholder {
  background: linear-gradient(135deg, #F8F7FF 0%, #F0EBFF 100%);
  border-radius: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
  color: #888899;
}

.card-details {
  display: flex;
  flex-direction: column;
}

.card-header-info {
  margin-bottom: 2rem;
}

.set-badge {
  display: inline-block;
  background: var(--secondary-gradient);
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 12px;
  font-weight: 700;
  font-size: 0.9rem;
  margin-right: 0.5rem;
}

.set-code {
  color: #888899;
  font-weight: 600;
}

.card-properties {
  background: #F8F7FF;
  border-radius: 16px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
}

.property {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 0;
  border-bottom: 1px solid rgba(255, 107, 157, 0.1);
}

.property:last-child {
  border-bottom: none;
}

.property-label {
  font-weight: 700;
  color: #2C2C7C;
}

.property-value {
  color: #666688;
  font-weight: 600;
}

.oracle-box {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(192, 107, 255, 0.05) 100%);
  border-left: 4px solid var(--secondary-gradient);
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
}

.oracle-text {
  color: #2C2C7C;
  line-height: 1.6;
  font-weight: 500;
}

.prices-section {
  margin-bottom: 2rem;
}

.price-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 1rem;
  margin-top: 1rem;
}

.price-card {
  background: linear-gradient(135deg, #FFB347 0%, #FF8C47 100%);
  color: white;
  border-radius: 16px;
  padding: 1.25rem;
  text-align: center;
  box-shadow: var(--shadow-sm);
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.price-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(255, 140, 71, 0.3);
}

.price-currency {
  font-size: 0.8rem;
  font-weight: 700;
  opacity: 0.9;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.price-value {
  font-size: 1.5rem;
  font-weight: 900;
  margin: 0.5rem 0 0 0;
}
</style>
