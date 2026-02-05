<template>
  <div v-if="results" :class="styles.resultsSection" class="mt-6">
    <div :class="styles.resultsHeader">
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
          :value="manualCardNames"
          @input="emit('update-manual-cards', ($event.target as HTMLTextAreaElement).value)"
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
      
      <div :class="styles.identifiedGrid">
        <CardItem 
          v-for="(card, index) in identifiedCards" 
          :key="index" 
          :card="card"
          @card-added="handleCardAdded"
        />
      </div>

      <!-- Total Value Summary -->
      <div :class="styles.totalValueBox" class="mt-5">
        <div :class="styles.totalValueContent">
          <p :class="styles.totalLabel"><i class="fas fa-gem"></i> Total Estimated Value</p>
          <p :class="styles.totalAmount">${{ totalValue.toFixed(2) }}</p>
        </div>
        <div :class="styles.totalIcon"><i class="fas fa-money-bill-wave fa-3x"></i></div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import CardItem from './CardItem.vue'
import api from '../services/api'
import type { Card, ScanResult } from '../types'
import styles from './CardResults.module.scss'

interface Props {
  results: ScanResult | null
  identifiedCards: Card[]
  totalValue: number
  identifying?: boolean
  manualCardNames?: string
}

interface Emits {
  (e: 'update-manual-cards', value: string): void
  (e: 'identify-cards'): void
  (e: 'card-added'): void
}

const props = withDefaults(defineProps<Props>(), {
  identifying: false,
  manualCardNames: ''
})
const emit = defineEmits<Emits>()

const identifyCards = async () => {
  if (!props.manualCardNames.trim()) return
  emit('identify-cards')
}

const handleCardAdded = () => {
  emit('card-added')
}
</script>
