<template>
  <div :class="styles.scannerCard" class="card" v-if="props.card.image_uri || props.failed">
    <!-- Card Image as Background (if available) -->
    <img v-if="props.card.image_uri" :src="props.card.image_uri" :alt="props.card.name" :class="styles.cardImageBg">
    
    <!-- Placeholder for failed cards without image -->
    <div v-else :class="styles.cardImageBg">
      <div :class="styles.imagePlaceholder">
        <i class="fas fa-image" style="font-size: 2rem;"></i>
      </div>
    </div>
    
    <!-- Button (Add or Failed Indicator) -->
    <button 
      @click="addCard"
      :class="[styles.cornerButton, props.failed ? styles.failedButton : styles.addButton]"
      :title="props.failed ? 'Price not found' : 'Add to Collection'">
      <i :class="props.failed ? 'fas fa-times' : 'fas fa-plus'"></i>
    </button>
    
    <!-- Overlay Content (Bottom) -->
    <div :class="styles.cardOverlay">
      <!-- Card Info with Gradient Background -->
      <div :class="styles.cardContent">
        <p class="subtitle is-7" v-if="props.card.set" :class="styles.cardSet">{{ props.card.set }}</p>
        <p class="title is-6" :class="styles.cardName">{{ props.card.name }}</p>
        
        <div :class="styles.cardPrice" v-if="props.card.price && !props.failed">
          <p :class="styles.priceLabel"><i class="fas fa-dollar-sign"></i></p>
          <p :class="styles.priceValue">{{ props.card.price.toFixed(2) }}</p>
        </div>
        
        <p class="has-text-danger" v-else-if="props.failed">
          Price not found
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import api from '../services/api'
import type { Card } from '../types'
import { useCollection } from '../composables/useCollection'
import styles from './CardItem.module.scss'

interface Props {
  card: Card
  failed?: boolean
}

interface Emits {
  (e: 'card-added'): void
}

const props = withDefaults(defineProps<Props>(), {
  failed: false
})
const emit = defineEmits<Emits>()

const { addAnimation, incrementCount } = useCollection()

const addCard = async (event: Event) => {
  const buttonElement = event.target as HTMLButtonElement
  
  try {
    addAnimation(buttonElement, {
      name: props.card.name,
      set: props.card.set,
      price: props.card.price || 0,
      image_uri: props.card.image_uri || ''
    })
    
    await api.addToCollection({
      name: props.card.name,
      set: props.card.set,
      price: props.card.price || 0,
      image_uri: props.card.image_uri || ''
    })

    incrementCount()
    buttonElement.classList.add('is-loading')
    setTimeout(() => {
      buttonElement.classList.remove('is-loading')
    }, 500)
    
    emit('card-added')
  } catch (error) {
    console.error('Failed to add card to collection:', error)
  }
}
</script>
