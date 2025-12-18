<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Team extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'description',
        'leader_id',
        'department'
    ];

    // ========== ОТНОШЕНИЯ ==========
    
    public function leader()
    {
        return $this->belongsTo(User::class, 'leader_id');
    }

    public function members()
    {
        return $this->belongsToMany(User::class, 'team_members')
                    ->withPivot('role')
                    ->withTimestamps();
    }

    public function projects()
    {
        return $this->hasMany(Project::class);
    }

    // ========== МЕТОДЫ ==========
    
    // Добавить участника
    public function addMember(User $user, $role = 'member')
    {
        if (!$this->members()->where('user_id', $user->id)->exists()) {
            $this->members()->attach($user->id, ['role' => $role]);
        }
    }

    // Удалить участника
    public function removeMember(User $user)
    {
        $this->members()->detach($user->id);
    }

    // Получить всех активных участников
    public function getActiveMembers()
    {
        return $this->members()
                   ->where('is_active', true)
                   ->get();
    }

    // Проверить является ли пользователь участником
    public function hasMember(User $user)
    {
        return $this->members()->where('user_id', $user->id)->exists();
    }
}