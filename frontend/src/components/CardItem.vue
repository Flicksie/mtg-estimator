<template>
  <div :class="styles.scannerCard" class="card">
    <!-- Card Image -->
    <div :class="styles.cardImage" v-if="props.card.image_uri">
      <img :src="props.card.image_uri" :alt="props.card.name">
    </div>

    <!-- Card Info -->
    <div :class="styles.cardContent">
      <p class="title is-6" :class="styles.cardName">{{ props.card.name }}</p>
      <p class="subtitle is-7" v-if="props.card.set">{{ props.card.set }}</p>
      
      <div :class="styles.cardPrice" v-if="props.card.price">
        <p :class="styles.priceLabel"><i class="fas fa-dollar-sign"></i></p>
        <p :class="styles.priceValue">${{ props.card.price.toFixed(2) }}</p>
      </div>
      
      <p class="has-text-danger" v-else-if="'found' in props.card && !props.card.found">
        Card not found
      </p>
      
      <button 
        @click="addCard"
        class="button is-success is-fullwidth mt-3"
        v-if="'found' in props.card ? props.card.found !== false : true">
        <span class="icon">
          <i class="fas fa-plus-circle"></i>
        </span>
        <span>Add to Collection</span>
      </button>
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
}

interface Emits {
  (e: 'card-added'): void
}

const props = defineProps<Props>()
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
