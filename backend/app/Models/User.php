<?php namespace App\Models;


// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
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
    use CrudTrait;
    use HasApiTokens, HasFactory, Notifiable; 
    use HasRoles;
    use SoftDeletes;

    protected $fillable = [
        'role',
        'name',
        'surname',
        'email',
        'phone',
        'password',
    ];
    protected $hidden = [
        'password',
        'remember_token',
    ];
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];
        protected $dates = ['deleted_at'];
}
