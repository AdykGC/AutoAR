import http from "./http-common";

class Auth_Service {

    register( email, nickname, password ) {
        return http.post("/auth/users/", {
            email, nickname, password
        });
    }

    login( email, password ) {
        return http.post("/auth/jwt/create/", {
            email, password
        });
    }

    refreshToken() {
        const user = JSON.parse(localStorage.getItem("user"));
        if (user && user.refresh) {
            return axios.post("/auth/jwt/refresh/", {
                refresh: user.refresh,
            });
        }
        return Promise.reject("No refresh token found");
    }

    logout() {
        localStorage.removeItem("user");
    }

    saveToken(data) {
        localStorage.setItem("user", JSON.stringify(data));
    }

    getToken() {
        const user = JSON.parse(localStorage.getItem("user"));
        return user?.access;
    }

    getCurrentUser() {
        const token = this.getToken();
        return http.get("/auth/users/me/", {
            headers: { Authorization: `Bearer ${token}` }
        });
    }
/*
    getAll() {
        return http.get("/tutorials");
    }

    get(id) {
        return http.get(`/tutorials/${id}`);
    }


    update(id, data) {
        return http.put(`/tutorials/${id}`, data);
    }

    delete(id) {
        return http.delete(`/tutorials/${id}`);
    }

    deleteAll() {
        return http.delete(`/tutorials`);
    }

    findByTitle(title) {
        return http.get(`/tutorials?title=${title}`);
    }
*/
}
export default new Auth_Service();
