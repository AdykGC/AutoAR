<?php 

use Illuminate\Support\Facades\Route;


use App\Http\Controllers\CRUDofUser\{
    CRUDofUserController,
};
use App\Http\Controllers\CRM\{
    ClientGoalController,
};

use Illuminate\Support\Facades\Request;

// Route::post('/register',                  [CRUDofUserController::class, 'register']);
// Route::post('/login',                     [CRUDofUserController::class, 'login']);
// Route::middleware(['auth:sanctum'])->group(function () {
//     Route::patch('/update',                        [CRUDofUserController::class, 'update']);
//     Route::post('/logout',                         [CRUDofUserController::class, 'logout']);
//     // Данные сотрудника | Увольнение сотрудника
//     Route::post('/profile',          [CRUDofUserController::class, 'read']);
//     Route::post('/user/{user}/terminate',          [CRUDofUserController::class, 'terminate']);
// });
// 
// Route::middleware(['auth:sanctum'])->group(function () {
//     
//     // === ЦЕЛИ КЛИЕНТОВ ===
//     Route::prefix('client')->group(function () {
//         // Клиент создает цель (POST /api/client/goal)
//         Route::post('/goal', [ClientGoalController::class, 'createGoal']);
//         
//         // Мои цели (GET /api/client/goals)  
//         Route::get('/goals', [ClientGoalController::class, 'myGoals']);
//         
//         // Детали цели (GET /api/client/goal/{id})
//         Route::get('/goal/{goal}', [ClientGoalController::class, 'showGoal']);
//     });
//     
//     // === МЕНЕДЖЕРСКАЯ ЧАСТЬ (только для менеджеров) ===
//     Route::middleware(['role:Admin|Manager|Owner|Ceo'])->group(function () {
//         // Назначить цель команде (POST /api/goal/{id}/assign)
//         Route::post('/goal/{goal}/assign', [ClientGoalController::class, 'assignGoalToTeam']);
//         
//         // Список целей клиентов на рассмотрении (GET /api/pending-client-goals)
//         Route::get('/pending-client-goals', [ClientGoalController::class, 'pendingGoals']); // нужно добавить метод
//     });
//});

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ClientTaskController;
use App\Http\Controllers\Api\ProjectController;
use App\Http\Controllers\Api\ProjectTaskController;
use App\Http\Controllers\Api\TeamController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ActivityController;
use App\Http\Controllers\Api\CommentController;
use App\Http\Controllers\Api\AttachmentController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// ==================== ПУБЛИЧНЫЕ МАРШРУТЫ ====================

// Аутентификация
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    
    // Восстановление пароля
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/reset-password', [AuthController::class, 'resetPassword']);
});

// ==================== ЗАЩИЩЕННЫЕ МАРШРУТЫ ====================

