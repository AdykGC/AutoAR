<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Machine extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'machine_number',
        'location',
        'status',
        'last_service',
        'type',
        'capacity',
        'current_balance',
        'connectivity_status',
        'maintenance_notes',
        'user_id',
    ];

    // Связь с пользователем
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
