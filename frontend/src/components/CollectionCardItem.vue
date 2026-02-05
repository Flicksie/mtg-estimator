<template>
  <div :class="styles.collectionCardWrapper" :style="{ 'animation-delay': `${props.index * 0.05}s` }">
    <!-- Remove Button Overlay -->
    <button 
      @click="handleRemove"
      :class="[styles.cornerButton, styles.removeButton]"
      title="Remove from Collection">
      <i class="fas fa-trash-alt"></i>
    </button>

    <!-- Card Base (Image + Info) -->
    <div :class="styles.cardBase">
      <img v-if="props.card.image_uri" :src="props.card.image_uri" :alt="props.card.name" :class="styles.cardImageBg">
      
      <div v-else :class="styles.cardImageBg">
        <div :class="styles.imagePlaceholder">
          <i class="fas fa-image" style="font-size: 2rem;"></i>
        </div>
      </div>

      <!-- Overlay Content -->
      <div :class="styles.cardOverlay">
        <div :class="styles.cardContent">
          <p class="subtitle is-7" v-if="props.card.set" :class="styles.cardSet">{{ props.card.set }}</p>
          <p class="title is-6" :class="styles.cardName">{{ props.card.name }}</p>
          
          <div :class="styles.cardPrice" v-if="props.card.price">
            <p :class="styles.priceLabel"><i class="fas fa-dollar-sign"></i></p>
            <p :class="styles.priceValue">{{ props.card.price.toFixed(2) }}</p>
          </div>

          <p class="is-size-7" v-if="props.card.added_date" :class="styles.dateAdded">
            <i class="fas fa-calendar"></i> {{ formatDate(props.card.added_date) }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useSwal } from '../composables/useSwal'
import type { Card } from '../types'
import styles from './CollectionCardItem.module.scss'

interface Props {
  card: Card
  index: number
}

interface Emits {
  (e: 'remove', cardId: number): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()
const { fire: swal } = useSwal()

const handleRemove = async () => {
  if (!props.card.id) return
  
  const result = await swal({
    title: 'Remove Card?',
    text: 'This card will be removed from your collection',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Remove',
    cancelButtonText: 'Cancel'
  })

  if (result.isConfirmed) {
    emit('remove', props.card.id)
  }
}

const formatDate = (dateStr?: string) => {
  if (!dateStr) return 'Unknown'
  const date = new Date(dateStr)
  return date.toLocaleDateString()
}
</script>