Route::middleware('auth:sanctum')->group(function () {
    
    // ---------- АУТЕНТИФИКАЦИЯ ----------
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
    });
    
    // ---------- ДАШБОРДЫ ----------
    Route::prefix('dashboard')->group(function () {
        Route::get('/client', [DashboardController::class, 'clientDashboard'])
            ->middleware('role:Client|Client VIP');
            
        Route::get('/manager', [DashboardController::class, 'managerDashboard'])
            ->middleware('role:Manager|Admin|Owner|CEO');
            
        Route::get('/employee', [DashboardController::class, 'employeeDashboard'])
            ->middleware('role:Employee|Slave|Seller|Counter|Lawyer|HR');
            
        Route::get('/admin', [DashboardController::class, 'adminDashboard'])
            ->middleware('role:Admin|Owner|CEO');
    });
    
    // ---------- ЗАДАЧИ КЛИЕНТОВ (ClientTask) ----------
    Route::prefix('client-tasks')->group(function () {
        // Клиентские маршруты
        Route::middleware('role:Client|Client VIP')->group(function () {
            Route::get('/my', [ClientTaskController::class, 'myTasks']);
            Route::post('/', [ClientTaskController::class, 'store']);
            Route::put('/{id}', [ClientTaskController::class, 'update']);
            Route::delete('/{id}', [ClientTaskController::class, 'cancel']);
        });
        
        // Общие маршруты (клиент и менеджер)
        Route::get('/{id}', [ClientTaskController::class, 'show']);
        
        // Менеджерские маршруты
        Route::middleware('role:Manager|Admin|Owner|CEO')->group(function () {
            Route::get('/', [ClientTaskController::class, 'index']); // Все задачи
            Route::get('/pending', [ClientTaskController::class, 'pending']); // На рассмотрении
            Route::post('/{id}/approve', [ClientTaskController::class, 'approve']); // Одобрить
            Route::post('/{id}/reject', [ClientTaskController::class, 'reject']); // Отклонить
            Route::post('/{id}/assign-manager', [ClientTaskController::class, 'assignManager']); // Назначить менеджера
        });
    });
    
    // ---------- ПРОЕКТЫ (Project) ----------
    Route::prefix('projects')->group(function () {
        // Менеджерские маршруты
        Route::middleware('role:Manager|Admin|Owner|CEO')->group(function () {
            Route::get('/', [ProjectController::class, 'index']); // Все проекты
            Route::post('/', [ProjectController::class, 'store']); // Создать проект
            Route::put('/{id}', [ProjectController::class, 'update']); // Обновить проект
            Route::post('/{id}/start', [ProjectController::class, 'start']); // Запустить проект
            Route::post('/{id}/complete', [ProjectController::class, 'complete']); // Завершить проект
            Route::post('/{id}/hold', [ProjectController::class, 'hold']); // Приостановить проект
        });
        
        // Мои проекты (где я менеджер)
        Route::get('/my', [ProjectController::class, 'myProjects'])
            ->middleware('role:Manager|Admin|Owner|CEO');
            
        // Общие маршруты (просмотр для всех участников)
        Route::get('/{id}', [ProjectController::class, 'show']); // Детали проекта
        
        // Статистика проекта
        Route::get('/{id}/stats', [ProjectController::class, 'stats']); // Статистика
    });
    
    // ---------- ПОДЗАДАЧИ ПРОЕКТА (ProjectTask) ----------
    Route::prefix('project-tasks')->group(function () {
        // Маршруты сотрудника
        Route::middleware('role:Employee|Slave|Seller|Counter|Lawyer|HR')->group(function () {
            Route::get('/my', [ProjectTaskController::class, 'myTasks']); // Мои задачи
            Route::post('/{id}/complete', [ProjectTaskController::class, 'complete']); // Завершить задачу
            Route::post('/{id}/update-time', [ProjectTaskController::class, 'updateTime']); // Обновить время
            Route::post('/{id}/start', [ProjectTaskController::class, 'start']); // Начать задачу
        });
        
        // Менеджерские маршруты
        Route::middleware('role:Manager|Admin|Owner|CEO')->group(function () {
            Route::post('/', [ProjectTaskController::class, 'store']); // Создать задачу
            Route::put('/{id}', [ProjectTaskController::class, 'update']); // Обновить задачу
            Route::post('/{id}/assign', [ProjectTaskController::class, 'assign']); // Назначить задачу
            Route::post('/{id}/review', [ProjectTaskController::class, 'markForReview']); // Отправить на проверку
        });
        
        // Общие маршруты
        Route::get('/{id}', [ProjectTaskController::class, 'show']); // Детали задачи
    });
    
    // ---------- КОМАНДЫ (Team) ----------
    Route::prefix('teams')->group(function () {
        // Просмотр для всех авторизованных
        Route::get('/', [TeamController::class, 'index']);
        Route::get('/{id}', [TeamController::class, 'show']);
        
        // Управление командами (только менеджеры и выше)
        Route::middleware('role:Manager|Admin|Owner|CEO')->group(function () {
            Route::post('/', [TeamController::class, 'store']);
            Route::put('/{id}', [TeamController::class, 'update']);
            Route::delete('/{id}', [TeamController::class, 'destroy']);
            
            // Управление участниками
            Route::post('/{id}/members', [TeamController::class, 'addMember']);
            Route::delete('/{id}/members/{userId}', [TeamController::class, 'removeMember']);
            Route::put('/{id}/members/{userId}/role', [TeamController::class, 'updateMemberRole']);
            
            // Статистика команды
            Route::get('/{id}/stats', [TeamController::class, 'stats']);
        });
        
        // Моя команда (для сотрудников)
        Route::get('/my/team', [TeamController::class, 'myTeam'])
            ->middleware('role:Employee|Slave|Seller|Counter|Lawyer|HR');
    });
    
    // ---------- АКТИВНОСТЬ (Activity) ----------
    Route::prefix('activities')->group(function () {
        Route::get('/my', [ActivityController::class, 'myActivity']); // Моя активность
        Route::get('/recent', [ActivityController::class, 'recent']); // Последняя активность
        
        // Для менеджеров и админов
        Route::middleware('role:Manager|Admin|Owner|CEO')->group(function () {
            Route::get('/', [ActivityController::class, 'index']); // Вся активность
            Route::get('/stats', [ActivityController::class, 'stats']); // Статистика
            Route::get('/entity/{type}/{id}', [ActivityController::class, 'entityActivity']); // Активность по сущности
        });
    });
    
    // ---------- КОММЕНТАРИИ (Comment) ----------
    Route::prefix('comments')->group(function () {
        Route::post('/', [CommentController::class, 'store']); // Создать комментарий
        Route::put('/{id}', [CommentController::class, 'update']); // Обновить комментарий
        Route::delete('/{id}', [CommentController::class, 'destroy']); // Удалить комментарий
        
        // Получение комментариев для сущности
        Route::get('/entity/{type}/{id}', [CommentController::class, 'entityComments']);
        
        // Ответы на комментарии
        Route::post('/{id}/reply', [CommentController::class, 'reply']);
    });
    
    // ---------- ФАЙЛЫ (Attachment) ----------
    Route::prefix('attachments')->group(function () {
        Route::post('/', [AttachmentController::class, 'store']); // Загрузить файл
        Route::delete('/{id}', [AttachmentController::class, 'destroy']); // Удалить файл
        
        // Получение файлов для сущности
        Route::get('/entity/{type}/{id}', [AttachmentController::class, 'entityAttachments']);
        
        // Скачивание файла
        Route::get('/{id}/download', [AttachmentController::class, 'download']);
        Route::get('/{id}/preview', [AttachmentController::class, 'preview']);
    });
    
    // ---------- ПОЛЬЗОВАТЕЛИ (User) ----------
    Route::prefix('users')->middleware('role:Admin|Owner|CEO|Manager')->group(function () {
        Route::get('/', [UserController::class, 'index']); // Список пользователей
        Route::get('/{id}', [UserController::class, 'show']); // Детали пользователя
        Route::put('/{id}', [UserController::class, 'update']); // Обновить пользователя
        Route::post('/{id}/toggle-status', [UserController::class, 'toggleStatus']); // Активация/деактивация
        
        // Роли и разрешения
        Route::post('/{id}/assign-role', [UserController::class, 'assignRole']);
        Route::post('/{id}/remove-role', [UserController::class, 'removeRole']);
        
        // Поиск пользователей (для назначения задач)
        Route::get('/search/employees', [UserController::class, 'searchEmployees']);
    });
    
    // ---------- ОТЧЕТЫ И АНАЛИТИКА ----------
    Route::prefix('reports')->middleware('role:Manager|Admin|Owner|CEO')->group(function () {
        Route::get('/projects', [ReportController::class, 'projectsReport']);
        Route::get('/tasks', [ReportController::class, 'tasksReport']);
        Route::get('/team-performance', [ReportController::class, 'teamPerformance']);
        Route::get('/client-satisfaction', [ReportController::class, 'clientSatisfaction']);
        
        // Экспорт отчетов
        Route::post('/export/projects', [ReportController::class, 'exportProjects']);
        Route::post('/export/tasks', [ReportController::class, 'exportTasks']);
    });
    
    // ---------- УВЕДОМЛЕНИЯ (Notifications) ----------
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']); // Мои уведомления
        Route::get('/unread', [NotificationController::class, 'unread']); // Непрочитанные
        Route::post('/{id}/read', [NotificationController::class, 'markAsRead']); // Отметить как прочитанное
        Route::post('/read-all', [NotificationController::class, 'markAllAsRead']); // Отметить все как прочитанные
        
        // Настройки уведомлений
        Route::get('/settings', [NotificationController::class, 'settings']);
        Route::put('/settings', [NotificationController::class, 'updateSettings']);
    });
});

