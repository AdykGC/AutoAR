<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\User\{
    GetUserController, LoginController, RegisterController, LogoutController, UpdateController
};
use App\Http\Controllers\Product\{
    MachineController, CreateMachinesController, ShowMachinesController, UpdateMachinesController, DeleteMachinesController, ListMachinesController,
};


use App\Http\Controllers\TestController;

// Тестовые маршруты (публичные)
Route::get('/test', [TestController::class, 'test']);
Route::get('/cors-test', [TestController::class, 'corsTest']);

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});


Route::prefix('auth')->group(function () {
    Route::post('/register',                  RegisterController::class)->middleware('throttle:5,1');
    Route::post('/login',                     LoginController::class)->middleware('throttle:5,1');

    Route::middleware(['auth:sanctum'])->group(function () {
        Route::post('/logout',                             LogoutController::class);
        Route::post('/update',                             UpdateController::class);
        Route::get('/showMe',                              GetUserController::class);
    });
});

Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/machines/create',                              CreateMachinesController::class);
    Route::put('/machines/update/{id}',                          UpdateMachinesController::class);
    Route::post('/machines/delete/{id}',                         DeleteMachinesController::class);
    Route::get('/machines/show/{id}',                            ShowMachinesController::class);
    Route::get('/machines/list',                                 ListMachinesController::class);
    //Route::get('/machines', [MachineController::class, 'index']);
    //Route::get('/machines/{id}', [MachineController::class, 'show']);
});










































































// // ==================== ПУБЛИЧНЫЕ МАРШРУТЫ ====================
// Route::prefix('auth')->group(function () {
//     Route::post('/register', [AuthController::class, 'register']);
//     Route::post('/login', [AuthController::class, 'login']);
// });

// // ==================== ЗАЩИЩЕННЫЕ МАРШРУТЫ (ТОЛЬКО АУТЕНТИФИКАЦИЯ) ====================
// 
// Route::middleware('auth:sanctum')->group(function () {
//     // ---------- АУТЕНТИФИКАЦИЯ ----------
//     Route::prefix('auth')->group(function () {
//         Route::post('/logout', [AuthController::class, 'logout']);
//         Route::get('/me', [AuthController::class, 'me']);
//     });
// 
// 
// 
// 
// 
// 
//     // ---------- ДАШБОРДЫ ----------
//     Route::prefix('dashboard')->group(function () {
//         Route::get('/client', [DashboardController::class, 'clientDashboard']);
//         Route::get('/manager', [DashboardController::class, 'managerDashboard']);
//         Route::get('/employee', [DashboardController::class, 'employeeDashboard']);
//     });
// 
// 
// 
// 
//     // ---------- ЗАДАЧИ КЛИЕНТОВ (ClientTask) ----------
//     Route::prefix('client-tasks')->group(function () {
//         // Клиентские маршруты (БЕЗ MIDDLEWARE ROLE)
//         Route::get('/my', [ClientTaskController::class, 'myTasks']);
//         Route::post('/', [ClientTaskController::class, 'store']);
//         
//         // Менеджерские маршруты (БЕЗ MIDDLEWARE ROLE)
//         Route::get('/', [ClientTaskController::class, 'index']);
//         Route::get('/pending', [ClientTaskController::class, 'pending']);  // ← ПЕРЕМЕСТИ ВВЕРХ!
//         
//         // Общие маршруты с {id} (В САМОМ КОНЦЕ!)
//         Route::get('/{id}', [ClientTaskController::class, 'show']);
//         Route::put('/{id}', [ClientTaskController::class, 'update']);
//         Route::delete('/{id}', [ClientTaskController::class, 'cancel']);
//         Route::post('/{id}/approve', [ClientTaskController::class, 'approve']);
//         Route::post('/{id}/reject', [ClientTaskController::class, 'reject']);
//         Route::post('/{id}/assign-manager', [ClientTaskController::class, 'assignManager']);
//     });
// 
// 
// 
//     // ---------- ПРОЕКТЫ (Project) ----------
//     Route::prefix('projects')->group(function () {
//         Route::get('/', [ProjectController::class, 'index']);
//         Route::post('/', [ProjectController::class, 'store']);
//         Route::get('/my', [ProjectController::class, 'myProjects']);
//         Route::get('/{id}', [ProjectController::class, 'show']);
//         Route::put('/{id}', [ProjectController::class, 'update']);
//         Route::post('/{id}/start', [ProjectController::class, 'start']);
//         Route::post('/{id}/complete', [ProjectController::class, 'complete']);
//         Route::get('/{id}/stats', [ProjectController::class, 'stats']);
//     });
//     
//     // ---------- ПОДЗАДАЧИ ПРОЕКТА (ProjectTask) ----------
//     Route::prefix('project-tasks')->group(function () {
//         Route::get('/my', [ProjectTaskController::class, 'myTasks']);
//         Route::post('/', [ProjectTaskController::class, 'store']);
//         Route::get('/{id}', [ProjectTaskController::class, 'show']);
//         Route::put('/{id}', [ProjectTaskController::class, 'update']);
//         Route::post('/{id}/assign', [ProjectTaskController::class, 'assign']);
//         Route::post('/{id}/complete', [ProjectTaskController::class, 'complete']);
//         Route::post('/{id}/update-time', [ProjectTaskController::class, 'updateTime']);
//     });
//     
//     // ---------- КОМАНДЫ (Team) ----------
//     Route::prefix('teams')->group(function () {
//         Route::get('/', [TeamController::class, 'index']);
//         Route::get('/{id}', [TeamController::class, 'show']);
//         Route::get('/my/team', [TeamController::class, 'myTeam']);
//         Route::post('/', [TeamController::class, 'store']);
//         Route::put('/{id}', [TeamController::class, 'update']);
//         Route::delete('/{id}', [TeamController::class, 'destroy']);
//         Route::post('/{id}/members', [TeamController::class, 'addMember']);
//         Route::delete('/{id}/members/{userId}', [TeamController::class, 'removeMember']);
//         Route::get('/{id}/stats', [TeamController::class, 'stats']);
//     });
// });

// ==================== HEALTH CHECK ====================
// Route::get('/health', function () {
//     return response()->json(['status' => 'ok']);
// });
// 
// // ==================== ТЕСТОВЫЙ МАРШРУТ ДЛЯ ПРОВЕРКИ ====================
// Route::get('/test-simple', function () {
//     return response()->json(['message' => 'API работает без middleware role']);
// });
