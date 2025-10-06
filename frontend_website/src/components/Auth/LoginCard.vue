<template>
    <div class="">

    
    <div class="login-container">
        <h1>Welcome Back</h1>
        <form>
            <div class="input-group">
                <input type="text" id="username" placeholder=" " required>
                <label for="username">Username</label>
            </div>
            <div class="input-group">
                <input type="password" id="password" placeholder=" " required>
                <label for="password">Password</label>
            </div>
            <button type="submit" class="btn">Login</button>
            <div class="extra-links">
                <a href="#">Forgot Password?</a>
                <a href="#">Create Account</a>
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
            width: 100%;
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

</style>

    <script>
    document.addEventListener('DOMContentLoaded', function () {
        // Create floating particles
        const particlesContainer = document.getElementById('particles');
        const colors = ['#ff3e9d', '#0fceff', '#ae0dff', '#ffffff'];

        for (let i = 0; i < 20; i++) {
            const particle = document.createElement('div');
            particle.style.position = 'absolute';
            particle.style.width = Math.random() * 20 + 5 + 'px';
            particle.style.height = particle.style.width;
            particle.style.background = colors[Math.floor(Math.random() * colors.length)];
            particle.style.opacity = Math.random() * 0.6 + 0.2;
            particle.style.borderRadius = '50%';
            particle.style.left = Math.random() * 100 + '%';
            particle.style.top = Math.random() * 100 + '%';
            particle.style.filter = 'blur(1px)';

            const animationDuration = Math.random() * 20 + 10;
            particle.style.animation = `float ${animationDuration}s linear infinite`;

            particlesContainer.appendChild(particle);
        }

        // Form animation in
        document.querySelector('.login-container').addEventListener('mouseenter', function () {
            this.style.transform = 'scale(1.02)';
        });

        document.querySelector('.login-container').addEventListener('mouseleave', function () {
            this.style.transform = 'scale(1)';
        });

        // Input focus effects
        const inputs = document.querySelectorAll('input');
        inputs.forEach(input => {
            input.addEventListener('focus', function () {
                this.parentElement.style.transform = 'translateY(-3px)';
            });

            input.addEventListener('blur', function() {
                        this.parentElement.style.transform = 'translateY(0)';
                    });
                });
            });
    </script>