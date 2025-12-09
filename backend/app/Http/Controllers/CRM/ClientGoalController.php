<?php

namespace App\Http\Controllers\CRM;

use App\Http\Controllers\CRM\BaseController;
use App\Http\Requests\ClientGoalRequest;
use App\Http\Requests\AssignGoalRequest;
use Illuminate\Http\Request;
use App\Models\Goal; // ← Импорт модели Goal

class ClientGoalController extends BaseController
{
    protected $goalService;

    public function __construct()
    {
        $this->goalService = new \App\Services\CRM\ClientGoalService();
    }

    // Клиент создает цель
    public function createGoal(ClientGoalRequest $request)
    {
        return response()->json(
            $this->goalService->createClientGoal($request)
        );
    }

    // Менеджер назначает цель команде (только для менеджеров)
    public function assignGoalToTeam(AssignGoalRequest $request, $goalId)
    {
        return response()->json(
            $this->goalService->assignClientGoalToTeam($request, $goalId)
        );
    }

    // Получить мои цели (для клиента)
    public function myGoals(Request $request)
    {
        $client = $request->user();
        
        return response()->json([
            'goals' => $this->goalService->getClientGoals($client),
            'stats' => [
                'total' => Goal::where('user_id', $client->id)->count(),
                'pending' => Goal::where('user_id', $client->id)->where('status', 'pending_review')->count(),
                'in_progress' => Goal::where('user_id', $client->id)->where('status', 'in_progress')->count(),
                'completed' => Goal::where('user_id', $client->id)->where('status', 'completed')->count(),
            ]
        ]);
    }

    // Просмотр конкретной цели с деталями
    public function showGoal($goalId)
    {
        $goal = Goal::with(['project', 'team', 'tasks.assignee', 'activities'])
                   ->findOrFail($goalId);
        
        // Проверка прав доступа
        $user = request()->user();
        if ($goal->user_id != $user->id && !$user->hasAnyRole(['Admin', 'Manager', 'Owner', 'Ceo'])) {
            abort(403, 'Нет доступа к этой цели');
        }

        return response()->json([
            'goal' => $goal,
            'progress_updates' => $goal->activities()->latest()->limit(10)->get(),
            'team_members' => $goal->team ? $goal->team->members : [],
            'project_tasks' => $goal->project ? $goal->project->tasks()->with('assignee')->get() : [],
        ]);
    }

    // Список целей клиентов на рассмотрении (для менеджеров)
    public function pendingGoals(Request $request)
    {
        if (!$request->user()->hasAnyRole(['Admin', 'Manager', 'Owner', 'Ceo'])) {
            abort(403, 'Недостаточно прав');
        }
        
        $pendingGoals = Goal::where('status', 'pending_review')
                           ->where('metadata->is_client_goal', true)
                           ->with(['user:id,name,email,phone'])
                           ->orderBy('created_at', 'desc')
                           ->get()
                           ->map(function($goal) {
                               return [
                                   'id' => $goal->id,
                                   'title' => $goal->title,
                                   'description' => $goal->description,
                                   'client' => [
                                       'id' => $goal->user->id,
                                       'name' => $goal->user->name,
                                       'email' => $goal->user->email,
                                       'phone' => $goal->user->phone,
                                   ],
                                   'deadline' => $goal->end_date,
                                   'priority' => $goal->priority,
                                   'expected_budget' => $goal->metadata['expected_budget'] ?? null,
                                   'created_at' => $goal->created_at,
                                   'attachments_count' => count($goal->attachments ?? []),
                               ];
                           });
                       
        return response()->json([
            'pending_goals' => $pendingGoals,
            'count' => $pendingGoals->count(),
        ]);
    }
}