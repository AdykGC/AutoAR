<?php namespace App\Http\Controllers\User;

use App\Http\Controllers\User\BaseController;
use App\Http\Requests\User\UserRegisterRequest;

class UserRegisterController extends BaseController{
    public function __invoke(UserRegisterRequest $request) {
        return $this->service->register($request);
    }
}
