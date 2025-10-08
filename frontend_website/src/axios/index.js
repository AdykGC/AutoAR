import http from "./http-common";

class Auth_Service {

    login(email, password) {
        return http.post("/auth/jwt/create/", {
            email, password
        });
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