// ==================== МАРШРУТЫ ДЛЯ АДМИНИСТРАТОРОВ ====================

Route::middleware(['auth:sanctum', 'role:Admin|Owner|CEO'])->group(function () {
    
    // ---------- СИСТЕМНЫЕ НАСТРОЙКИ ----------
    Route::prefix('admin')->group(function () {
        // Управление ролями
        Route::prefix('roles')->group(function () {
            Route::get('/', [RoleController::class, 'index']);
            Route::post('/', [RoleController::class, 'store']);
            Route::put('/{id}', [RoleController::class, 'update']);
            Route::delete('/{id}', [RoleController::class, 'destroy']);
            Route::post('/{id}/permissions', [RoleController::class, 'assignPermissions']);
        });
        
        // Управление разрешениями
        Route::prefix('permissions')->group(function () {
            Route::get('/', [PermissionController::class, 'index']);
            Route::post('/', [PermissionController::class, 'store']);
        });
        
        // Системные логи
        Route::get('/logs', [LogController::class, 'index']);
        
        // Резервное копирование
        Route::post('/backup', [BackupController::class, 'create']);
        Route::get('/backups', [BackupController::class, 'list']);
        
        // Системная статистика
        Route::get('/system-stats', [SystemController::class, 'stats']);
    });
});

