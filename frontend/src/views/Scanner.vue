<template>
  <div>
    <h1 class="title">Card Scanner</h1>
    <p class="subtitle">Upload images of your cards for automatic identification</p>

    <div class="notification" :class="ocrAvailable ? 'is-info' : 'is-warning'">
      <p v-if="ocrAvailable">
        <span class="icon"><i class="fas fa-info-circle"></i></span>
        OCR is available! Upload card images and we'll try to identify them automatically.
      </p>
      <p v-else>
        <span class="icon"><i class="fas fa-exclamation-triangle"></i></span>
        OCR is not available. You can still upload images and provide card names manually.
      </p>
    </div>

    <div class="box mb-4">
      <div class="field">
        <label class="label">
          <span class="icon-text">
            <span class="icon"><i class="fas fa-key"></i></span>
            <span>Gemini API Key (Optional)</span>
          </span>
        </label>
        <div class="control">
          <input 
            v-model="customGeminiKey"
            class="input" 
            type="password"
            placeholder="Enter your own Gemini API key (optional)">
        </div>
        <p class="help">Leave empty to use server's key. Your key is stored locally and sent with each request.</p>
      </div>
    </div>

    <div class="box">
      <div class="file has-name is-boxed is-large is-fullwidth">
        <label class="file-label">
          <input 
            class="file-input" 
            type="file" 
            @change="onFileSelected"
            accept="image/*"
            ref="fileInput">
          <span class="file-cta">
            <span class="file-icon">
              <i class="fas fa-upload"></i>
            </span>
            <span class="file-label">
              Choose a file…
            </span>
          </span>
          <span class="file-name" v-if="selectedFile">
            {{ selectedFile.name }}
          </span>
        </label>
      </div>

      <div v-if="imagePreview" class="mt-4">
        <figure class="image">
          <img :src="imagePreview" alt="Preview" style="max-height: 400px; width: auto; margin: 0 auto; display: block;">
        </figure>
      </div>

      <button 
        @click="uploadImage" 
        :class="['button', 'is-primary', 'is-large', 'is-fullwidth', 'mt-3', { 'is-loading': uploading }]"
        :disabled="!selectedFile || uploading">
        <span class="icon">
          <i class="fas fa-camera"></i>
        </span>
        <span>Scan Image</span>
      </button>

      <div v-if="error" class="notification is-danger mt-3">
        <button @click="error = ''" class="delete"></button>
        {{ error }}
      </div>

      <div v-if="results" class="mt-5">
        <h2 class="title is-4">Scan Results</h2>
        <p class="subtitle is-6">Detected {{ results.num_detected }} card(s)</p>

        <div v-if="results.message" class="notification is-warning">
          {{ results.message }}
        </div>

        <div class="field" v-if="results.num_detected > 0 && results.cards.length === 0">
          <label class="label">Enter card names (one per line)</label>
          <div class="control">
            <textarea 
              v-model="manualCardNames"
              class="textarea" 
              placeholder="Lightning Bolt&#10;Counterspell&#10;Dark Ritual"
              rows="5"></textarea>
          </div>
          <button 
            @click="identifyCards"
            :class="['button', 'is-primary', 'mt-3', { 'is-loading': identifying }]"
            :disabled="!manualCardNames || identifying">
            <span class="icon">
              <i class="fas fa-search"></i>
            </span>
            <span>Identify Cards</span>
          </button>
        </div>

        <div v-if="identifiedCards.length > 0" class="mt-4">
          <h3 class="title is-5">Identified Cards</h3>
          
          <div class="columns is-multiline">
            <div v-for="(card, index) in identifiedCards" :key="index" class="column is-one-third">
              <div class="card">
                <div class="card-image" v-if="card.image_uri">
                  <figure class="image is-4by3">
                    <img :src="card.image_uri" :alt="card.name">
                  </figure>
                </div>
                <div class="card-content">
                  <p class="title is-5">{{ card.name }}</p>
                  <p class="subtitle is-6" v-if="card.set">{{ card.set }}</p>
                  <p class="has-text-weight-bold has-text-success" v-if="card.price">
                    ${{ card.price.toFixed(2) }}
                  </p>
                  <p class="has-text-danger" v-else-if="'found' in card && !card.found">
                    Card not found
                  </p>
                  <button 
                    @click="addToCollection(card)"
                    class="button is-small is-success is-fullwidth mt-2"
                    v-if="'found' in card ? card.found !== false : true">
                    <span class="icon">
                      <i class="fas fa-plus"></i>
                    </span>
                    <span>Add to Collection</span>
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div class="notification is-success is-light mt-4">
            <p class="title is-5">Total Estimated Value</p>
            <p class="title is-3">${{ totalValue.toFixed(2) }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import api from '../services/api'
import type { Card, ScanResult } from '../types'

const selectedFile = ref<File | null>(null)
const uploading = ref(false)
const identifying = ref(false)
const error = ref('')
const results = ref<ScanResult | null>(null)
const manualCardNames = ref('')
const identifiedCards = ref<Card[]>([])
const totalValue = ref(0)
const ocrAvailable = ref(false)
const fileInput = ref<HTMLInputElement | null>(null)
const customGeminiKey = ref('')
const imagePreview = ref('')

// Load saved key from localStorage
onMounted(() => {
  const savedKey = localStorage.getItem('gemini_api_key')
  if (savedKey) {
    customGeminiKey.value = savedKey
  }
  checkOcrStatus()
})

// Save key to localStorage when it changes
watch(customGeminiKey, (newKey) => {
  if (newKey) {
    localStorage.setItem('gemini_api_key', newKey)
  } else {
    localStorage.removeItem('gemini_api_key')
  }
})

const onFileSelected = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0] || null
  
  // Clean up previous preview URL
  if (imagePreview.value) {
    URL.revokeObjectURL(imagePreview.value)
  }
  
  selectedFile.value = file
  results.value = null
  identifiedCards.value = []
  manualCardNames.value = ''
  
  // Create preview URL for new file
  if (file) {
    imagePreview.value = URL.createObjectURL(file)
  } else {
    imagePreview.value = ''
  }
}

