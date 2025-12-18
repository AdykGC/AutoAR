<template>
  <div id="profile">
    <UserCard />
    <UserNavCard />
    <ProjectCard />
  </div>
</template>

<script setup>

import UserCard from '../../components/Profile/UserCard.vue';
import UserNavCard from '../../components/Profile/UserNavCard.vue';
import ProjectCard from '../../components/Profile/ProjectCard.vue';

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
