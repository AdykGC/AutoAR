<?php

namespace App\Services\CRM;

use App\Models\Goal;
use App\Models\User;
use App\Models\Project;
use App\Models\Team;
use Illuminate\Support\Facades\Storage;

class ClientGoalService
{
    // Клиент создает цель
    public function createClientGoal($request)
    {
        $client = $request->user();
        
        // Создаем цель клиента
        $goal = Goal::create([
            'title' => $request->title,
            'description' => $request->description,
            'type' => 'client_' . $request->type, // client_business, client_personal, etc
            'user_id' => $client->id, // Клиент - владелец цели
            'assigned_by' => $client->id, // Сам себе назначил
            'target_value' => $request->target_value,
            'current_value' => 0,
            'unit' => $request->unit,
            'start_date' => now(),
            'end_date' => $request->deadline,
            'status' => 'pending_review', // На рассмотрении
            'priority' => $request->priority,
            'metadata' => [
                'client_id' => $client->id,
                'client_type' => $client->getRoleNames()->first(),
                'expected_budget' => $request->expected_budget,
                'is_client_goal' => true,
                'can_be_assigned' => true, // Можно передать команде
            ]
        ]);

        // Обработка вложений
        if ($request->hasFile('attachments')) {
            $attachments = [];
            foreach ($request->file('attachments') as $file) {
                $path = $file->store('client-goals/' . $client->id, 'public');
                $attachments[] = [
                    'name' => $file->getClientOriginalName(),
                    'path' => $path,
                    'size' => $file->getSize(),
                    'mime' => $file->getMimeType(),
                ];
            }
            $goal->update(['attachments' => $attachments]);
        }

        // Отправляем уведомление менеджерам/админам
        $this->notifyManagersAboutClientGoal($client, $goal);

        return [
            'message' => 'Цель успешно создана и отправлена на рассмотрение',
            'goal' => $goal,
            'next_steps' => [
                'wait_for_review' => 'Ваша цель будет рассмотрена менеджером',
                'possible_assignment' => 'После одобрения цель может быть передана команде',
                'estimated_time' => 'Рассмотрение занимает 1-2 рабочих дня',
            ]
        ];
    }

    // Менеджер принимает цель клиента и назначает команде
    public function assignClientGoalToTeam($request, $goalId)
    {
        $manager = $request->user();
        
        if (!$manager->hasAnyRole(['Admin', 'Manager', 'Owner', 'Ceo'])) {
            abort(403, 'Только менеджеры могут назначать цели командам');
        }

        $goal = Goal::findOrFail($goalId);
        
        // Проверяем, что это цель клиента
        if (!($goal->metadata['is_client_goal'] ?? false)) {
            abort(422, 'Это не цель клиента');
        }

        // Находим или создаем проект для этой цели
        $project = $this->createOrAssignProject($goal, $request);
        
        // Назначаем команду
        $team = Team::findOrFail($request->team_id);
        
        // Обновляем цель
        $goal->update([
            'status' => 'assigned',
            'assigned_by' => $manager->id,
            'project_id' => $project->id,
            'team_id' => $team->id,
            'metadata' => array_merge($goal->metadata, [
                'assigned_at' => now(),
                'assigned_by_manager' => $manager->id,
                'assigned_team' => $team->id,
                'project_id' => $project->id,
            ])
        ]);

        // Создаем задачи для команды на основе цели
        $this->createTasksFromClientGoal($goal, $team, $project);

        // Уведомляем клиента
        $this->notifyClientAboutAssignment($goal->user, $goal, $team);

        return [
            'message' => 'Цель клиента успешно назначена команде',
            'goal' => $goal,
            'project' => $project,
            'team' => $team,
            'client' => $goal->user,
        ];
    }

    private function createOrAssignProject($goal, $request)
    {
        // Если указан существующий проект
        if ($request->has('project_id')) {
            return Project::findOrFail($request->project_id);
        }

        // Создаем новый проект для цели клиента
        return Project::create([
            'name' => "Проект: " . $goal->title,
            'description' => $goal->description,
            'manager_id' => $request->user()->id,
            'client_id' => $goal->user_id,
            'budget' => $goal->metadata['expected_budget'] ?? null,
            'start_date' => now(),
            'deadline' => $goal->end_date,
            'priority' => $goal->priority,
            'status' => 'planning',
            'source_goal_id' => $goal->id,
        ]);
    }

    private function createTasksFromClientGoal($goal, $team, $project)
    {
        $tasks = [];
        
        // Автоматически создаем базовые задачи
        $baseTasks = [
            [
                'title' => 'Анализ требований клиента',
                'description' => 'Изучить цель клиента и требования',
                'estimated_hours' => 8,
                'priority' => 'high',
            ],
            [
                'title' => 'Планирование реализации',
                'description' => 'Создать план достижения цели',
                'estimated_hours' => 16,
                'priority' => 'medium',
            ],
            [
                'title' => 'Реализация цели',
                'description' => 'Основная работа по достижению цели клиента',
                'estimated_hours' => 40,
                'priority' => 'high',
            ],
        ];

        foreach ($baseTasks as $taskData) {
            $task = $project->tasks()->create(array_merge($taskData, [
                'creator_id' => $goal->assigned_by,
                'goal_id' => $goal->id,
                'due_date' => $goal->end_date,
                'status' => 'todo',
            ]));
            
            $tasks[] = $task;
        }

        return $tasks;
    }

    private function notifyManagersAboutClientGoal($client, $goal)
    {
        // Находим всех менеджеров
        $managers = User::role(['Admin', 'Manager', 'Owner', 'Ceo'])->get();
        
        foreach ($managers as $manager) {
            // Отправляем уведомление
            // $manager->notify(new ClientGoalCreatedNotification($client, $goal));
            
            // Или создаем запись в системе
            \App\Models\Notification::create([
                'user_id' => $manager->id,
                'type' => 'client_goal_created',
                'data' => [
                    'client_id' => $client->id,
                    'client_name' => $client->name,
                    'goal_id' => $goal->id,
                    'goal_title' => $goal->title,
                    'created_at' => now(),
                ],
                'read_at' => null,
            ]);
        }
    }

    private function notifyClientAboutAssignment($client, $goal, $team)
    {
        // Уведомляем клиента
        \App\Models\Notification::create([
            'user_id' => $client->id,
            'type' => 'goal_assigned',
            'data' => [
                'goal_id' => $goal->id,
                'goal_title' => $goal->title,
                'team_name' => $team->name,
                'team_leader' => $team->leader->name,
                'assigned_at' => now(),
                'estimated_completion' => $goal->end_date,
            ],
            'read_at' => null,
        ]);
    }

    // Получить цели клиента с статусами
    public function getClientGoals($client)
    {
        return Goal::where('user_id', $client->id)
                   ->where('metadata->is_client_goal', true)
                   ->with(['project', 'team', 'tasks'])
                   ->orderBy('created_at', 'desc')
                   ->get()
                   ->map(function($goal) {
                       return [
                           'id' => $goal->id,
                           'title' => $goal->title,
                           'status' => $goal->status,
                           'progress' => $goal->current_value / $goal->target_value * 100,
                           'deadline' => $goal->end_date,
                           'assigned_to' => $goal->team ? $goal->team->name : 'Не назначено',
                           'project' => $goal->project ? $goal->project->name : 'Не создан',
                           'tasks_count' => $goal->tasks->count(),
                           'completed_tasks' => $goal->tasks->where('status', 'completed')->count(),
                           'created_at' => $goal->created_at,
                       ];
                   });
    }
}