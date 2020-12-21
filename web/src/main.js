import Vue from 'vue'
import App from './App.vue'

import VueMaterial from "vue-material";
Vue.use(VueMaterial);
import 'vue-material/dist/vue-material.min.css'
import 'vue-material/dist/theme/default.css'

Vue.config.productionTip = false;
Vue.prototype.$hostname = "http://34.67.172.64:5000";
new Vue({
  render: h => h(App),
}).$mount('#app');
