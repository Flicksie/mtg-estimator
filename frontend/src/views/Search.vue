<template>
  <div>
    <h1 class="title">Card Search</h1>
    <p class="subtitle">Search for Magic: The Gathering cards by name</p>

    <div class="box">
      <div class="field has-addons">
        <div class="control is-expanded">
          <input 
            v-model="query" 
            @keyup.enter="searchCard"
            class="input is-large" 
            type="text" 
            placeholder="Enter card name (e.g., Lightning Bolt)">
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

      <div v-if="error" class="notification is-danger mt-3">
        <button @click="error = ''" class="delete"></button>
        {{ error }}
      </div>

      <div v-if="card" class="columns mt-5">
        <div class="column is-one-third">
          <figure class="image">
            <img :src="card.image_uri" :alt="card.name" v-if="card.image_uri">
            <div v-else class="has-background-light has-text-centered p-6">
              <span class="icon is-large">
                <i class="fas fa-image" style="font-size: 3rem;"></i>
              </span>
              <p>No image available</p>
            </div>
          </figure>
        </div>
        <div class="column">
          <h2 class="title is-3">{{ card.name }}</h2>
          <p class="subtitle is-5">{{ card.set }} ({{ card.set_code }})</p>

          <div class="content">
            <p v-if="card.mana_cost"><strong>Mana Cost:</strong> {{ card.mana_cost }}</p>
            <p v-if="card.type_line"><strong>Type:</strong> {{ card.type_line }}</p>
            <p v-if="card.oracle_text" class="box">{{ card.oracle_text }}</p>
          </div>

          <div class="box" v-if="Object.keys(card.prices).length > 0">
            <h4 class="title is-5">Prices</h4>
            <table class="table is-fullwidth">
              <tbody>
                <tr v-for="(price, currency) in card.prices" :key="currency">
                  <td><strong>{{ currency.toString().toUpperCase() }}</strong></td>
                  <td class="has-text-right">${{ (price ?? 0).toFixed(2) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="notification is-warning" v-else>
            <p>Price information not available for this card.</p>
          </div>

          <div class="buttons mt-4">
            <button 
              @click="addToCollection" 
              class="button is-success"
              ref="addButton">
              <span class="icon">
                <i class="fas fa-plus"></i>
              </span>
              <span>Add to Collection</span>
            </button>
            <a :href="card.scryfall_uri" target="_blank" class="button is-link">
              <span class="icon">
                <i class="fas fa-external-link-alt"></i>
              </span>
              <span>View on Scryfall</span>
            </a>
          </div>

          <div v-if="addedMessage" class="notification is-success mt-3">
            <button @click="addedMessage = ''" class="delete"></button>
            {{ addedMessage }}
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

  console.log('Adding to collection, button element:', addButton.value)

  try {
    const price = card.value.prices.usd || 0
    
    // Trigger the animation
    addAnimation(addButton.value, {
      name: card.value.name,
      set: card.value.set,
      price: price,
      image_uri: card.value.image_uri
    })
    
    console.log('Animation triggered for:', card.value.name)
    
    await api.addToCollection({
      name: card.value.name,
      set: card.value.set,
      price: price,
      image_uri: card.value.image_uri
    })

    incrementCount()
    addedMessage.value = 'Card added to collection!'
    console.log('Card added successfully')
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Failed to add card to collection'
    console.error('Error adding to collection:', err)
  }
}
</script>
