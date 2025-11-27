<?php namespace App\Http\Controllers\CRUDofUser;

use App\Models\User;
use App\Http\Controllers\CRUDofUser\BaseController;
use App\Http\Requests\{
    createUserRequest,
    readUserRequest,
    updateUserRequest
};
use Illuminate\Http\Request;

class CRUDofUserController extends BaseController{
    public function create(createUserRequest $request) {
        /** @var User $user */
        return $this->service->create($request);
    }
    public function read(readUserRequest $request) {
        /** @var User $user */
        return $this->service->read($request);
    }
    public function update(updateUserRequest $request) {
        /** @var User $user */
        $user = auth()->user();
        return $this->service->update($request, $user);
    }
    public function delete(Request $request) {
        /** @var User $user */
        $request->user()->currentAccessToken()->delete();
        return $this->service->delete();
    }
}
