<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\ClientTask\CreateClientTaskRequest;
use App\Http\Requests\ClientTask\UpdateClientTaskRequest;
use App\Services\ClientTaskService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ClientTaskController extends BaseController
{
    protected $clientTaskService;

    public function __construct(ClientTaskService $clientTaskService)
    {
        $this->clientTaskService = $clientTaskService;
        $this->middleware('auth:sanctum');
    }

    private function toInt($value): int {
        return (int) $value;
    }
    /**
     * Проверка роли пользователя
     */
    private function checkClientRole(): void
    {
        $user = auth()->user();
        if (!$user->hasRole('Client') && !$user->hasRole('Client VIP')) {
            throw new \Exception('Только клиенты могут выполнять это действие');
        }
    }

    /**
     * Проверка роли менеджера
     */
    private function checkManagerRole(): void
    {
        $user = auth()->user();
        if (!$user->hasRole('Manager') && 
            !$user->hasRole('Admin') && 
            !$user->hasRole('Owner') && 
            !$user->hasRole('CEO')) {
            throw new \Exception('Только менеджеры могут выполнять это действие');
        }
    }

    /**
     * Список задач клиента (только свои)
     */
    public function myTasks(Request $request): JsonResponse
    {
        try {
            $this->checkClientRole();
            $tasks = $this->clientTaskService->getClientTasks(auth()->id());
            return $this->success($tasks);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 403);
        }
    }

    /**
     * Создать новую задачу (клиент)
     */
    public function store(CreateClientTaskRequest $request): JsonResponse
    {
        try {
            $this->checkClientRole();

            $data = $request->validated();
            $data['client_id'] = auth()->id();
            
            $task = $this->clientTaskService->createTask($data);
            return $this->success($task, 'Задача создана', 201);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 403);
        }
    }

    /**
     * Просмотр деталей задачи
     */
    public function show($id): JsonResponse {
        try {
            // ДОБАВЬТЕ ЭТУ СТРОКУ ↓
            $taskId = (int) $id;

            // ИЗМЕНИТЕ ЭТУ СТРОКУ ↓ (передавайте $taskId вместо $id)
            $task = $this->clientTaskService->getTaskWithProgress($taskId, auth()->id());

            if (!$task) {
                return $this->error('Задача не найдена', 404);
            }

            // Проверка доступа
            $user = auth()->user();
            if ($task->client_id !== $user->id && !$user->hasRole('Manager')) {
                return $this->error('Доступ запрещен', 403);
            }

            return $this->success($task);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Обновить задачу (клиент)
     */
    public function update(UpdateClientTaskRequest $request, $id): JsonResponse {
        try {
            $this->checkClientRole();
            
            $taskId = $this->toInt($id);  // ← ДОБАВЬТЕ
            $task = $this->clientTaskService->findTask($taskId);  // ← ПЕРЕДАВАЙТЕ $taskId
            
            if (!$task) {
                return $this->error('Задача не найдена', 404);
            }

            if ($task->client_id !== auth()->id()) {
                return $this->error('Вы можете редактировать только свои задачи', 403);
            }

            if ($task->status !== 'pending') {
                return $this->error('Нельзя редактировать задачу в статусе: ' . $task->status, 400);
            }

            $updatedTask = $this->clientTaskService->updateTask($task, $request->validated());
            return $this->success($updatedTask, 'Задача обновлена');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 403);
        }
    }

    /**
     * Отменить задачу (клиент)
     */
    public function cancel($id): JsonResponse
    {
        try {
            $this->checkClientRole();
            
            $taskId = $this->toInt($id);  // ← ДОБАВЬТЕ
            $task = $this->clientTaskService->findTask($taskId);  // ← ПЕРЕДАВАЙТЕ $taskId
            
            if (!$task) {
                return $this->error('Задача не найдена', 404);
            }

            if ($task->client_id !== auth()->id()) {
                return $this->error('Вы можете отменять только свои задачи', 403);
            }

            if (!in_array($task->status, ['pending', 'approved'])) {
                return $this->error('Нельзя отменить задачу в статусе: ' . $task->status, 400);
            }

            $this->clientTaskService->cancelTask($task);
            return $this->success(null, 'Задача отменена');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 403);
        }
    }

    /**
     * Получить все задачи (менеджер)
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $this->checkManagerRole();
            $tasks = $this->clientTaskService->getAllTasks($request->all());
            return $this->success($tasks);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 403);
        }
    }

    /**
     * Получить задачи на рассмотрении (менеджер)
     */
    public function pending(Request $request): JsonResponse
    {
        try {
            $this->checkManagerRole();
            $tasks = $this->clientTaskService->getPendingTasks($request->all());
            return $this->success($tasks);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 403);
        }
    }

    /**
     * Одобрить задачу (менеджер)
     */
    public function approve($id): JsonResponse
    {
        try {
            $this->checkManagerRole();
            
            $taskId = $this->toInt($id);  // ← ДОБАВЬТЕ
            $task = $this->clientTaskService->findTask($taskId);  // ← ПЕРЕДАВАЙТЕ $taskId
            
            if (!$task) {
                return $this->error('Задача не найдена', 404);
            }

            $this->clientTaskService->approveTask($task);
            return $this->success(null, 'Задача одобрена');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 403);
        }
    }

    /**
     * Отклонить задачу (менеджер)
     */
    public function reject($id): JsonResponse
    {
        try {
            $this->checkManagerRole();
            
            $taskId = $this->toInt($id);  // ← ДОБАВЬТЕ
            $task = $this->clientTaskService->findTask($taskId);  // ← ПЕРЕДАВАЙТЕ $taskId
            
            if (!$task) {
                return $this->error('Задача не найдена', 404);
            }

            $this->clientTaskService->rejectTask($task);
            return $this->success(null, 'Задача отклонена');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 403);
        }
    }

    /**
     * Назначить менеджера (менеджер)
     */
    public function assignManager(Request $request, $id): JsonResponse
    {
        try {
            $this->checkManagerRole();
            
            $taskId = $this->toInt($id);  // ← ДОБАВЬТЕ

            $request->validate([
                'manager_id' => 'required|exists:users,id'
            ]);

            $task = $this->clientTaskService->findTask($taskId);  // ← ПЕРЕДАВАЙТЕ $taskId
            
            if (!$task) {
                return $this->error('Задача не найдена', 404);
            }

            $this->clientTaskService->assignManager($task, $request->manager_id);
            return $this->success(null, 'Менеджер назначен');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 403);
        }
    }
}