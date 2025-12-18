<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Activity extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'activityable_type',
        'activityable_id',
        'type',
        'description',
        'old_values',
        'new_values'
    ];

    protected $casts = [
        'old_values' => 'array',
        'new_values' => 'array'
    ];

    // ========== ОТНОШЕНИЯ ==========
    
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function activityable()
    {
        return $this->morphTo();
    }

    // ========== СТАТИЧЕСКИЕ МЕТОДЫ ==========
    
    // Создать запись активности (ИСПРАВЛЕННЫЙ МЕТОД)
    public static function log($user, $type, $description, $model = null, $oldValues = null, $newValues = null)
    {
        $data = [
            'user_id' => $user->id,
            'type' => $type,
            'description' => $description,
        ];

        // Добавляем morph поля только если модель передана
        if ($model) {
            $data['activityable_type'] = get_class($model);
            $data['activityable_id'] = $model->id;
        }

        // Добавляем старые и новые значения
        if ($oldValues !== null) {
            $data['old_values'] = is_array($oldValues) ? $oldValues : [$oldValues];
        }

        if ($newValues !== null) {
            $data['new_values'] = is_array($newValues) ? $newValues : [$newValues];
        }

        return self::create($data);
    }

    // Получить активности для сущности
    public static function forModel($model, $limit = 20)
    {
        return self::where('activityable_type', get_class($model))
                  ->where('activityable_id', $model->id)
                  ->with('user')
                  ->latest()
                  ->limit($limit)
                  ->get();
    }

    // Получить системные активности (без привязки к модели)
    public static function getSystemActivities($limit = 50)
    {
        return self::whereNull('activityable_type')
                  ->orWhereNull('activityable_id')
                  ->with('user')
                  ->latest()
                  ->limit($limit)
                  ->get();
    }
}