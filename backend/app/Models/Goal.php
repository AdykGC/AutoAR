<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Goal extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'title',
        'description', 
        'type',
        'user_id',
        'assigned_by',
        'target_value',
        'current_value',
        'unit',
        'start_date',
        'end_date',
        'status',
        'priority',
        'metadata',
        'attachments',
        'project_id',
        'team_id'
    ];

    protected $casts = [
        'metadata' => 'array',
        'attachments' => 'array',
        'target_value' => 'decimal:2',
        'current_value' => 'decimal:2',
        'start_date' => 'date',
        'end_date' => 'date'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function assignedBy()
    {
        return $this->belongsTo(User::class, 'assigned_by');
    }

    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function team()
    {
        return $this->belongsTo(Team::class);
    }

    public function tasks()
    {
        return $this->hasMany(Task::class);
    }

    public function activities()
    {
        return $this->morphMany(Activity::class, 'activityable');
    }
}