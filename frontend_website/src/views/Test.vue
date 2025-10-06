<template>
    <div id="profile">
        <AuthLogin />
    </div>
</template>

<script setup>

import AuthLogin from '../components/Auth/LoginCard.vue';

</script>

<style scoped>
#profile {
  max-width: 1280px;
  margin: 0 auto;
  padding: 4rem;
  /*
  text-align: center;
  margin: 0 auto;
  padding: 2rem;
  */
}
</style>