const uploadImage = async () => {
  if (!selectedFile.value) return

  uploading.value = true
  error.value = ''
  results.value = null
  identifiedCards.value = []

  try {
    results.value = await api.scanImage(selectedFile.value, customGeminiKey.value || undefined)
    
    // If cards were automatically identified
    if (results.value.cards && results.value.cards.length > 0) {
      identifiedCards.value = results.value.cards.filter(c => c.name)
      calculateTotal()
    }
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Failed to scan image'
  } finally {
    uploading.value = false
  }
}

const identifyCards = async () => {
  if (!manualCardNames.value.trim()) return

  identifying.value = true
  error.value = ''

  try {
    const cardNames = manualCardNames.value.split('\n')
      .map(name => name.trim())
      .filter(name => name.length > 0)

    const data = await api.identifyCards(cardNames)
    identifiedCards.value = data.cards
    totalValue.value = data.total_value
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Failed to identify cards'
  } finally {
    identifying.value = false
  }
}

const calculateTotal = () => {
  totalValue.value = identifiedCards.value.reduce((sum, card) => {
    return sum + (card.price || 0)
  }, 0)
}

const addToCollection = async (card: Card) => {
  try {
    await api.addToCollection({
      name: card.name,
      set: card.set,
      price: card.price || 0,
      image_uri: card.image_uri || ''
    })

    alert('Card added to collection!')
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Failed to add card to collection'
  }
}

const checkOcrStatus = async () => {
  try {
    const stats = await api.getStats()
    ocrAvailable.value = stats.ocr_available
  } catch (error) {
    console.error('Failed to load OCR status:', error)
  }
}
</script>
