<?php use GuzzleHttp\Promise\Create;
use Illuminate\Support\Facades\Route;


use App\Http\Controllers\CRUDofUser\{
    CRUDofUserController,
};

use Illuminate\Support\Facades\Request;

Route::post('/register',                  [CRUDofUserController::class, 'Create']);