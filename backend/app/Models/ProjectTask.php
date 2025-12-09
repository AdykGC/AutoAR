<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ProjectTask extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
        'description',
        'project_id',
        'assignee_id',
        'creator_id',
        'status',
        'estimated_hours',
        'actual_hours',
        'due_date',
        'completed_at',
        'priority'
    ];

    protected $casts = [
        'due_date' => 'date',
        'completed_at' => 'datetime',
        'estimated_hours' => 'integer',
        'actual_hours' => 'integer',
        'priority' => 'integer'
    ];

    // ========== ОТНОШЕНИЯ ==========
    
    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function assignee()
    {
        return $this->belongsTo(User::class, 'assignee_id');
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'creator_id');
    }

    public function activities()
    {
        return $this->morphMany(Activity::class, 'activityable');
    }

    public function comments()
    {
        return $this->morphMany(Comment::class, 'commentable');
    }

    public function attachments()
    {
        return $this->morphMany(Attachment::class, 'attachable');
    }

    // ========== МЕТОДЫ ==========
    
    // Назначить исполнителя
    public function assignTo(User $user)
    {
        $this->update([
            'assignee_id' => $user->id,
            'status' => 'in_progress'
        ]);

        Activity::create([
            'user_id' => auth()->id(),
            'activityable_type' => self::class,
            'activityable_id' => $this->id,
            'type' => 'assigned',
            'description' => "Задача назначена {$user->name}"
        ]);
    }

    // Отметить как выполненную
    public function markAsCompleted()
    {
        $this->update([
            'status' => 'completed',
            'completed_at' => now(),
            'actual_hours' => $this->actual_hours ?: $this->estimated_hours
        ]);

        // Обновляем прогресс проекта
        $this->project->clientTask?->updateProgress();

        Activity::create([
            'user_id' => auth()->id(),
            'activityable_type' => self::class,
            'activityable_id' => $this->id,
            'type' => 'completed',
            'description' => "Задача выполнена"
        ]);
    }

    // Обновить затраченное время
    public function updateTimeSpent($hours)
    {
        $this->update(['actual_hours' => $hours]);
    }

    // Проверить просрочена ли задача
    public function isOverdue()
    {
        return $this->due_date && $this->due_date->isPast() && $this->status !== 'completed';
    }
}