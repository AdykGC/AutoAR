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
  max-width: 380px;
  margin: 0 auto;
  padding: 15% 4rem 4rem 4rem;
  /*
  text-align: center;
  margin: 0 auto;
  padding: 2rem;
  */
}
</style>
