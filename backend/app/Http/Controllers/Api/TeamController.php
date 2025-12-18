<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Team\CreateTeamRequest;
use App\Http\Requests\Team\UpdateTeamRequest;
use App\Services\TeamService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeamController extends BaseController
{
    protected $teamService;

    public function __construct(TeamService $teamService)
    {
        $this->teamService = $teamService;
        $this->middleware('auth:sanctum');
        $this->middleware('role:Manager|Admin|Owner|CEO')->except(['index', 'show']);
    }

    /**
     * Список команд
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $teams = $this->teamService->getAllTeams($request->all());
            return $this->success($teams);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Создать команду
     */
    public function store(CreateTeamRequest $request): JsonResponse
    {
        try {
            $data = $request->validated();
            $data['leader_id'] = auth()->id();
            
            $team = $this->teamService->createTeam($data);
            return $this->success($team, 'Команда создана', 201);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Добавить участника в команду
     */
    public function addMember(Request $request, $id): JsonResponse
    {
        try {
            $request->validate([
                'user_id' => 'required|exists:users,id',
                'role' => 'sometimes|string|in:member,senior,lead'
            ]);

            $team = $this->teamService->findTeam($id);
            
            if (!$team) {
                return $this->error('Команда не найдена', 404);
            }

            if ($team->leader_id !== auth()->id() && !$this->hasRole('Admin')) {
                return $this->error('Вы не лидер этой команды', 403);
            }

            $this->teamService->addMember($team, $request->user_id, $request->role ?? 'member');
            return $this->success(null, 'Участник добавлен');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Удалить участника из команды
     */
    public function removeMember(Request $request, $id, $userId): JsonResponse
    {
        try {
            $team = $this->teamService->findTeam($id);
            
            if (!$team) {
                return $this->error('Команда не найдена', 404);
            }

            if ($team->leader_id !== auth()->id() && !$this->hasRole('Admin')) {
                return $this->error('Вы не лидер этой команды', 403);
            }

            $this->teamService->removeMember($team, $userId);
            return $this->success(null, 'Участник удален');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }
}