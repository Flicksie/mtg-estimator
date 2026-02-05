<template>
  <footer class="footer">
    <div class="content has-text-centered">
      <p>
        <strong>✨ MTG Card Estimator ✨</strong> &copy; {{ currentYear }} | 
        Data provided by <a href="https://scryfall.com" target="_blank">Scryfall</a>
      </p>
      <p class="is-size-7 has-text-grey-light">
        Made with 💜 for card collectors everywhere
      </p>
    </div>
  </footer>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const currentYear = computed(() => new Date().getFullYear())
</script>

<style scoped>
a {
    color: #FF6B9D;
    text-decoration: none;
    transition: all 0.3s ease;
}

a:hover {
    color: #FFB3D9;
    text-decoration: underline;
}
</style>
