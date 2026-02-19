<?php namespace App\Http\Controllers\User;

use App\Models\User;
use App\Http\Controllers\User\BaseController;
use App\Http\Requests\User\loginUserRequest;

class LoginController extends BaseController{
    public function __invoke(loginUserRequest $request) {


        try {
            $data = $this->service->login($request);
            return $this->success($data, 'Вход успешен');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 401);
        }
    }
}
