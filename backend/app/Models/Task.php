<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Task extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'title',
        'description',
        'project_id',
        'goal_id',
        'assignee_id',
        'creator_id',
        'estimated_hours',
        'actual_hours',
        'priority',
        'status',
        'due_date',
        'completed_at',
        'checklist',
        'attachments',
        'metadata'
    ];

    protected $casts = [
        'checklist' => 'array',
        'attachments' => 'array',
        'metadata' => 'array',
        'due_date' => 'date',
        'completed_at' => 'datetime',
        'estimated_hours' => 'integer',
        'actual_hours' => 'integer'
    ];

    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function goal()
    {
        return $this->belongsTo(Goal::class);
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

    // Прогресс задачи (0-100%)
    public function getProgressAttribute()
    {
        if ($this->status === 'completed') return 100;
        
        $checklist = $this->checklist ?? [];
        if (empty($checklist)) {
            return match($this->status) {
                'in_progress' => 50,
                'review' => 80,
                default => 0
            };
        }
        
        $completed = count(array_filter($checklist, fn($item) => $item['completed'] ?? false));
        $total = count($checklist);
        
        return $total > 0 ? ($completed / $total) * 100 : 0;
    }
}