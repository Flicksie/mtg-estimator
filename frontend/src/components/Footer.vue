<template>
  <footer class="footer has-background-dark has-text-white-ter">
    <div class="content has-text-centered">
      <p class="has-text-white-ter">
        <strong class="has-text-white">MTG Card Estimator</strong> &copy; {{ currentYear }} | 
        Data provided by <a href="https://scryfall.com" target="_blank" class="has-text-link">Scryfall</a>
      </p>
    </div>
  </footer>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const currentYear = computed(() => new Date().getFullYear())
</script>
