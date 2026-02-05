<template>
  <div>
    <h1 class="title"><i class="fas fa-camera"></i> Smart Card Scanner</h1>
    <p class="subtitle">Upload card images for AI-powered automatic identification</p>

    <!-- OCR Status Banner -->
    <div class="notification scanner-status" :class="ocrAvailable ? 'is-success' : 'is-warning'">
      <p v-if="ocrAvailable">
        <span class="icon"><i class="fas fa-check-circle"></i></span>
        <strong>AI Scanner Active!</strong> Upload images and we'll identify your cards automatically
      </p>
      <p v-else>
        <span class="icon"><i class="fas fa-exclamation-circle"></i></span>
        <strong>Manual Mode</strong> Upload images and enter card names manually
      </p>
    </div>

    <!-- API Key Input (Optional) -->
    <div class="box api-key-box">
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
            placeholder="Enter your own API key (optional)">
        </div>
        <p class="help">Your key is stored locally and never shared</p>
      </div>
    </div>

    <!-- File Upload Section -->
    <div class="box upload-container">
      <div class="file has-name is-boxed is-fullwidth upload-area">
        <label class="file-label">
          <input 
            class="file-input" 
            type="file" 
            @change="onFileSelected"
            accept="image/*"
            ref="fileInput">
          <span class="file-cta">
            <span class="file-icon">
              <i class="fas fa-cloud-upload-alt"></i>
            </span>
            <span class="file-label-text">
              <strong>Drag files or click to upload</strong><br>
              <small>Supports JPG, PNG, WebP and more</small>
            </span>
          </span>
          <span class="file-name" v-if="selectedFile">
            <i class="fas fa-check"></i> {{ selectedFile.name }}
          </span>
        </label>
      </div>

      <!-- Image Preview -->
      <div v-if="imagePreview" class="image-preview-container mt-4">
        <figure class="image">
          <img :src="imagePreview" alt="Preview" class="preview-img">
        </figure>
      </div>

      <!-- Scan Button -->
      <button 
        @click="uploadImage" 
        :class="['button', 'is-primary', 'is-large', 'is-fullwidth', 'mt-4', { 'is-loading': uploading }]"
        :disabled="!selectedFile || uploading">
        <span class="icon">
          <i class="fas fa-magic"></i>
        </span>
        <span>{{ uploading ? 'Scanning...' : 'Scan Image' }}</span>
      </button>

      <!-- Error Notification -->
      <div v-if="error" class="notification is-danger mt-4">
        <button @click="error = ''" class="delete"></button>
        <p><strong>Error:</strong> {{ error }}</p>
      </div>

      <!-- Scan Results -->
      <div v-if="results" class="mt-6 results-section">
        <div class="results-header">
          <h2 class="title is-4"><i class="fas fa-bullseye"></i> Scan Results</h2>
          <p class="subtitle is-6">Detected <strong>{{ results.num_detected }}</strong> card(s)</p>
        </div>

        <!-- Warning Message -->
        <div v-if="results.message" class="notification is-warning">
          <p>{{ results.message }}</p>
        </div>

        <!-- Manual Card Name Entry -->
        <div class="field" v-if="results.num_detected > 0 && results.cards.length === 0">
          <label class="label"><i class="fas fa-pen"></i> Enter Card Names (one per line)</label>
          <div class="control">
            <textarea 
              v-model="manualCardNames"
              class="textarea" 
              placeholder="Lightning Bolt&#10;Counterspell&#10;Dark Ritual"
              rows="5"></textarea>
          </div>
          <button 
            @click="identifyCards"
            :class="['button', 'is-primary', 'is-fullwidth', 'mt-3', { 'is-loading': identifying }]"
            :disabled="!manualCardNames || identifying">
            <span class="icon">
              <i class="fas fa-magnifying-glass"></i>
            </span>
            <span>{{ identifying ? 'Identifying...' : 'Identify Cards' }}</span>
          </button>
        </div>

        <!-- Identified Cards Grid -->
        <div v-if="identifiedCards.length > 0" class="mt-5">
          <h3 class="title is-4">Identified Cards</h3>
          
          <div class="columns is-multiline identified-grid">
            <div 
              v-for="(card, index) in identifiedCards" 
              :key="index" 
              class="column is-one-third-desktop is-half-tablet is-full-mobile"
            >
              <div class="card scanner-card">
                <!-- Card Image -->
                <div class="card-image" v-if="card.image_uri">
                  <figure class="image is-4by3">
                    <img :src="card.image_uri" :alt="card.name" class="scanner-card-img">
                  </figure>
                </div>

                <!-- Card Info -->
                <div class="card-content">
                  <p class="title is-6 card-name">{{ card.name }}</p>
                  <p class="subtitle is-7" v-if="card.set">{{ card.set }}</p>
                  
                  <div class="card-price" v-if="card.price">
                    <p class="price-label"><i class="fas fa-dollar-sign"></i></p>
                    <p class="price-value">${{ card.price.toFixed(2) }}</p>
                  </div>
                  
                  <p class="has-text-danger" v-else-if="'found' in card && !card.found">
                    Card not found
                  </p>
                  
                  <button 
                    @click="addToCollection(card, $event)"
                    class="button is-success is-fullwidth mt-3"
                    v-if="'found' in card ? card.found !== false : true">
                    <span class="icon">
                      <i class="fas fa-plus-circle"></i>
                    </span>
                    <span>Add to Collection</span>
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Total Value Summary -->
          <div class="total-value-box mt-5">
            <div class="total-value-content">
              <p class="total-label"><i class="fas fa-gem"></i> Total Estimated Value</p>
              <p class="total-amount">${{ totalValue.toFixed(2) }}</p>
            </div>
            <div class="total-icon"><i class="fas fa-money-bill-wave fa-3x"></i></div>
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
import { useCollection } from '../composables/useCollection'

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

