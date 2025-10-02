<template>
    <div id="tabs">
        <button class="tab active" data-tab="projects">Projects</button>
        <button class="tab" data-tab="likes">Likes</button>
        <button class="tab" data-tab="following">Following</button>
        <button class="tab" data-tab="followers">Followers</button>
    </div>
</template>


<style scoped>
#tabs {
    display: flex;
    gap: 1rem;
    margin-bottom: 2rem;
    padding: 1rem;
    background: var(--card-bg);
    border-radius: 15px;
    box-shadow: var(--card-shadow);
}

.tab {
    background: none;
    border: none;
    font-size: 1.1rem;
    color: var(--text);
    cursor: pointer;
    padding: 0.8rem 1.5rem;
    border-radius: 12px;
    transition: all 0.3s;
}

.tab:hover:not(.active) {
    background: rgba(255, 255, 255, 0.1);
}

.tab.active {
    background: var(--primary-gradient);
    color: white;
    font-weight: 500;
}
</style>