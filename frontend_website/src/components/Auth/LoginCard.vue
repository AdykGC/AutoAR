<template>
    <div class="">
        <div class="login-container">
            <h1>Welcome Back</h1>

            <form @submit.prevent="handleLogin">
                <div class="input-group">
                    <input v-model="email" type="email" id="email" placeholder=" " required>
                    <label for="username">Email</label>
                </div>
                <div class="input-group">
                    <input v-model="password" type="password" id="password" placeholder=" " required>
                    <label for="password">Password</label>
                </div>
                <button type="submit" class="btn">Login</button>
                <div class="extra-links">
                    <a href="#">Forgot Password?</a>
                    <a href="/register">Create Account</a>
                </div>
            </form>

        </div>
    </div>
</template>


<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;500;700&display=swap');

.login-container {
    display: flex;
    font-family: 'Space Grotesk', sans-serif;
    align-items: center;
    flex-direction: column;
    justify-content: center;
    background: var(--card-bg);
    padding: 2rem;
    border-radius: 20px;
    box-shadow: var(--card-shadow);
}

.input-group {
    position: relative;
    margin-bottom: 1.5rem;
}

.input-group input {
    width: 300px;
    padding: 15px;
    background: rgba(255, 255, 255, 0.1);
    border: none;
    border-radius: 10px;
    color: var(--text);
    font-size: 1rem;
    outline: none;
    transition: all 0.3s ease;
    border-left: 3px solid transparent;
}

.input-group input:focus {
    background: rgba(255, 255, 255, 0.15);
    border-left: 3px solid var(--secondary);
    box-shadow: 0 5px 15px rgba(15, 206, 255, 0.2);
}

.input-group label {
    position: absolute;
    top: 15px;
    left: 15px;
    color: var(--light);
    font-size: 1rem;
    transition: all 0.3s ease;
    pointer-events: none;
    opacity: 0.7;
}

.input-group input:focus+label,
.input-group input:not(:placeholder-shown)+label {
    transform: translateY(-26px);
    font-size: 0.8rem;
    opacity: 1;
    color: var(--secondary);
}


.btn {
    width: 100%;
    padding: 15px;
    border: none;
    border-radius: 10px;
    background: linear-gradient(45deg, var(--primary), var(--tertiary));
    color: var(--light);
    font-size: 1rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 10px 20px rgba(174, 13, 255, 0.3);
    position: relative;
    overflow: hidden;
}

.btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 15px 30px rgba(174, 13, 255, 0.4);
}

.btn:active {
    transform: translateY(0);
}

.btn::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: linear-gradient(to bottom right,
            rgba(255, 255, 255, 0.3),
            rgba(255, 255, 255, 0),
            rgba(255, 255, 255, 0.3));
    transform: rotate(45deg);
    transition: all 0.5s ease;
    opacity: 0;
}

.btn:hover::before {
    animation: shine 1.5s ease;
}

@keyframes shine {
    0% {
        left: -100%;
        opacity: 0;
    }

    50% {
        opacity: 0.5;
    }

    100% {
        left: 100%;
        opacity: 0;
    }
}

.extra-links {
    display: flex;
    justify-content: space-between;
    margin-top: 1.5rem;
    font-size: 0.9rem;
}

.extra-links a {
    color: var(--light);
    text-decoration: none;
    opacity: 0.7;
    transition: all 0.3s ease;
}

.extra-links a:hover {
    color: var(--secondary);
    opacity: 1;
    text-decoration: underline;
}
</style>

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