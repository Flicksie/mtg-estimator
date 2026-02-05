<template>
  <div id="app">
    <Navbar />
    
    <section class="section main-content">
      <div class="container">
        <router-view />
      </div>
    </section>
    
    <Footer />
    <CollectionIcon />
  </div>
</template>

<script setup lang="ts">
import Navbar from './components/Navbar.vue'
import Footer from './components/Footer.vue'
import CollectionIcon from './components/CollectionIcon.vue'
</script>
