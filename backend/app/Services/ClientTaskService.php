<?php

namespace App\Services;

use App\Models\ClientTask;
use App\Models\Activity;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class ClientTaskService
{
    /**
     * Получить задачи клиента
     */
    public function getClientTasks(int $clientId, array $filters = [])
    {
        $query = ClientTask::where('client_id', $clientId)
            ->with(['manager', 'project.team'])
            ->latest();

        // Фильтрация по статусу
        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        // Поиск
        if (isset($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($q) use ($search) {
                $q->where('title', 'LIKE', "%{$search}%")
                  ->orWhere('description', 'LIKE', "%{$search}%");
            });
        }

        // Сортировка
        $sortBy = $filters['sort_by'] ?? 'created_at';
        $sortOrder = $filters['sort_order'] ?? 'desc';
        $query->orderBy($sortBy, $sortOrder);

        return $query->paginate($filters['per_page'] ?? 15);
    }

    /**
     * Создать новую задачу
     */
    public function createTask(array $data): ClientTask
    {
        return DB::transaction(function () use ($data) {
            $task = ClientTask::create($data);

            // Логируем создание
            Activity::log(auth()->user(), 'created', 
                "Создана новая задача: {$task->title}", $task);

            return $task->load('client');
        });
    }

    /**
     * Найти задачу
     */
    public function findTask(int $id): ?ClientTask
    {
        return ClientTask::with(['client', 'manager', 'project.projectTasks.assignee'])->find($id);
    }

    /**
     * Получить задачу с прогрессом
     */
    public function getTaskWithProgress(int $taskId, int $userId)
    {
        $task = $this->findTask($taskId);
        
        if (!$task) {
            return null;
        }

        // Проверяем доступ
        if ($task->client_id !== $userId && !auth()->user()->hasRole('Manager')) {
            throw new \Exception('Доступ запрещен');
        }

        // Рассчитываем прогресс если есть проект
        if ($task->project) {
            $task->progress_calculated = $task->calculateProgress();
            $task->project->load(['projectTasks' => function ($query) {
                $query->orderBy('priority')->orderBy('due_date');
            }]);
        }

        return $task;
    }

    /**
     * Обновить задачу
     */
    public function updateTask(ClientTask $task, array $data): ClientTask
    {
        $oldData = $task->toArray();

        $task->update($data);

        // Логируем изменения
        $changes = array_diff_assoc($task->toArray(), $oldData);
        if (!empty($changes)) {
            Activity::log(auth()->user(), 'updated', 
                "Задача обновлена: {$task->title}", $task, $oldData, $changes);
        }

        return $task->fresh();
    }

    /**
     * Отменить задачу
     */
    public function cancelTask(ClientTask $task): void
    {
        DB::transaction(function () use ($task) {
            $oldStatus = $task->status;
            $task->update(['status' => 'cancelled']);

            // Отменяем связанный проект если есть
            if ($task->project) {
                $task->project->update(['status' => 'cancelled']);
            }

            Activity::log(auth()->user(), 'cancelled', 
                "Задача отменена: {$task->title} (был статус: {$oldStatus})", $task);
        });
    }

    /**
     * Назначить менеджера на задачу
     */
    public function assignManager(ClientTask $task, User $manager): void
    {
        $task->assignToManager($manager);
    }

    /**
     * Получить задачи на рассмотрении (для менеджеров)
     */
    public function getPendingTasks(array $filters = [])
    {
        $query = ClientTask::where('status', 'pending')
            ->with('client')
            ->latest();

        if (isset($filters['search'])) {
            $query->where('title', 'LIKE', "%{$filters['search']}%");
        }

        return $query->paginate($filters['per_page'] ?? 20);
    }
}