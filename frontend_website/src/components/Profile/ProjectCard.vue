<template>
    <div id="header">
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


<script scoped>
import Auth_Service from "../../axios/index.js";

export default {
    data() {
        return {
            email: "",
            password: ""
            };
        },
    methods: {
        handleLogin() {
            Auth_Service.login(this.email, this.password)
                .then(response => {
                    Auth_Service.saveToken(response.data);
                    console.log("Login successful", response.data);
                    // редирект на защищённую страницу, например:
                    this.$router.push("/profile");
                })
                .catch(error => {
                    console.error("Login failed", error);
                    alert("Invalid email or password");
                });
        }
    }
};
</script>