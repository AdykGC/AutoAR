<template>
  <div id="profile">
    <UserCard />
    <UserNavCard />
  </div>
</template>

<script setup>

import UserCard from '../components/Profile/UserCard.vue';
import UserNavCard from '../components/Profile/UserNavCard.vue';

</script>

<style scoped>
#profile {
  margin: 0 auto;
  padding: 2rem;
}
</style>
