<?php

namespace App\Services;

use App\Models\ClientTask;
use App\Models\Activity;
use App\Models\User;
use App\Models\Team;
use App\Models\Project;
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
     * Получить все задачи (для менеджеров)
     */
    public function getAllTasks(array $filters = [])
    {
        $query = ClientTask::with(['client', 'manager', 'project'])
            ->latest();

        // Фильтрация по статусу
        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        // Фильтрация по клиенту
        if (isset($filters['client_id'])) {
            $query->where('client_id', $filters['client_id']);
        }

        // Поиск
        if (isset($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($q) use ($search) {
                $q->where('title', 'LIKE', "%{$search}%")
                  ->orWhere('description', 'LIKE', "%{$search}%")
                  ->orWhereHas('client', function ($q) use ($search) {
                      $q->where('name', 'LIKE', "%{$search}%");
                  });
            });
        }

        // Сортировка
        $sortBy = $filters['sort_by'] ?? 'created_at';
        $sortOrder = $filters['sort_order'] ?? 'desc';
        $query->orderBy($sortBy, $sortOrder);

        return $query->paginate($filters['per_page'] ?? 20);
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
    public function updateTask(ClientTask $task, array $data): ClientTask {
        $oldData = $task->toArray();
        $task->update($data);
        // Простое логирование без передачи массивов
        Activity::log(auth()->user(), 'updated', 
            "Задача обновлена: {$task->title}. Изменены поля: " . implode(', ', array_keys($data)),
            $task
        );
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
     * Одобрить задачу и создать проект
     */
    public function approveTask(ClientTask $task): ClientTask
    {
        return DB::transaction(function () use ($task) {
            $oldStatus = $task->status;
            
            // Обновляем статус задачи
            $task->update([
                'status' => 'approved',
                'approved_at' => now(),
                'manager_id' => auth()->id() // Назначаем текущего менеджера
            ]);

            // СОЗДАЕМ ПРОЕКТ АВТОМАТИЧЕСКИ
            $this->createProjectForTask($task);

            // Создаем активность
            Activity::log(auth()->user(), 'approved', 
                "Задача одобрена: {$task->title} (был статус: {$oldStatus})", $task);

            return $task->fresh();
        });
    }

    /**
     * Создать проект для одобренной задачи
     */
    private function createProjectForTask(ClientTask $task): void {
        // Ищем первую команду
        $team = Team::first();

        if (!$team) {
            // Создаем команду по умолчанию если нет
            $team = Team::create([
                'name' => 'Команда по умолчанию',
                'description' => 'Автоматически созданная команда',
                'leader_id' => auth()->id(),
                'department' => 'Разработка'
            ]);
        }

        // Создаем проект
        $project = Project::create([
            'name' => "Проект: {$task->title}",
            'description' => $task->description,
            'client_task_id' => $task->id,
            'manager_id' => auth()->id(),
            'team_id' => $team->id,
            'status' => 'planning',
            'start_date' => now(),
            'deadline' => $task->deadline ?? now()->addDays(30)
        ]);

        // Создаем стандартные подзадачи
        $this->createDefaultProjectTasks($project, $task);

        Activity::log(auth()->user(), 'created', 
            "Создан проект: {$project->name} для задачи: {$task->title}", $project);
    }


    /**
    * Создать стандартные подзадачи для проекта
    */
    private function createDefaultProjectTasks(Project $project, ClientTask $task): void
    {
        $defaultTasks = [
            [
                'title' => 'Анализ требований',
                'description' => 'Изучить требования задачи: ' . $task->title,
                'estimated_hours' => 8,
                'priority' => '1',
                'status' => 'todo'
            ],
            [
                'title' => 'Планирование',
                'description' => 'Создать план проекта',
                'estimated_hours' => 4,
                'priority' => '2',
                'status' => 'todo'
            ],
            [
                'title' => 'Разработка',
                'description' => 'Выполнить основную работу по проекту',
                'estimated_hours' => 40,
                'priority' => '1',
                'status' => 'todo'
            ],
            [
                'title' => 'Тестирование',
                'description' => 'Проверить качество работы',
                'estimated_hours' => 8,
                'priority' => '2',
                'status' => 'todo'
            ],
            [
                'title' => 'Сдача проекта',
                'description' => 'Подготовить документацию и сдать проект клиенту',
                'estimated_hours' => 4,
                'priority' => '3',
                'status' => 'todo'
            ]
        ];

        foreach ($defaultTasks as $index => $taskData) {
            $project->projectTasks()->create([
                'title' => $taskData['title'],
                'description' => $taskData['description'],
                'project_id' => $project->id,
                'creator_id' => auth()->id(),
                'estimated_hours' => $taskData['estimated_hours'],
                'priority' => $taskData['priority'],
                'status' => $taskData['status'],
                'order' => $index + 1,
                'due_date' => now()->addDays($index * 3 + 1) // Каждая задача через 3 дня
            ]);
        }
    }
    /**
    * Отклонить задачу
    */
    public function rejectTask(ClientTask $task, string $reason = null): ClientTask
    {
        return DB::transaction(function () use ($task, $reason) {
            $oldStatus = $task->status;
            
            $task->update([
                'status' => 'rejected',
                'rejected_at' => now(),
                'rejection_reason' => $reason
            ]);

            Activity::log(auth()->user(), 'rejected', 
                "Задача отклонена: {$task->title} (был статус: {$oldStatus})", $task);

            return $task->fresh();
        });
    }

    /**
     * Назначить менеджера на задачу
     */
    public function assignManager(ClientTask $task, int $managerId): void
    {
        $manager = User::findOrFail($managerId);
        
        // Проверяем, что пользователь является менеджером
        if (!$manager->hasRole('Manager') && !$manager->hasRole('Admin')) {
            throw new \Exception('Пользователь не является менеджером');
        }

        $task->assignToManager($manager);
    }
}