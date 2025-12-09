<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Comment extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'commentable_type',
        'commentable_id',
        'content',
        'parent_id'
    ];

    // ========== ОТНОШЕНИЯ ==========
    
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function commentable()
    {
        return $this->morphTo();
    }

    public function parent()
    {
        return $this->belongsTo(Comment::class, 'parent_id');
    }

    public function replies()
    {
        return $this->hasMany(Comment::class, 'parent_id');
    }

    // ========== МЕТОДЫ ==========
    
    // Проверить является ли комментарий ответом
    public function isReply()
    {
        return !is_null($this->parent_id);
    }

    // Получить все ответы с пользователями
    public function getRepliesWithUsers()
    {
        return $this->replies()->with('user')->get();
    }
}