<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Attachment extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'attachable_type',
        'attachable_id',
        'filename',
        'path',
        'mime_type',
        'size'
    ];

    protected $casts = [
        'size' => 'integer'
    ];

    // ========== ОТНОШЕНИЯ ==========
    
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function attachable()
    {
        return $this->morphTo();
    }

    // ========== МЕТОДЫ ==========
    
    // Получить URL файла
    public function getUrlAttribute()
    {
        return asset('storage/' . $this->path);
    }

    // Проверить является ли файл изображением
    public function isImage()
    {
        return str_starts_with($this->mime_type, 'image/');
    }

    // Проверить является ли файлом PDF
    public function isPdf()
    {
        return $this->mime_type === 'application/pdf';
    }
}