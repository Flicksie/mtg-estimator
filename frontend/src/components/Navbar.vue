<template>
  <nav class="navbar" role="navigation" aria-label="main navigation">
    <div class="container">
      <div class="navbar-brand">
        <router-link to="/" class="navbar-item navbar-logo">
          <span class="icon logo-icon"><i class="fas fa-sparkles"></i></span>
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
          <router-link to="/" class="navbar-item nav-link" @click="closeMobileMenu">
            <span class="icon"><i class="fas fa-home"></i></span>
            <span>Home</span>
          </router-link>
          <router-link to="/search" class="navbar-item nav-link" @click="closeMobileMenu">
            <span class="icon"><i class="fas fa-search"></i></span>
            <span>Search</span>
          </router-link>
          <router-link to="/scanner" class="navbar-item nav-link" @click="closeMobileMenu">
            <span class="icon"><i class="fas fa-camera"></i></span>
            <span>Scanner</span>
          </router-link>
          <router-link to="/collection" class="navbar-item nav-link" @click="closeMobileMenu">
            <span class="icon"><i class="fas fa-book"></i></span>
            <span>Collection</span>
          </router-link>
        </div>
      </div>
    </div>
  </nav>
</template>

<style scoped>
.navbar-logo {
    font-size: 1.3rem !important;
    letter-spacing: 1px;
    font-weight: 800;
}

.logo-icon {
    animation: float 3s ease-in-out infinite;
    color: #FFD700;
    text-shadow: 0 0 10px rgba(255, 215, 0, 0.5);
}

.nav-link {
    position: relative;
}

.nav-link::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 50%;
    width: 0;
    height: 2px;
    background: white;
    transform: translateX(-50%);
    transition: width 0.3s ease;
}

.nav-link:hover::after {
    width: 80%;
}
</style>

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
