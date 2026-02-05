<template>
  <div>
    <!-- Hero Section -->
    <section class="hero">
      <div class="hero-body">
        <p class="title">
          ✨ Welcome to MTG Estimator ✨
        </p>
        <p class="subtitle">
          Discover, scan, and value your Magic: The Gathering collection with AI-powered precision
        </p>
      </div>
    </section>

    <!-- Statistics Cards -->
    <div class="columns mt-5">
      <div class="column floating" style="animation-delay: 0s">
        <div class="notification is-primary stats-card">
          <p class="heading">📚 Your Collection</p>
          <p class="title stat-number">{{ stats.total_cards }}</p>
          <p class="subtitle">Total Cards</p>
        </div>
      </div>
      
      <div class="column floating" style="animation-delay: 0.2s">
        <div class="notification is-success stats-card">
          <p class="heading">💰 Total Value</p>
          <p class="title stat-number">${{ stats.total_value.toFixed(2) }}</p>
          <p class="subtitle">Estimated USD</p>
        </div>
      </div>
      
      <div class="column floating" style="animation-delay: 0.4s">
        <div class="notification" :class="stats.ocr_available ? 'is-success' : 'is-warning'" style="height: 100%">
          <p class="heading">🔍 Scanner Status</p>
          <p class="title" style="margin: 1rem 0;">
            <span class="icon is-large">
              <i class="fas" :class="stats.ocr_available ? 'fa-check-circle' : 'fa-exclamation-circle'" style="font-size: 2.5rem;"></i>
            </span>
          </p>
          <p class="subtitle">
            {{ stats.ocr_available ? 'Ready to Scan' : 'Limited Mode' }}
          </p>
          <button class="button is-small is-light mt-2" @click="reloadOCRStatus">Check Status</button>
        </div>
      </div>
    </div>

    <!-- Feature Cards -->
    <div class="columns mt-6">
      <div class="column">
        <div class="card feature-card search-card">
          <div class="card-content has-text-centered">
            <span class="feature-icon search-icon">🔎</span>
            <h3 class="title is-4 mt-4">Card Search</h3>
            <p class="has-text-grey-dark">Find any Magic card and get instant pricing from our database</p>
            <router-link to="/search" class="button is-primary mt-4">
              <span class="icon"><i class="fas fa-search"></i></span>
              <span>Search Cards</span>
            </router-link>
          </div>
        </div>
      </div>
      
      <div class="column">
        <div class="card feature-card scanner-card">
          <div class="card-content has-text-centered">
            <span class="feature-icon scanner-icon">📸</span>
            <h3 class="title is-4 mt-4">Smart Scanner</h3>
            <p class="has-text-grey-dark">Upload images and our AI identifies cards automatically</p>
            <router-link to="/scanner" class="button is-success mt-4">
              <span class="icon"><i class="fas fa-camera"></i></span>
              <span>Open Scanner</span>
            </router-link>
          </div>
        </div>
      </div>
      
      <div class="column">
        <div class="card feature-card collection-card">
          <div class="card-content has-text-centered">
            <span class="feature-icon collection-icon">📖</span>
            <h3 class="title is-4 mt-4">My Collection</h3>
            <p class="has-text-grey-dark">Track, manage, and export your entire card collection</p>
            <router-link to="/collection" class="button is-info mt-4">
              <span class="icon"><i class="fas fa-book"></i></span>
              <span>View Collection</span>
            </router-link>
          </div>
        </div>
      </div>
    </div>

    <!-- How It Works -->
    <div class="box mt-6 how-it-works-box">
      <h3 class="title is-3">✨ How It Works</h3>
      
      <div class="columns is-multiline mt-5">
        <div class="column is-one-quarter-desktop is-half-tablet">
          <div class="tutorial-step">
            <div class="step-number">1️⃣</div>
            <h4 class="title is-5">Upload or Search</h4>
            <p class="is-size-7">Use Scanner to upload card images, or Search by name</p>
          </div>
        </div>

        <div class="column is-one-quarter-desktop is-half-tablet">
          <div class="tutorial-step">
            <div class="step-number">2️⃣</div>
            <h4 class="title is-5">Auto Recognition</h4>
            <p class="is-size-7">AI analyzes images and extracts card information</p>
          </div>
        </div>

        <div class="column is-one-quarter-desktop is-half-tablet">
          <div class="tutorial-step">
            <div class="step-number">3️⃣</div>
            <h4 class="title is-5">Get Live Pricing</h4>
            <p class="is-size-7">Fetch current market prices from Scryfall</p>
          </div>
        </div>

        <div class="column is-one-quarter-desktop is-half-tablet">
          <div class="tutorial-step">
            <div class="step-number">4️⃣</div>
            <h4 class="title is-5">Manage & Export</h4>
            <p class="is-size-7">Track collection value and export your data</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Warning Banner -->
    <div v-if="!stats.ocr_available" class="notification is-warning mt-5" style="border-radius: 20px;">
      <h5 class="title is-5"><i class="fas fa-exclamation-circle"></i> Scanner Unavailable</h5>
      <p>You can still search cards manually and use all other features!</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../services/api'
