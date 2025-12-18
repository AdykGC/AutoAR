<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\ProjectTask\CreateProjectTaskRequest;
use App\Http\Requests\ProjectTask\UpdateProjectTaskRequest;
use App\Services\ProjectTaskService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProjectTaskController extends BaseController
{
    protected $projectTaskService;

    public function __construct(ProjectTaskService $projectTaskService)
    {
        $this->projectTaskService = $projectTaskService;
        $this->middleware('auth:sanctum');
    }

    /**
     * Мои задачи (сотрудник)
     */
    public function myTasks(Request $request): JsonResponse
    {
        try {
            $tasks = $this->projectTaskService->getEmployeeTasks(auth()->id(), $request->all());
            return $this->success($tasks);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Создать подзадачу (менеджер)
     */
    public function store(CreateProjectTaskRequest $request): JsonResponse
    {
        try {
            if (!$this->hasRole('Manager')) {
                return $this->error('Только менеджеры могут создавать задачи', 403);
            }

            $data = $request->validated();
            $data['creator_id'] = auth()->id();
            
            $task = $this->projectTaskService->createTask($data);
            return $this->success($task, 'Задача создана', 201);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Обновить задачу
     */
    public function update(UpdateProjectTaskRequest $request, $id): JsonResponse
    {
        try {
            $task = $this->projectTaskService->findTask($id);
            
            if (!$task) {
                return $this->error('Задача не найдена', 404);
            }

            // Проверка доступа
            $user = auth()->user();
            if ($task->assignee_id !== $user->id && 
                $task->creator_id !== $user->id &&
                !$user->hasRole('Manager')) {
                return $this->error('Доступ запрещен', 403);
            }

            $updatedTask = $this->projectTaskService->updateTask($task, $request->validated());
            return $this->success($updatedTask, 'Задача обновлена');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Назначить задачу на исполнителя (менеджер)
     */
    public function assign(Request $request, $id): JsonResponse
    {
        try {
            if (!$this->hasRole('Manager')) {
                return $this->error('Только менеджеры могут назначать задачи', 403);
            }

            $request->validate([
                'assignee_id' => 'required|exists:users,id'
            ]);

            $task = $this->projectTaskService->findTask($id);
            
            if (!$task) {
                return $this->error('Задача не найдена', 404);
            }

            // Проверка что менеджер управляет этим проектом
            if ($task->project->manager_id !== auth()->id()) {
                return $this->error('Вы не менеджер этого проекта', 403);
            }

            $this->projectTaskService->assignTask($task, $request->assignee_id);
            return $this->success(null, 'Задача назначена');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Отметить как выполненную (сотрудник)
     */
    public function complete($id): JsonResponse
    {
        try {
            $task = $this->projectTaskService->findTask($id);
            
            if (!$task) {
                return $this->error('Задача не найдена', 404);
            }

            if ($task->assignee_id !== auth()->id()) {
                return $this->error('Вы не назначены на эту задачу', 403);
            }

            $this->projectTaskService->completeTask($task);
            return $this->success(null, 'Задача выполнена');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Обновить затраченное время
     */
    public function updateTime(Request $request, $id): JsonResponse
    {
        try {
            $request->validate([
                'actual_hours' => 'required|integer|min:0'
            ]);

            $task = $this->projectTaskService->findTask($id);
            
            if (!$task) {
                return $this->error('Задача не найдена', 404);
            }

            if ($task->assignee_id !== auth()->id()) {
                return $this->error('Вы не назначены на эту задачу', 403);
            }

            $this->projectTaskService->updateTimeSpent($task, $request->actual_hours);
            return $this->success(null, 'Время обновлено');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }
}