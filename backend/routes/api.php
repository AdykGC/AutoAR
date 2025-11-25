<?php 

use Illuminate\Support\Facades\Route;


use App\Http\Controllers\CRUDofUser\{
    CRUDofUserController,
};

use Illuminate\Support\Facades\Request;

Route::post('/register',                  [CRUDofUserController::class, 'create']);
Route::post('/login',                     [CRUDofUserController::class, 'read']);
Route::post('/3',                  [CRUDofUserController::class, 'update']);
Route::post('/4',                  [CRUDofUserController::class, 'delete']);