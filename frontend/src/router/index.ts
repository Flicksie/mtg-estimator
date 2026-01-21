import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import Search from '../views/Search.vue'
import Scanner from '../views/Scanner.vue'
import Collection from '../views/Collection.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home
    },
    {
      path: '/search',
      name: 'search',
      component: Search
    },
    {
      path: '/scanner',
      name: 'scanner',
      component: Scanner
    },
    {
      path: '/collection',
      name: 'collection',
      component: Collection
    }
  ]
})

export default router
