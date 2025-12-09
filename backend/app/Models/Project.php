<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Project extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'description',
        'client_task_id',
        'manager_id',
        'team_id',
        'status',
        'start_date',
        'deadline'
    ];

    protected $casts = [
        'start_date' => 'date',
        'deadline' => 'date'
    ];

    // ========== ОТНОШЕНИЯ ==========
    
    public function clientTask()
    {
        return $this->belongsTo(ClientTask::class);
    }

    public function manager()
    {
        return $this->belongsTo(User::class, 'manager_id');
    }

    public function team()
    {
        return $this->belongsTo(Team::class);
    }

    public function projectTasks()
    {
        return $this->hasMany(ProjectTask::class);
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
    
    // Запустить проект
    public function start()
    {
        $this->update([
            'status' => 'active',
            'start_date' => now()
        ]);
    }

    // Завершить проект
    public function complete()
    {
        $this->update([
            'status' => 'completed'
        ]);

        // Обновляем прогресс родительской задачи
        if ($this->clientTask) {
            $this->clientTask->updateProgress();
        }
    }

    // Получить прогресс проекта
    public function getProgressAttribute()
    {
        $totalTasks = $this->projectTasks()->count();
        if ($totalTasks === 0) {
            return 0;
        }

        $completedTasks = $this->projectTasks()
                              ->where('status', 'completed')
                              ->count();

        return (int) (($completedTasks / $totalTasks) * 100);
    }

    // Создать стандартные подзадачи
    public function createDefaultTasks()
    {
        $defaultTasks = [
            ['title' => 'Анализ требований', 'estimated_hours' => 8],
            ['title' => 'Планирование', 'estimated_hours' => 16],
            ['title' => 'Разработка', 'estimated_hours' => 40],
            ['title' => 'Тестирование', 'estimated_hours' => 16],
            ['title' => 'Сдача проекта', 'estimated_hours' => 4],
        ];

        foreach ($defaultTasks as $taskData) {
            $this->projectTasks()->create(array_merge($taskData, [
                'creator_id' => $this->manager_id,
                'status' => 'todo',
                'due_date' => $this->deadline,
                'priority' => count($this->projectTasks) + 1
            ]));
        }
    }
}