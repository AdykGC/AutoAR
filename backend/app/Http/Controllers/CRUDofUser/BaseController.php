<?php namespace App\Http\Controllers\CRUDofUser;

use App\Services\CRUDofUser\UserService;

class BaseController{
    public $service;
    public function __construct(UserService $service){
        $this->service = $service;
    }
}