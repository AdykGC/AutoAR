<?php namespace App\Http\Controllers\CRUDofUser;

use App\Models\User;
use App\Http\Controllers\CRUDofUser\BaseController;
use App\Http\Requests\{
    registerUserRequest,
    loginUserRequest,
    updateUserRequest,
    terminateUserRequest
};
use Illuminate\Http\Request;

class CRUDofUserController extends BaseController{
    public function register(registerUserRequest $request) {
        /** @var User $user */
        return $this->service->register($request);
    }


    public function login(loginUserRequest $request) {
        /** @var User $user */
        return $this->service->login($request);
    }


    public function update(updateUserRequest $request) {
        /** @var User $user */
        $user = auth()->user();
        return $this->service->update($request, $user);
    }


    public function logout(Request $request) {
        /** @var User $user */
        $request->user()->currentAccessToken()->delete();
        return $this->service->logout();
    }


    public function terminate(terminateUserRequest $request, $userId) {
        $user = User::findOrFail($userId);
        return $this->service->terminate($request, $user);
    }


    public function read(Request $request) {
        /** @var User $user */
        $user = $request->user();
        return $this->service->read($user);
    }
}