const { addAnimation, incrementCount } = useCollection()

onMounted(() => {
  const savedKey = localStorage.getItem('gemini_api_key')
  if (savedKey) {
    customGeminiKey.value = savedKey
  }
  checkOcrStatus()
})

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
  
  if (imagePreview.value) {
    URL.revokeObjectURL(imagePreview.value)
  }
  
  selectedFile.value = file
  results.value = null
  identifiedCards.value = []
  manualCardNames.value = ''
  
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

const addToCollection = async (card: Card, event: Event) => {
  const button = event.target as HTMLElement
  const buttonElement = button.closest('button') as HTMLButtonElement
  
  if (!buttonElement) return

  try {
    addAnimation(buttonElement, {
      name: card.name,
      set: card.set,
      price: card.price || 0,
      image_uri: card.image_uri || ''
    })
    
    await api.addToCollection({
      name: card.name,
      set: card.set,
      price: card.price || 0,
      image_uri: card.image_uri || ''
    })

    incrementCount()
    buttonElement.classList.add('is-loading')
    setTimeout(() => {
      buttonElement.classList.remove('is-loading')
    }, 500)
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

<style scoped>
.scanner-status {
  border-radius: 20px;
  margin-bottom: 2rem;
  border: none;
}

.api-key-box {
  border-radius: 20px;
  border: 2px solid #F0F0F0;
  margin-bottom: 2rem;
}

.upload-container {
  border-radius: 20px;
  border: 2px solid #F0F0F0;
}

.upload-area {
  background: linear-gradient(135deg, rgba(255, 107, 157, 0.05) 0%, rgba(192, 107, 255, 0.05) 100%);
  border: 2px dashed #FF6B9D;
  border-radius: 20px;
  transition: all 0.3s ease;
  cursor: pointer;
}

.upload-area:hover {
  background: linear-gradient(135deg, rgba(255, 107, 157, 0.1) 0%, rgba(192, 107, 255, 0.1) 100%);
  border-color: #C06BFF;
}

.file-label {
  width: 100%;
  cursor: pointer;
}

.file-cta {
  flex-direction: column;
  gap: 1rem;
  padding: 2rem;
}

.file-icon {
  font-size: 2.5rem;
}

.file-label-text {
  text-align: center;
  color: #2C2C7C;
}

.file-label-text strong {
  font-weight: 700;
  font-size: 1.1rem;
  display: block;
  margin-bottom: 0.5rem;
}

.file-label-text small {
  color: #888899;
  display: block;
}

.image-preview-container {
  border-radius: 20px;
  overflow: hidden;
  box-shadow: var(--shadow-md);
}

.preview-img {
  max-height: 400px;
  width: auto;
  margin: 0 auto;
  display: block;
  border-radius: 20px;
}

.results-section {
  animation: slideIn 0.6s ease;
}

.results-header {
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid #F0F0F0;
}

.identified-grid {
  animation: fadeInUp 0.6s ease;
}

.scanner-card {
  border-radius: 20px;
  overflow: hidden;
  box-shadow: var(--shadow-md);
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.scanner-card:hover {
  transform: translateY(-12px) scale(1.02);
  box-shadow: var(--shadow-lg);
}

.scanner-card-img {
  transition: transform 0.4s ease;
  object-fit: cover;
}

.scanner-card:hover .scanner-card-img {
  transform: scale(1.08);
}

.card-name {
  color: #2C2C7C;
  font-weight: 800;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-price {
  background: linear-gradient(135deg, #FFB347 0%, #FF8C47 100%);
  color: white;
  border-radius: 12px;
  padding: 1rem;
  text-align: center;
  margin: 1rem 0;
}

.price-label {
  font-size: 1.5rem;
  margin: 0;
}

.price-value {
  font-size: 1.5rem;
  font-weight: 900;
  margin: 0;
}

.total-value-box {
  background: linear-gradient(135deg, #11D8A2 0%, #00D4FF 100%);
  color: white;
  border-radius: 24px;
  padding: 2.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: var(--shadow-lg);
  animation: float 3s ease-in-out infinite;
}

.total-label {
  font-size: 1rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1px;
  opacity: 0.95;
  margin: 0;
}

.total-amount {
  font-size: 2.5rem;
  font-weight: 900;
  margin: 0.5rem 0 0 0;
}

.total-icon {
  font-size: 4rem;
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

@media screen and (max-width: 768px) {
  .total-value-box {
    flex-direction: column;
    text-align: center;
    gap: 1rem;
  }

  .file-cta {
    padding: 1.5rem;
  }
}
</style>