import type { Stats } from '../types'

const stats = ref<Stats>({
  total_cards: 0,
  total_value: 0,
  ocr_available: false
})

const loadStats = async () => {
  try {
    stats.value = await api.getStats()
  } catch (error) {
    console.error('Failed to load stats:', error)
  }
}

const reloadOCRStatus = async () => {
  try {
    const ocrStatus = await api.getStats()
    stats.value.ocr_available = ocrStatus.ocr_available
  } catch (error) {
    console.error('Failed to reload OCR status:', error)
  }
}

onMounted(() => {
  loadStats()
})
</script>

<style scoped>
.stat-number {
  font-size: 2.5rem;
  font-weight: 900;
  margin: 0.5rem 0;
}

.stats-card {
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  border-radius: 20px;
}

.feature-card {
  border-radius: 24px;
  position: relative;
  overflow: visible;
  border: 3px solid transparent;
  background: white;
}

.feature-card::before {
  content: '';
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  border-radius: 24px;
  z-index: -1;
  opacity: 0;
  transition: all 0.4s ease;
}

.search-card::before {
  background: linear-gradient(135deg, #FF6B9D 0%, #FFB3D9 100%);
}

.scanner-card::before {
  background: linear-gradient(135deg, #11D8A2 0%, #00D4FF 100%);
}

.collection-card::before {
  background: linear-gradient(135deg, #667EEA 0%, #764BA2 100%);
}

.feature-card:hover {
  transform: translateY(-16px) scale(1.02);
}

.feature-card:hover::before {
  opacity: 1;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
}

.feature-icon {
  display: block;
  font-size: 4rem;
  margin: 0 auto;
  animation: float 3s ease-in-out infinite;
}

.search-icon {
  animation-delay: 0s;
}

.scanner-icon {
  animation-delay: 0.2s;
}

.collection-icon {
  animation-delay: 0.4s;
}

.how-it-works-box {
  background: white;
  border-radius: 24px;
  border: 2px solid #F0F0F0;
}

.tutorial-step {
  background: linear-gradient(135deg, #F8F7FF 0%, #F0EBFF 100%);
  border-radius: 16px;
  padding: 1.5rem;
  text-align: center;
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
  border: 2px solid transparent;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.tutorial-step:hover {
  background: linear-gradient(135deg, #FF6B9D 0%, #C06BFF 50%, #5B61FF 100%);
  color: white;
  transform: translateY(-8px);
  border-color: white;
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
}

.tutorial-step:hover .title,
.tutorial-step:hover p {
  color: white;
}

.step-number {
  font-size: 2.5rem;
  display: block;
  margin-bottom: 1rem;
}

.title {
  color: #2C2C7C;
}

.subtitle {
  color: #666688;
}
</style>
