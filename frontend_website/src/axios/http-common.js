import axios from "axios";

const instance = axios.create({
    baseURL: "http://127.0.0.1:8000/api",
    headers: {
        "Content-type": "application/json",
    },
});

// Добавим интерцептор для добавления Authorization заголовка
instance.interceptors.request.use(
    (config) => {
        const user = JSON.parse(localStorage.getItem("user"));
        if (user && user.access) {
            config.headers.Authorization = `Bearer ${user.access}`;
        }
        return config;
    },
    (error) => Promise.reject(error)
);

// 🔁 Interceptor для обновления токена при ошибке 401
instance.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
// Если получили 401 и ещё не пробовали обновить
    if (
      error.response &&
      error.response.status === 401 &&
      !originalRequest._retry
    ) {
      originalRequest._retry = true;

      try {
        const user = JSON.parse(localStorage.getItem("user"));
        const response = await instance.post( "/auth/jwt/refresh/",
          { refresh: user.refresh }
        );

        // Обновляем access в localStorage
        user.access = response.data.access;
        localStorage.setItem("user", JSON.stringify(user));

        // Ставим новый access в заголовки и повторяем запрос
        originalRequest.headers.Authorization = `Bearer ${user.access}`;
        return instance(originalRequest);
      } catch (refreshError) {
        console.error("Refresh token failed", refreshError);
        localStorage.removeItem("user"); // Очистить токены
        window.location.href = "/login"; // Редирект на логин
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default instance;