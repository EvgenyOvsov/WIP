<template>
  <div id="app">
    <md-card class="card">
      <h2>Value:</h2>
      <div class="value">
        <h3>{{value}}</h3>
      </div>
      <md-divider></md-divider>
      <div class="container">
        <md-button
                @click="incr"
                class="md-raised md-accent">Increment</md-button>
      </div>
    </md-card>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'App',
  data(){return{
    value: null
  }},
  components: {
  },
  methods: {
    update_data(){
      axios.get(`${this.$hostname}`).then(result => {
        this.value = result.data.Value;
      })
    },
    incr(){
      axios.post(`${this.$hostname}/up`, {"delta": 1}).then(()=>{
        this.update_data();
      })
    }
  },
  mounted() {
    this.update_data()
  }
}
</script>

<style lang="scss">
#app {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
  .card{
    padding: 2rem;
  }
  .value{
    min-width: 4rem;
    min-height: 3rem;
  }
</style>
