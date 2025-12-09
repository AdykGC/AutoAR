<?php 

use Illuminate\Support\Facades\Route;


use App\Http\Controllers\CRUDofUser\{
    CRUDofUserController,
};
use App\Http\Controllers\CRM\{
    ClientGoalController,
};

use Illuminate\Support\Facades\Request;

Route::post('/register',                  [CRUDofUserController::class, 'register']);
Route::post('/login',                     [CRUDofUserController::class, 'login']);
Route::middleware(['auth:sanctum'])->group(function () {
    Route::patch('/update',                        [CRUDofUserController::class, 'update']);
    Route::post('/logout',                         [CRUDofUserController::class, 'logout']);
    // Данные сотрудника | Увольнение сотрудника
    Route::post('/profile',          [CRUDofUserController::class, 'read']);
    Route::post('/user/{user}/terminate',          [CRUDofUserController::class, 'terminate']);
});

Route::middleware(['auth:sanctum'])->group(function () {
    
    // === ЦЕЛИ КЛИЕНТОВ ===
    Route::prefix('client')->group(function () {
        // Клиент создает цель (POST /api/client/goal)
        Route::post('/goal', [ClientGoalController::class, 'createGoal']);
        
        // Мои цели (GET /api/client/goals)  
        Route::get('/goals', [ClientGoalController::class, 'myGoals']);
        
        // Детали цели (GET /api/client/goal/{id})
        Route::get('/goal/{goal}', [ClientGoalController::class, 'showGoal']);
    });
    
    // === МЕНЕДЖЕРСКАЯ ЧАСТЬ (только для менеджеров) ===
    Route::middleware(['role:Admin|Manager|Owner|Ceo'])->group(function () {
        // Назначить цель команде (POST /api/goal/{id}/assign)
        Route::post('/goal/{goal}/assign', [ClientGoalController::class, 'assignGoalToTeam']);
        
        // Список целей клиентов на рассмотрении (GET /api/pending-client-goals)
        Route::get('/pending-client-goals', [ClientGoalController::class, 'pendingGoals']); // нужно добавить метод
    });
    
});