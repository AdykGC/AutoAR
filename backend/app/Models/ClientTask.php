<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ClientTask extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
        'description',
        'client_id',
        'status',
        'budget',
        'deadline',
        'manager_id',
        'assigned_at',
        'progress'
    ];

    protected $casts = [
        'budget' => 'decimal:2',
        'deadline' => 'date',
        'assigned_at' => 'datetime',
        'progress' => 'integer'
    ];

    // ========== ОТНОШЕНИЯ ==========
    
    public function client()
    {
        return $this->belongsTo(User::class, 'client_id');
    }

    public function manager()
    {
        return $this->belongsTo(User::class, 'manager_id');
    }

    public function project()
    {
        return $this->hasOne(Project::class, 'client_task_id');
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
    
    // Рассчитать прогресс на основе подзадач проекта
    public function calculateProgress()
    {
        if (!$this->project) {
            return 0;
        }

        $totalTasks = $this->project->projectTasks()->count();
        if ($totalTasks === 0) {
            return 0;
        }

        $completedTasks = $this->project->projectTasks()
                                       ->where('status', 'completed')
                                       ->count();

        return (int) (($completedTasks / $totalTasks) * 100);
    }

    // Автоматическое обновление прогресса
    public function updateProgress()
    {
        $this->progress = $this->calculateProgress();
        
        // Если прогресс 100% - завершаем задачу
        if ($this->progress === 100 && $this->status !== 'completed') {
            $this->status = 'completed';
        }
        
        $this->save();
    }

    // Назначить менеджера
    public function assignToManager(User $manager)
    {
        $this->update([
            'manager_id' => $manager->id,
            'assigned_at' => now(),
            'status' => 'approved'
        ]);

        // Создаем активность
        Activity::create([
            'user_id' => $manager->id,
            'activityable_type' => self::class,
            'activityable_id' => $this->id,
            'type' => 'assigned',
            'description' => "Задача назначена менеджеру {$manager->name}"
        ]);
    }

    // Проверить можно ли взять в работу
    public function canBeAssigned()
    {
        return $this->status === 'pending' && !$this->manager_id;
    }
}