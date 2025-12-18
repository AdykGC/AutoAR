<?php

namespace App\Services;

use App\Models\User;
use App\Models\ClientTask;
use App\Models\Project;
use App\Models\ProjectTask;
use Carbon\Carbon;

class DashboardService
{
    /**
     * Статистика для клиента
     */
    public function getClientStats(int $clientId): array
    {
        $tasks = ClientTask::where('client_id', $clientId)->get();
        
        $total = $tasks->count();
        $completed = $tasks->where('status', 'completed')->count();
        $inProgress = $tasks->where('status', 'in_progress')->count();
        $pending = $tasks->where('status', 'pending')->count();

        // Последние активные проекты
        $activeProjects = Project::whereHas('clientTask', function ($query) use ($clientId) {
            $query->where('client_id', $clientId);
        })
        ->where('status', 'active')
        ->with(['clientTask', 'team', 'projectTasks' => function ($query) {
            $query->where('status', '!=', 'completed')->latest();
        }])
        ->orderBy('deadline')
        ->limit(5)
        ->get();

        // Последние обновления
        $recentUpdates = $tasks->sortByDesc('updated_at')->take(5);

        return [
            'overview' => [
                'total_tasks' => $total,
                'completed_tasks' => $completed,
                'in_progress_tasks' => $inProgress,
                'pending_tasks' => $pending,
                'completion_rate' => $total > 0 ? round(($completed / $total) * 100, 1) : 0
            ],
            'active_projects' => $activeProjects,
            'recent_updates' => $recentUpdates,
            'upcoming_deadlines' => $tasks->where('deadline', '>=', now())
                ->where('deadline', '<=', now()->addDays(30))
                ->sortBy('deadline')
                ->values()
        ];
    }

    /**
     * Статистика для менеджера
     */
    public function getManagerStats(int $managerId): array
    {
        // Проекты менеджера
        $projects = Project::where('manager_id', $managerId)->get();
        
        // Задачи на рассмотрении
        $pendingTasks = ClientTask::where('status', 'pending')->count();

        // Активность команды
        $teamActivity = ProjectTask::whereHas('project', function ($query) use ($managerId) {
            $query->where('manager_id', $managerId);
        })
        ->where('updated_at', '>=', now()->subDays(7))
        ->groupBy('status')
        ->selectRaw('status, count(*) as count')
        ->pluck('count', 'status');

        // Просроченные проекты
        $overdueProjects = $projects->filter(function ($project) {
            return $project->deadline && $project->deadline->isPast() && 
                   $project->status !== 'completed';
        })->count();

        return [
            'overview' => [
                'total_projects' => $projects->count(),
                'active_projects' => $projects->where('status', 'active')->count(),
                'pending_tasks' => $pendingTasks,
                'overdue_projects' => $overdueProjects,
                'team_productivity' => $this->calculateTeamProductivity($managerId)
            ],
            'project_statuses' => [
                'planning' => $projects->where('status', 'planning')->count(),
                'active' => $projects->where('status', 'active')->count(),
                'on_hold' => $projects->where('status', 'on_hold')->count(),
                'completed' => $projects->where('status', 'completed')->count()
            ],
            'team_activity' => $teamActivity,
            'urgent_projects' => $projects->where('status', 'active')
                ->filter(fn($p) => $p->deadline && $p->deadline->diffInDays(now()) <= 7)
                ->sortBy('deadline')
                ->values()
        ];
    }

    /**
     * Статистика для сотрудника
     */
    public function getEmployeeStats(int $employeeId): array
    {
        $tasks = ProjectTask::where('assignee_id', $employeeId)->get();
        
        // Текущие задачи
        $currentTasks = $tasks->where('status', 'in_progress')
            ->sortBy('due_date')
            ->values();

        // Предстоящие сроки
        $upcomingDeadlines = $tasks->where('due_date', '>=', now())
            ->where('due_date', '<=', now()->addDays(7))
            ->sortBy('due_date')
            ->values();

        // Продуктивность за неделю
        $weeklyStats = $this->calculateWeeklyProductivity($employeeId);

        return [
            'overview' => [
                'total_tasks' => $tasks->count(),
                'completed_tasks' => $tasks->where('status', 'completed')->count(),
                'in_progress_tasks' => $tasks->where('status', 'in_progress')->count(),
                'overdue_tasks' => $tasks->filter(fn($task) => $task->isOverdue())->count()
            ],
            'current_tasks' => $currentTasks,
            'upcoming_deadlines' => $upcomingDeadlines,
            'weekly_productivity' => $weeklyStats,
            'recent_completions' => $tasks->where('status', 'completed')
                ->sortByDesc('completed_at')
                ->take(5)
                ->values()
        ];
    }

    /**
     * Рассчитать продуктивность команды
     */
    private function calculateTeamProductivity(int $managerId): float
    {
        $completedTasks = ProjectTask::whereHas('project', function ($query) use ($managerId) {
            $query->where('manager_id', $managerId);
        })
        ->where('status', 'completed')
        ->where('completed_at', '>=', now()->subDays(30))
        ->count();

        $totalTasks = ProjectTask::whereHas('project', function ($query) use ($managerId) {
            $query->where('manager_id', $managerId);
        })
        ->where('created_at', '>=', now()->subDays(30))
        ->count();

        return $totalTasks > 0 ? round(($completedTasks / $totalTasks) * 100, 1) : 0;
    }

    /**
     * Рассчитать недельную продуктивность
     */
    private function calculateWeeklyProductivity(int $employeeId): array
    {
        $stats = [];
        
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $dayStart = $date->copy()->startOfDay();
            $dayEnd = $date->copy()->endOfDay();

            $completed = ProjectTask::where('assignee_id', $employeeId)
                ->where('status', 'completed')
                ->whereBetween('completed_at', [$dayStart, $dayEnd])
                ->count();

            $stats[$date->format('Y-m-d')] = [
                'day' => $date->format('D'),
                'completed_tasks' => $completed
            ];
        }

        return $stats;
    }
}