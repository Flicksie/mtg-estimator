import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

// Import Bulma CSS
import 'bulma/css/bulma.min.css'

// Import custom SCSS
import './assets/styles/custom.scss'

const app = createApp(App)

app.use(router)

app.mount('#app')
