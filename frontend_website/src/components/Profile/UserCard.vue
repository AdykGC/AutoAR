<template>
    <div id="header">
        <div id="avatar-container">
            <img id="avatar" alt="Profile avatar" src="https://images.websim.ai/avatar/${user.username}">
        </div>
        <div id="profile-info">
            <h1 id="username">
                ADILKHAN
            </h1>
            <p id="description">
                Hello world
            </p>
            <div id="stats">
                <div class="stat">
                    <span id="total-likes">10</span>
                    <label>Likes</label>
                </div>
                <div class="stat">
                    <span id="total-views">124</span>
                    <label>Views</label>
                </div>
                <div class="stat">
                    <span id="following-count">7</span>
                    <label>Following</label>
                </div>
                <div class="stat">
                    <span id="followers-count">2</span>
                    <label>Followers</label>
                </div>
            </div>
        </div>
    </div>

</template>


<style scoped>
#header {
    display: flex;
    align-items: flex-start;
    gap: 2rem;
    margin-bottom: 2rem;
    background: var(--card-bg);
    padding: 2rem;
    border-radius: 20px;
    box-shadow: var(--card-shadow);
    animation: float 3s ease-in-out infinite;
}

#avatar-container {
    flex-shrink: 0;
    position: relative;
    animation: pulse 2s ease-in-out infinite;
}

#avatar-container::after {
    content: '';
    position: absolute;
    top: -8px;
    left: -8px;
    right: -8px;
    bottom: -8px;
    background: var(--primary-gradient);
    border-radius: 50%;
    z-index: -1;
}

#avatar {
    width: 150px;
    height: 150px;
    border-radius: 50%;
    object-fit: cover;
    border: 4px solid white;
}

#profile-info {
    flex-grow: 1;
}

#username {
    margin: 0;
    font-size: 2.5rem;
    background: var(--primary-gradient);
    -webkit-background-clip: text;
    background-clip: text;
    color: transparent;
}

#description {
    margin: 0.5rem 0;
    color: #666;
    font-size: 1.1rem;
}

#stats {
    display: flex;
    gap: 2rem;
    margin: 1.5rem 0;
}

.stat {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 1rem;
    background: var(--card-bg);
    border-radius: 15px;
    box-shadow: var(--card-shadow);
    transition: transform 0.2s;
    /*     animation: jump 2s ease-in-out infinite;     */
}

.stat:nth-child(1) {
    animation-delay: 0s;
}

.stat:nth-child(2) {
    animation-delay: 0.2s;
}

.stat:nth-child(3) {
    animation-delay: 0.4s;
}

.stat:nth-child(4) {
    animation-delay: 0.6s;
}

.stat span {
    font-size: 1.8rem;
    font-weight: bold;
    color: var(--primary);
}

.stat label {
    font-size: 0.9rem;
    color: #666;
    margin-top: 0.3rem;
}
</style>