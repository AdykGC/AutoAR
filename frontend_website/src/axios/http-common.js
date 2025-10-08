import axios from "axios";

const instance = axios.create({
    baseURL: "http://127.0.0.1:8000//api",
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

export default instance;