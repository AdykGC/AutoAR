<?php namespace App\Http\Controllers\User;

use App\Models\User;
use App\Http\Controllers\User\BaseController;
use App\Http\Requests\User\registerUserRequest;

class RegisterController extends BaseController{
    public function __invoke(registerUserRequest $request) {
        /** @var User $user */
        return $this->service->register($request);
    }
}
