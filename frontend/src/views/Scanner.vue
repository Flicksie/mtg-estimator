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
      <!-- Camera and Upload Options -->
      <div class="upload-options mb-4">
        <button 
          @click="openCamera" 
          class="button is-info is-medium"
          :disabled="!cameraSupported">
          <span class="icon">
            <i class="fas fa-camera"></i>
          </span>
          <span>Use Camera</span>
        </button>
        <span class="mx-2 has-text-grey">or</span>
        <button 
          @click="loadDemoCards" 
          class="button is-warning is-medium"
          :disabled="uploading">
          <span class="icon">
            <i class="fas fa-wand-magic-sparkles"></i>
          </span>
          <span>Demo Cards</span>
        </button>
      </div>

      <!-- Camera Modal -->
      <div class="modal" :class="{ 'is-active': showCamera }">
        <div class="modal-background" @click="closeCamera"></div>
        <div class="modal-content camera-modal">
          <div class="box">
            <h3 class="title is-4">Capture Card Photo</h3>
            <video ref="videoElement" autoplay playsinline class="camera-video"></video>
            <canvas ref="canvasElement" style="display: none;"></canvas>
            <div class="buttons mt-4">
              <button @click="capturePhoto" class="button is-primary is-large">
                <span class="icon">
                  <i class="fas fa-camera"></i>
                </span>
                <span>Capture</span>
              </button>
              <button @click="closeCamera" class="button is-light is-large">
                <span>Cancel</span>
              </button>
            </div>
          </div>
        </div>
        <button class="modal-close is-large" @click="closeCamera"></button>
      </div>

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

      <!-- Card Results Component -->
      <CardResults 
        :results="results"
        :identified-cards="identifiedCards"
        :failed-cards="failedCards"
        :total-value="totalValue"
        :identifying="identifying"
        :manual-card-names="manualCardNames"
        @update-manual-cards="(value) => manualCardNames = value"
        @identify-cards="identifyCards"
        @card-added="handleCardAdded"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import api from '../services/api'
import CardResults from '../components/CardResults.vue'
import type { Card, ScanResult } from '../types'
import { useCollection } from '../composables/useCollection'

const selectedFile = ref<File | null>(null)
const uploading = ref(false)
const identifying = ref(false)
const error = ref('')
const results = ref<ScanResult | null>(null)
const manualCardNames = ref('')
const identifiedCards = ref<Card[]>([])
const failedCards = ref<Card[]>([])
const totalValue = ref(0)
const ocrAvailable = ref(false)
const fileInput = ref<HTMLInputElement | null>(null)
const customGeminiKey = ref('')
const imagePreview = ref('')
const showCamera = ref(false)
const videoElement = ref<HTMLVideoElement | null>(null)
const canvasElement = ref<HTMLCanvasElement | null>(null)
const mediaStream = ref<MediaStream | null>(null)
const cameraSupported = ref(true)

const { addAnimation, incrementCount } = useCollection()

onMounted(() => {
  const savedKey = localStorage.getItem('gemini_api_key')
  if (savedKey) {
    customGeminiKey.value = savedKey
  }
  checkOcrStatus()
  
  // Check if camera is supported
  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
    cameraSupported.value = false
  }
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
  failedCards.value = []
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
  failedCards.value = []

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
    const allCards = data.cards || []
    identifiedCards.value = allCards.filter((c: Card) => !c.error && c.price_usd)
    failedCards.value = allCards.filter((c: Card) => c.error || !c.price_usd)
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

const openCamera = async () => {
  try {
    showCamera.value = true
    await new Promise(resolve => setTimeout(resolve, 100)) // Wait for modal to render
    
    if (!videoElement.value) return
    
    const stream = await navigator.mediaDevices.getUserMedia({ 
      video: { 
        facingMode: 'environment', // Use back camera on mobile
        width: { ideal: 1920 },
        height: { ideal: 1080 }
      } 
    })
    
    mediaStream.value = stream
    videoElement.value.srcObject = stream
  } catch (err) {
    error.value = 'Failed to access camera: ' + (err instanceof Error ? err.message : 'Unknown error')
    closeCamera()
  }
}

const closeCamera = () => {
  if (mediaStream.value) {
    mediaStream.value.getTracks().forEach(track => track.stop())
    mediaStream.value = null
  }
  showCamera.value = false
}

const capturePhoto = () => {
  if (!videoElement.value || !canvasElement.value) return
  
  const video = videoElement.value
  const canvas = canvasElement.value
  
  // Set canvas dimensions to match video
  canvas.width = video.videoWidth
  canvas.height = video.videoHeight
  
  // Draw current video frame to canvas
  const ctx = canvas.getContext('2d')
  if (ctx) {
    ctx.drawImage(video, 0, 0)
    
    // Convert canvas to blob and create file
    canvas.toBlob((blob) => {
      if (blob) {
        const file = new File([blob], 'camera-capture.jpg', { type: 'image/jpeg' })
        selectedFile.value = file
        imagePreview.value = URL.createObjectURL(file)
        results.value = null
        identifiedCards.value = []
        manualCardNames.value = ''
      }
      closeCamera()
    }, 'image/jpeg', 0.9)
  }
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

const handleIdentifyCards = () => {
  // This is called from CardResults component when cards are identified
  // The component handles the identification directly
}

const handleCardAdded = () => {
  // This is called from CardResults component when a card is added
  // The component handles the addition directly
}

const checkOcrStatus = async () => {
  try {
    const stats = await api.getStats()
    ocrAvailable.value = stats.ocr_available
  } catch (error) {
    console.error('Failed to load OCR status:', error)
  }
}

const loadDemoCards = async () => {
  uploading.value = true
  error.value = ''
  results.value = null
  identifiedCards.value = []
  failedCards.value = []

  try {
    // Demo card names to fetch
    const demoCardNames = ['Lightning Bolt', 'Black Lotus', 'Shock', 'Counterspell', 'Snapcaster Mage']
    const allCards = []

    // Fetch real card data from API for each demo card
    for (const cardName of demoCardNames) {
      try {
        const searchResult = await api.searchCard(cardName)
        if (searchResult) {
          allCards.push({
            name: searchResult.name,
            set: searchResult.set,
            price: searchResult.prices.usd || 0,
            image_uri: searchResult.image_uri || ''
          })
        }
      } catch (err) {
        console.warn(`Failed to fetch ${cardName}:`, err)
        allCards.push({
          name: cardName,
          price: null,
          error: 'Price not found'
        })
      }
    }

    if (allCards.length > 0) {
      results.value = { cards: allCards }
      identifiedCards.value = allCards.filter(c => !c.error && c.price)
      failedCards.value = allCards.filter(c => c.error || !c.price)
      calculateTotal()
    } else {
      error.value = 'Failed to load demo cards'
    }
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Failed to load demo cards'
  } finally {
    uploading.value = false
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

.upload-options {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
}

.camera-modal {
  max-width: 90%;
  width: 800px;
}

.camera-video {
  width: 100%;
  border-radius: 12px;
  background: #000;
  max-height: 70vh;
  object-fit: contain;
}

.camera-modal .buttons {
  display: flex;
  justify-content: center;
  gap: 1rem;
}
</style>

