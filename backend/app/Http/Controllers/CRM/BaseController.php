<?php namespace App\Http\Controllers\CRM;

use App\Services\CRM\ClientGoalService;

class BaseController{
    public $service;
    public function __construct(ClientGoalService $service){
        $this->service = $service;
    }
}