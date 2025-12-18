<?php

namespace App\Services;

use App\Models\Project;
use App\Models\ClientTask;
use App\Models\Activity;
use App\Models\Team;
use Illuminate\Support\Facades\DB;

class ProjectService
{
    /**
     * Получить все проекты (для менеджеров)
     */
    public function getAllProjects(array $filters = [])
    {
        $query = Project::with(['clientTask.client', 'manager', 'team'])
            ->latest();

        // Фильтрация
        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['team_id'])) {
            $query->where('team_id', $filters['team_id']);
        }

        if (isset($filters['client_id'])) {
            $query->whereHas('clientTask', function ($q) use ($filters) {
                $q->where('client_id', $filters['client_id']);
            });
        }

        // Поиск
        if (isset($filters['search'])) {
            $query->where(function ($q) use ($filters) {
                $q->where('name', 'LIKE', "%{$filters['search']}%")
                  ->orWhere('description', 'LIKE', "%{$filters['search']}%")
                  ->orWhereHas('clientTask', function ($q2) use ($filters) {
                      $q2->where('title', 'LIKE', "%{$filters['search']}%");
                  });
            });
        }

        return $query->paginate($filters['per_page'] ?? 15);
    }

    /**
     * Получить проекты менеджера
     */
    public function getManagerProjects(int $managerId)
    {
        return Project::where('manager_id', $managerId)
            ->with(['clientTask.client', 'team', 'projectTasks' => function ($query) {
                $query->where('status', '!=', 'completed')->latest();
            }])
            ->orderByRaw("FIELD(status, 'active', 'planning', 'on_hold', 'completed')")
            ->paginate(10);
    }

    /**
     * Создать проект
     */
    public function createProject(array $data): Project
    {
        return DB::transaction(function () use ($data) {
            // Получаем задачу клиента
            $clientTask = ClientTask::findOrFail($data['client_task_id']);
            
            // Проверяем что нет существующего проекта
            if ($clientTask->project) {
                throw new \Exception('Для этой задачи уже создан проект');
            }

            // Создаем проект
            $project = Project::create([
                'name' => $data['name'],
                'description' => $data['description'],
                'client_task_id' => $clientTask->id,
                'manager_id' => $data['manager_id'],
                'team_id' => $data['team_id'],
                'start_date' => $data['start_date'],
                'deadline' => $data['deadline'],
                'status' => 'planning'
            ]);

            // Обновляем статус задачи
            $clientTask->update([
                'status' => 'in_progress',
                'manager_id' => $data['manager_id'],
                'assigned_at' => now()
            ]);

            // Создаем стандартные задачи если нужно
            if ($data['create_default_tasks'] ?? false) {
                $project->createDefaultTasks();
            }

            // Логируем
            Activity::log(auth()->user(), 'created', 
                "Создан проект: {$project->name} для задачи: {$clientTask->title}", $project);

            return $project->load(['clientTask', 'team', 'manager']);
        });
    }

    /**
     * Найти проект
     */
    public function findProject(int $id): ?Project
    {
        return Project::with([
            'clientTask.client',
            'manager',
            'team.members',
            'projectTasks.assignee',
            'projectTasks.creator'
        ])->find($id);
    }

    /**
     * Получить проект с деталями
     */
    public function getProjectWithDetails(int $id)
    {
        $project = $this->findProject($id);
        
        if ($project) {
            $project->load(['projectTasks' => function ($query) {
                $query->orderBy('priority')->orderBy('due_date');
            }]);
            
            // Прогресс проекта
            $project->progress_calculated = $project->progress;
        }

        return $project;
    }

    /**
     * Обновить проект
     */
    public function updateProject(Project $project, array $data): Project
    {
        $oldData = $project->toArray();

        $project->update($data);

        // Логируем изменения
        $changes = array_diff_assoc($project->toArray(), $oldData);
        if (!empty($changes)) {
            Activity::log(auth()->user(), 'updated', 
                "Проект обновлен: {$project->name}", $project, $oldData, $changes);
        }

        return $project->fresh();
    }

    /**
     * Запустить проект
     */
    public function startProject(Project $project): void
    {
        if ($project->status !== 'planning') {
            throw new \Exception('Можно запустить только проекты в статусе планирования');
        }

        $project->start();

        Activity::log(auth()->user(), 'started', 
            "Проект запущен: {$project->name}", $project);
    }

    /**
     * Завершить проект
     */
    public function completeProject(Project $project): void
    {
        // Проверяем что все задачи завершены
        $incompleteTasks = $project->projectTasks()
            ->where('status', '!=', 'completed')
            ->count();

        if ($incompleteTasks > 0) {
            throw new \Exception('Не все задачи проекта завершены');
        }

        $project->complete();

        Activity::log(auth()->user(), 'completed', 
            "Проект завершен: {$project->name}", $project);
    }

    /**
     * Получить статистику проекта
     */
    public function getProjectStats(Project $project): array
    {
        $tasks = $project->projectTasks;
        
        return [
            'total_tasks' => $tasks->count(),
            'completed_tasks' => $tasks->where('status', 'completed')->count(),
            'in_progress_tasks' => $tasks->where('status', 'in_progress')->count(),
            'overdue_tasks' => $tasks->filter(fn($task) => $task->isOverdue())->count(),
            'total_estimated_hours' => $tasks->sum('estimated_hours'),
            'total_actual_hours' => $tasks->sum('actual_hours'),
            'progress_percentage' => $project->progress
        ];
    }
}