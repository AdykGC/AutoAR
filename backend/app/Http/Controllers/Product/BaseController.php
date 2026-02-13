<?php namespace App\Http\Controllers\Product;

use App\Services\Product\ProductService;

class BaseController{
    public $service;
    public function __construct(ProductService $service){
        $this->service = $service;
    }
}