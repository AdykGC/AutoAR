<?php namespace App\Http\Controllers\User;

use App\Models\User;
use App\Http\Controllers\User\BaseController;
use App\Http\Requests\User\updateUserRequest;

class UpdateController extends BaseController{
    public function __invoke(updateUserRequest $request) {
        /** @var User $user */
        $user = auth()->user();
        return $this->service->update($request, $user);
    }
}
