<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Activity extends Model
{
    protected $fillable = [
        'user_id',
        'activityable_type',
        'activityable_id',
        'type',
        'description',
        'metadata'
    ];

    protected $casts = [
        'metadata' => 'array'
    ];

    // Полиморфная связь - активность может быть у:
    // Goal, Task, Project, User, etc
    public function activityable()
    {
        return $this->morphTo();
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Типы активностей
    public static $types = [
        'goal_created',
        'goal_updated',
        'goal_completed',
        'task_created',
        'task_assigned',
        'task_completed',
        'project_created',
        'project_updated',
        'comment_added',
        'file_uploaded',
        'status_changed',
        'progress_updated'
    ];

    // Создать активность автоматически
    public static function log($user, $type, $description, $model = null)
    {
        return self::create([
            'user_id' => $user->id,
            'type' => $type,
            'description' => $description,
            'activityable_type' => $model ? get_class($model) : null,
            'activityable_id' => $model?->id,
            'metadata' => [
                'user_name' => $user->name,
                'user_role' => $user->getRoleNames()->first(),
                'timestamp' => now()->toISOString()
            ]
        ]);
    }
}