<template>
  <div>
    <p>Access: {{ token }}</p>
    <button @click="refreshToken">🔁 Обновить токен</button>
  </div>
</template>

<script>
import axios from "axios"; // ✅ оригинальный axios

export default {
  data() {
    return {
      token: "",
    };
  },
  mounted() {
    const user = JSON.parse(localStorage.getItem("user"));
    if (user && user.access) {
      this.token = user.access;
    }

    // Автообновление поля каждые 5 секунд
    setInterval(() => {
      const user = JSON.parse(localStorage.getItem("user"));
      this.token = user?.access || "❌ no token";
    }, 5000);
  },
  methods: {
    async refreshToken() {
      const user = JSON.parse(localStorage.getItem("user"));
      if (!user || !user.refresh) {
        alert("❌ Нет refresh токена");
        return;
      }

      try {
        const response = await axios.post("http://127.0.0.1:8000/api/auth/jwt/refresh/", {
          refresh: user.refresh,
        });

        user.access = response.data.access;
        localStorage.setItem("user", JSON.stringify(user));
        this.token = user.access;

        alert("✅ Токен обновлён успешно!");
        console.log("Новый access:", user.access);
      } catch (error) {
        console.error("❌ Ошибка при обновлении токена:", error);
        alert("❌ Ошибка при обновлении токена");
      }
    },
  },
};
</script>

<style scoped>
button {
  margin-top: 1rem;
  padding: 0.5rem 1rem;
  background-color: #4caf50;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}
button:hover {
  background-color: #388e3c;
}
</style>
