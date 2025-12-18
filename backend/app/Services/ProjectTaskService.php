<?php

namespace App\Services;

use App\Models\ProjectTask;
use App\Models\Project;
use App\Models\Activity;
use Illuminate\Support\Facades\DB;

class ProjectTaskService
{
    /**
     * Получить задачи сотрудника
     */
    public function getEmployeeTasks(int $employeeId, array $filters = [])
    {
        $query = ProjectTask::where('assignee_id', $employeeId)
            ->with(['project.clientTask', 'creator'])
            ->orderByRaw("FIELD(status, 'in_progress', 'todo', 'review', 'completed', 'blocked')")
            ->orderBy('priority')
            ->orderBy('due_date');

        // Фильтрация по статусу
        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        // Фильтрация по проекту
        if (isset($filters['project_id'])) {
            $query->where('project_id', $filters['project_id']);
        }

        // Только просроченные
        if (isset($filters['overdue']) && $filters['overdue']) {
            $query->where('due_date', '<', now())
                  ->where('status', '!=', 'completed');
        }

        return $query->paginate($filters['per_page'] ?? 20);
    }

    /**
     * Создать подзадачу
     */
    public function createTask(array $data): ProjectTask
    {
        return DB::transaction(function () use ($data) {
            // Проверяем проект
            $project = Project::findOrFail($data['project_id']);
            
            if ($project->status === 'completed') {
                throw new \Exception('Нельзя добавлять задачи в завершенный проект');
            }

            // Создаем задачу
            $task = ProjectTask::create($data);

            // Логируем
            Activity::log(auth()->user(), 'created', 
                "Создана подзадача: {$task->title} в проекте: {$project->name}", $task);

            return $task->load(['project', 'assignee', 'creator']);
        });
    }

    /**
     * Найти задачу
     */
    public function findTask(int $id): ?ProjectTask
    {
        return ProjectTask::with(['project.clientTask', 'assignee', 'creator'])->find($id);
    }

    /**
     * Обновить задачу
     */
    public function updateTask(ProjectTask $task, array $data): ProjectTask
    {
        $oldData = $task->toArray();

        $task->update($data);

        // Если задача завершена - обновляем прогресс проекта
        if (isset($data['status']) && $data['status'] === 'completed') {
            $task->markAsCompleted();
        }

        // Логируем изменения
        $changes = array_diff_assoc($task->toArray(), $oldData);
        if (!empty($changes)) {
            Activity::log(auth()->user(), 'updated', 
                "Подзадача обновлена: {$task->title}", $task, $oldData, $changes);
        }

        return $task->fresh();
    }

    /**
     * Назначить задачу исполнителю
     */
    public function assignTask(ProjectTask $task, int $assigneeId): void
    {
        $oldAssignee = $task->assignee_id;

        $task->update([
            'assignee_id' => $assigneeId,
            'status' => 'in_progress'
        ]);

        Activity::log(auth()->user(), 'assigned', 
            "Задача назначена на нового исполнителя (был: {$oldAssignee})", $task);
    }

    /**
     * Отметить задачу как выполненную
     */
    public function completeTask(ProjectTask $task): void
    {
        if ($task->status === 'completed') {
            throw new \Exception('Задача уже завершена');
        }

        $task->markAsCompleted();
    }

    /**
     * Обновить затраченное время
     */
    public function updateTimeSpent(ProjectTask $task, int $hours): void
    {
        $task->updateTimeSpent($hours);

        Activity::log(auth()->user(), 'time_updated', 
            "Обновлено время выполнения задачи: {$hours} часов", $task);
    }

    /**
     * Получить статистику по задачам
     */
    public function getEmployeeStats(int $employeeId): array
    {
        $tasks = ProjectTask::where('assignee_id', $employeeId)->get();

        return [
            'total_tasks' => $tasks->count(),
            'completed_tasks' => $tasks->where('status', 'completed')->count(),
            'in_progress_tasks' => $tasks->where('status', 'in_progress')->count(),
            'overdue_tasks' => $tasks->filter(fn($task) => $task->isOverdue())->count(),
            'total_estimated_hours' => $tasks->sum('estimated_hours'),
            'total_actual_hours' => $tasks->sum('actual_hours'),
            'completion_rate' => $tasks->count() > 0 
                ? round(($tasks->where('status', 'completed')->count() / $tasks->count()) * 100, 1)
                : 0
        ];
    }
}