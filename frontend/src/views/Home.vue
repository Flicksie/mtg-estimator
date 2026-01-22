<template>
  <div>
    <!-- Hero Section -->
    <section class="hero is-info">
      <div class="hero-body">
        <p class="title">
          Welcome to MTG Card Estimator
        </p>
        <p class="subtitle">
          Detect, identify, and estimate the value of your Magic: The Gathering cards.
        </p>
      </div>
    </section>

    <!-- Statistics -->
    <div class="columns mt-5">
      <div class="column">
        <div class="notification is-primary">
          <p class="heading">Your Collection</p>
          <p class="title">{{ stats.total_cards }}</p>
          <p class="subtitle">Total Cards</p>
        </div>
      </div>
      
      <div class="column">
        <div class="notification is-success">
          <p class="heading">Total Value</p>
          <p class="title">${{ stats.total_value.toFixed(2) }}</p>
          <p class="subtitle">Estimated USD</p>
        </div>
      </div>
      
      <div class="column">
        <div class="notification" :class="stats.ocr_available ? 'is-success' : 'is-warning'">
          <p class="heading">OCR Status</p>
          <p class="title">
            <span class="icon is-large">
              <i class="fas" :class="stats.ocr_available ? 'fa-check-circle' : 'fa-exclamation-triangle'" style="font-size: 2rem;"></i>
            </span>
          </p>
          <p class="subtitle">
            {{ stats.ocr_available ? 'Available' : 'Limited' }}
            <button class="button is-small" @click="reloadOCRStatus">Reload Status</button>
          </p>
        </div>
      </div>
    </div>

    <!-- Feature Cards -->
    <div class="columns mt-4">
      <div class="column">
        <div class="card">
          <div class="card-content has-text-centered">
            <span class="icon is-large has-text-primary">
              <i class="fas fa-search" style="font-size: 3rem;"></i>
            </span>
            <h3 class="title is-4 mt-3">Card Search</h3>
            <p>Search for any Magic: The Gathering card and get detailed information including current market prices.</p>
            <router-link to="/search" class="button is-primary mt-3">Go to Search</router-link>
          </div>
        </div>
      </div>
      
      <div class="column">
        <div class="card">
          <div class="card-content has-text-centered">
            <span class="icon is-large has-text-success">
              <i class="fas fa-camera" style="font-size: 3rem;"></i>
            </span>
            <h3 class="title is-4 mt-3">Card Scanner</h3>
            <p>Upload or capture images of your cards. Our OCR technology will identify them automatically.</p>
            <router-link to="/scanner" class="button is-success mt-3">Go to Scanner</router-link>
          </div>
        </div>
      </div>
      
      <div class="column">
        <div class="card">
          <div class="card-content has-text-centered">
            <span class="icon is-large has-text-info">
              <i class="fas fa-book" style="font-size: 3rem;"></i>
            </span>
            <h3 class="title is-4 mt-3">My Collection</h3>
            <p>View and manage your card collection. Track values and export your collection data.</p>
            <router-link to="/collection" class="button is-info mt-3">View Collection</router-link>
          </div>
        </div>
      </div>
    </div>

    <!-- How It Works -->
    <div class="box mt-5">
      <h3 class="title is-3">How It Works</h3>
      
      <div class="content">
        <div class="message">
          <div class="message-header">
            <p>1. Upload or Search</p>
          </div>
          <div class="message-body">
            Use the <strong>Scanner</strong> to upload images of your cards, or use the <strong>Search</strong> feature to look up cards by name.
          </div>
        </div>

        <div class="message">
          <div class="message-header">
            <p>2. Automatic Identification</p>
          </div>
          <div class="message-body">
            Our OCR technology analyzes card images to extract card names. You can also provide card names manually for best results.
          </div>
        </div>

        <div class="message">
          <div class="message-header">
            <p>3. Get Pricing</p>
          </div>
          <div class="message-body">
            We fetch current market prices from Scryfall's comprehensive database, giving you accurate price estimates for your cards.
          </div>
        </div>

        <div class="message">
          <div class="message-header">
            <p>4. Manage Collection</p>
          </div>
          <div class="message-body">
            Add cards to your collection, track total value, and export your collection data for safekeeping or sharing.
          </div>
        </div>
      </div>
    </div>

    <div v-if="!stats.ocr_available" class="notification is-warning mt-4">
      <h5 class="title is-5"><i class="fas fa-exclamation-triangle"></i> OCR Not Fully Available</h5>
      <p>Tesseract OCR is not installed or not accessible. Automatic card name recognition from images will be limited. You can still:</p>
      <ul>
        <li>Search for cards manually by name</li>
        <li>Upload images and provide card names manually</li>
        <li>Use all other features of the application</li>
      </ul>
      <p><strong>To enable OCR:</strong> Install Tesseract OCR on your system.</p>
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
    console.log('Stats loaded:', stats.value)
  } catch (error) {
    console.error('Failed to load stats:', error)
  }
}

const reloadOCRStatus = async () => {
  try {
    const ocrStatus = await api.getStats()
    stats.value.ocr_available = ocrStatus.ocr_available
    console.log('OCR status reloaded:', ocrStatus)
  } catch (error) {
    console.error('Failed to reload OCR status:', error)
  }
}

onMounted(() => {
  loadStats()
})
</script>
