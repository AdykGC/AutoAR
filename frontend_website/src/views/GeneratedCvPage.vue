<template>
    <div class="resume-container">
        <user></user>
        <professional_summary></professional_summary>
        <education></education>
        <skills></skills>
        <experience></experience>
    </div>
</template>

<script setup>

import user from '../components/GeneratedCv/user.vue';
import professional_summary from '../components/GeneratedCv/summary.vue';
import experience from '../components/GeneratedCv/experience.vue';
import skills from '../components/GeneratedCv/skills.vue';
import education from '../components/GeneratedCv/education.vue';

</script>

<style scoped>
.resume-container{
    width: 100%;
    height: 100%;
    background: var(--background2);
}
</style>