// ==================== МАРШРУТЫ ДЛЯ VIP КЛИЕНТОВ ====================

Route::middleware(['auth:sanctum', 'role:Client VIP'])->group(function () {
    Route::prefix('vip')->group(function () {
        // Приоритетная поддержка
        Route::post('/support', [SupportController::class, 'vipSupport']);
        
        // Расширенная аналитика
        Route::get('/analytics', [AnalyticsController::class, 'vipAnalytics']);
        
        // Персональный менеджер
        Route::get('/personal-manager', [ManagerController::class, 'getPersonalManager']);
        
        // Быстрое создание задач
        Route::post('/quick-task', [ClientTaskController::class, 'quickCreate']);
    });
});

// ==================== WEBHOOKS И ИНТЕГРАЦИИ ====================

// Внешние интеграции (без аутентификации или с API ключом)
Route::prefix('webhooks')->group(function () {
    // Уведомления от платежных систем
    Route::post('/payment', [WebhookController::class, 'payment']);
    
    // Интеграция с календарем
    Route::post('/calendar', [WebhookController::class, 'calendar']);
    
    // Slack/Telegram уведомления
    Route::post('/notify', [WebhookController::class, 'notification']);
});

// ==================== HEALTH CHECKS ====================

Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now()->toDateTimeString(),
        'version' => config('app.version', '1.0.0')
    ]);
});

// ==================== FALLBACK ROUTE ====================

Route::fallback(function () {
    return response()->json([
        'success' => false,
        'message' => 'Endpoint not found',
        'documentation' => url('/api/docs') // Указать на документацию когда будет
    ], 404);
});