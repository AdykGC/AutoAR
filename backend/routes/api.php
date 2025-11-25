<?php 

use Illuminate\Support\Facades\Route;


use App\Http\Controllers\CRUDofUser\{
    CRUDofUserController,
};

use Illuminate\Support\Facades\Request;

Route::post('/register',                  [CRUDofUserController::class, 'create']);
Route::post('/login',                     [CRUDofUserController::class, 'read']);
Route::patch('/update',                        [CRUDofUserController::class, 'update']);
Route::post('/logout',                    [CRUDofUserController::class, 'delete']);