import { ref } from 'vue'
import type { Card } from '../types'

interface AnimationEvent {
  id: string
  sourceElement: HTMLElement
  card: Partial<Card>
}

// Global shared state
const collectionCount = ref(0)
const pendingAnimations = ref<AnimationEvent[]>([])

export function useCollection() {
  const addAnimation = (sourceElement: HTMLElement, card: Partial<Card>) => {
    const id = `anim-${Date.now()}-${Math.random()}`
    console.log('addAnimation called, adding:', id, card.name)
    pendingAnimations.value.push({ id, sourceElement, card })
    console.log('Current pendingAnimations:', pendingAnimations.value.length)
    
    // Remove after animation completes
    setTimeout(() => {
      pendingAnimations.value = pendingAnimations.value.filter(a => a.id !== id)
      console.log('Animation removed:', id)
    }, 1000) // Match animation duration
  }

  const incrementCount = () => {
    collectionCount.value++
    console.log('Count incremented to:', collectionCount.value)
  }

  const setCount = (count: number) => {
    collectionCount.value = count
    console.log('Count set to:', count)
  }

  return {
    collectionCount,
    pendingAnimations,
    addAnimation,
    incrementCount,
    setCount
  }
}
