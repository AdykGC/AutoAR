<?php

namespace App\Services;

use App\Models\Activity;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;

class ActivityService
{
    /**
     * Получить активность пользователя
     */
    public function getUserActivity(int $userId, array $filters = [])
    {
        $query = Activity::where('user_id', $userId)
            ->with('activityable')
            ->latest();

        if (isset($filters['type'])) {
            $query->where('type', $filters['type']);
        }

        if (isset($filters['date_from'])) {
            $query->where('created_at', '>=', $filters['date_from']);
        }

        if (isset($filters['date_to'])) {
            $query->where('created_at', '<=', $filters['date_to']);
        }

        return $query->paginate($filters['per_page'] ?? 20);
    }

    /**
     * Получить активность по сущности
     */
    public function getEntityActivity(string $type, int $entityId)
    {
        return Activity::where('activityable_type', $type)
            ->where('activityable_id', $entityId)
            ->with('user')
            ->latest()
            ->paginate(20);
    }

    /**
     * Получить последнюю активность в системе
     */
    public function getRecentActivity(array $filters = [])
    {
        $query = Activity::with(['user', 'activityable'])
            ->latest();

        if (isset($filters['user_id'])) {
            $query->where('user_id', $filters['user_id']);
        }

        if (isset($filters['types'])) {
            $query->whereIn('type', $filters['types']);
        }

        return $query->paginate($filters['per_page'] ?? 30);
    }

    /**
     * Создать запись активности
     */
    public function logActivity(User $user, string $type, string $description, ?Model $model = null): Activity
    {
        return Activity::log($user, $type, $description, $model);
    }

    /**
     * Статистика активности
     */
    public function getActivityStats(): array
    {
        $today = now()->startOfDay();
        $weekAgo = now()->subDays(7)->startOfDay();

        return [
            'today' => Activity::where('created_at', '>=', $today)->count(),
            'last_7_days' => Activity::where('created_at', '>=', $weekAgo)->count(),
            'by_type' => Activity::selectRaw('type, count(*) as count')
                ->where('created_at', '>=', $weekAgo)
                ->groupBy('type')
                ->orderBy('count', 'desc')
                ->get()
                ->toArray(),
            'most_active_users' => Activity::selectRaw('user_id, count(*) as activity_count')
                ->with('user')
                ->where('created_at', '>=', $weekAgo)
                ->groupBy('user_id')
                ->orderBy('activity_count', 'desc')
                ->limit(5)
                ->get()
        ];
    }
}