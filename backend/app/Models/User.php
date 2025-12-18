<?php namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
// Backpack
use Backpack\CRUD\app\Models\Traits\CrudTrait;
// Spatie
use Spatie\Permission\Traits\HasRoles;
// Sanctum
use Laravel\Sanctum\HasApiTokens;
// Мягкое удаление
use Illuminate\Database\Eloquent\SoftDeletes;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable, HasRoles, SoftDeletes;

    protected $fillable = [
        'name',
        'surname',
        'email',
        'phone',
        'password',
        'is_active'
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'is_active' => 'boolean'
    ];

    // ========== ОТНОШЕНИЯ ==========
    
    // Задачи, которые создал клиент
    public function clientTasks()
    {
        return $this->hasMany(ClientTask::class, 'client_id');
    }

    // Проекты, которыми управляет менеджер
    public function managedProjects()
    {
        return $this->hasMany(Project::class, 'manager_id');
    }

    // Задачи, назначенные на сотрудника
    public function assignedTasks()
    {
        return $this->hasMany(ProjectTask::class, 'assignee_id');
    }

    // Команды, где пользователь лидер
    public function ledTeams()
    {
        return $this->hasMany(Team::class, 'leader_id');
    }

    // Команды, где пользователь участник
    public function teams()
    {
        return $this->belongsToMany(Team::class, 'team_members')
                    ->withPivot('role')
                    ->withTimestamps();
    }

    // Активности пользователя
    public function activities()
    {
        return $this->hasMany(Activity::class);
    }

    // Комментарии пользователя
    public function comments()
    {
        return $this->hasMany(Comment::class);
    }

    // Файлы пользователя
    public function attachments()
    {
        return $this->hasMany(Attachment::class);
    }

    // ========== МЕТОДЫ ПО РОЛЯМ ==========
    
    public function isClient()
    {
        return $this->hasRole('Client') || $this->hasRole('Client VIP');
    }

    public function isManager()
    {
        return $this->hasAnyRole(['Manager', 'Admin', 'Owner', 'Ceo']);
    }

    public function isEmployee()
    {
        return $this->hasAnyRole(['Employee', 'Slave', 'Seller', 'Counter', 'Lawyer', 'HR']);
    }

    // Получить задачи клиента с прогрессом
    public function getClientTasksWithProgress()
    {
        return $this->clientTasks()
                   ->with(['project.projectTasks'])
                   ->get()
                   ->map(function ($task) {
                       $task->progress_calculated = $task->calculateProgress();
                       return $task;
                   });
    }
}
