<?php namespace App\Models;


// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Project extends Model
{
    protected $fillable = ['name', 'description', 'manager_id', 'client_id', 
                          'budget', 'spent', 'start_date', 'deadline', 
                          'priority', 'status', 'tags'];

    public function manager()
    {
        return $this->belongsTo(User::class, 'manager_id');
    }

    public function client()
    {
        return $this->belongsTo(User::class, 'client_id')->whereHas('roles', function($q) {
            $q->whereIn('name', ['Client', 'Client VIP']);
        });
    }

    public function tasks()
    {
        return $this->hasMany(Task::class);
    }

    public function team()
    {
        return $this->belongsTo(Team::class);
    }
}