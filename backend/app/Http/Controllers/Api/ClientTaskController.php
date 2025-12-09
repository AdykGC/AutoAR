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

    /**
     * Список задач клиента (только свои)
     */
    public function myTasks(Request $request): JsonResponse
    {
        try {
            $tasks = $this->clientTaskService->getClientTasks(auth()->id());
            return $this->success($tasks);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Создать новую задачу (клиент)
     */
    public function store(CreateClientTaskRequest $request): JsonResponse
    {
        try {
            if (!$this->hasRole('Client') && !$this->hasRole('Client VIP')) {
                return $this->error('Только клиенты могут создавать задачи', 403);
            }

            $data = $request->validated();
            $data['client_id'] = auth()->id();
            
            $task = $this->clientTaskService->createTask($data);
            return $this->success($task, 'Задача создана', 201);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Просмотр деталей задачи
     */
    public function show($id): JsonResponse
    {
        try {
            $task = $this->clientTaskService->getTaskWithProgress($id, auth()->id());
            
            if (!$task) {
                return $this->error('Задача не найдена', 404);
            }

            // Проверка доступа
            if ($task->client_id !== auth()->id() && !$this->hasRole('Manager')) {
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
    public function update(UpdateClientTaskRequest $request, $id): JsonResponse
    {
        try {
            $task = $this->clientTaskService->findTask($id);
            
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
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Отменить задачу (клиент)
     */
    public function cancel($id): JsonResponse
    {
        try {
            $task = $this->clientTaskService->findTask($id);
            
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
            return $this->error($e->getMessage(), 500);
        }
    }
}