<?php

namespace App\Services;

use App\Models\Team;
use App\Models\User;
use App\Models\Activity;
use Illuminate\Support\Facades\DB;

class TeamService
{
    /**
     * Получить все команды
     */
    public function getAllTeams(array $filters = [])
    {
        $query = Team::with(['leader', 'members'])
            ->latest();

        if (isset($filters['department'])) {
            $query->where('department', $filters['department']);
        }

        if (isset($filters['search'])) {
            $query->where('name', 'LIKE', "%{$filters['search']}%");
        }

        return $query->paginate($filters['per_page'] ?? 20);
    }

    /**
     * Создать команду
     */
    public function createTeam(array $data): Team
    {
        return DB::transaction(function () use ($data) {
            $team = Team::create([
                'name' => $data['name'],
                'description' => $data['description'],
                'leader_id' => $data['leader_id'],
                'department' => $data['department'] ?? null
            ]);

            // Добавляем участников если указаны
            if (isset($data['members']) && is_array($data['members'])) {
                foreach ($data['members'] as $member) {
                    $team->addMember(User::find($member['user_id']), $member['role'] ?? 'member');
                }
            }

            // Добавляем лидера как участника
            $team->addMember(User::find($data['leader_id']), 'lead');

            Activity::log(auth()->user(), 'created', 
                "Создана команда: {$team->name}", $team);

            return $team->load(['leader', 'members']);
        });
    }

    /**
     * Найти команду
     */
    public function findTeam(int $id): ?Team
    {
        return Team::with(['leader', 'members', 'projects.clientTask'])->find($id);
    }

    /**
     * Обновить команду
     */
    public function updateTeam(Team $team, array $data): Team
    {
        $oldData = $team->toArray();

        $team->update($data);

        // Логируем изменения
        $changes = array_diff_assoc($team->toArray(), $oldData);
        if (!empty($changes)) {
            Activity::log(auth()->user(), 'updated', 
                "Команда обновлена: {$team->name}", $team, $oldData, $changes);
        }

        return $team->fresh();
    }

    /**
     * Добавить участника в команду
     */
    public function addMember(Team $team, int $userId, string $role = 'member'): void
    {
        $user = User::findOrFail($userId);

        // Проверяем что пользователь не в команде
        if ($team->hasMember($user)) {
            throw new \Exception('Пользователь уже в команде');
        }

        $team->addMember($user, $role);

        Activity::log(auth()->user(), 'member_added', 
            "{$user->name} добавлен в команду {$team->name} как {$role}", $team);
    }

    /**
     * Удалить участника из команды
     */
    public function removeMember(Team $team, int $userId): void
    {
        $user = User::findOrFail($userId);

        if (!$team->hasMember($user)) {
            throw new \Exception('Пользователь не в команде');
        }

        // Нельзя удалить лидера
        if ($team->leader_id === $userId) {
            throw new \Exception('Нельзя удалить лидера команды');
        }

        $team->removeMember($user);

        Activity::log(auth()->user(), 'member_removed', 
            "{$user->name} удален из команды {$team->name}", $team);
    }

    /**
     * Получить статистику команды
     */
    public function getTeamStats(Team $team): array
    {
        return [
            'total_members' => $team->members()->count(),
            'active_projects' => $team->projects()->where('status', 'active')->count(),
            'completed_projects' => $team->projects()->where('status', 'completed')->count(),
            'total_projects' => $team->projects()->count(),
            'upcoming_deadlines' => $team->projects()
                ->where('deadline', '>', now())
                ->where('deadline', '<=', now()->addDays(7))
                ->count()
        ];
    }
}