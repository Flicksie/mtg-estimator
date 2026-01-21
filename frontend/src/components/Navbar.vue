<template>
  <nav class="navbar is-dark" role="navigation" aria-label="main navigation">
    <div class="container">
      <div class="navbar-brand">
        <router-link to="/" class="navbar-item">
          <span class="icon"><i class="fas fa-chess-queen"></i></span>
          <span class="ml-2"><strong>MTG Estimator</strong></span>
        </router-link>
        
        <a
          role="button"
          class="navbar-burger"
          :class="{ 'is-active': isMobileMenuActive }"
          aria-label="menu"
          aria-expanded="false"
          @click="toggleMobileMenu"
        >
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
        </a>
      </div>

      <div class="navbar-menu" :class="{ 'is-active': isMobileMenuActive }">
        <div class="navbar-end">
          <router-link to="/" class="navbar-item" @click="closeMobileMenu">
            <span class="icon"><i class="fas fa-home"></i></span>
            <span>Home</span>
          </router-link>
          <router-link to="/search" class="navbar-item" @click="closeMobileMenu">
            <span class="icon"><i class="fas fa-search"></i></span>
            <span>Search</span>
          </router-link>
          <router-link to="/scanner" class="navbar-item" @click="closeMobileMenu">
            <span class="icon"><i class="fas fa-camera"></i></span>
            <span>Scanner</span>
          </router-link>
          <router-link to="/collection" class="navbar-item" @click="closeMobileMenu">
            <span class="icon"><i class="fas fa-book"></i></span>
            <span>Collection</span>
          </router-link>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const isMobileMenuActive = ref(false)

const toggleMobileMenu = () => {
  isMobileMenuActive.value = !isMobileMenuActive.value
}

const closeMobileMenu = () => {
  isMobileMenuActive.value = false
}
</script>
