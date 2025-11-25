<?php namespace App\Http\Controllers\CRUDofUser;

use App\Models\User;
use App\Http\Controllers\CRUDofUser\BaseController;
use App\Http\Requests\createUserRequest;
use App\Http\Requests\readUserRequest;

class CRUDofUserController extends BaseController{
    public function create(createUserRequest $request) {
        /** @var User $user */
        return $this->service->create($request);
    }
    public function read(readUserRequest $request) {
        /** @var User $user */
        return $this->service->read($request);
    }
    public function update(/* createUserRequest $request */) {
        /** @var User $user */
        return $this->service->update();
    }
    public function delete(/* createUserRequest $request */) {
        /** @var User $user */
        return $this->service->delete();
    }
}
