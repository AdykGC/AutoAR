<?php

namespace App\Http\Requests\Comment;

use Illuminate\Foundation\Http\FormRequest;

class CommentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check(); // Любой авторизованный пользователь
    }

    public function rules(): array
    {
        return [
            'content' => ['required', 'string', 'min:1', 'max:2000'],
            'commentable_type' => ['required', 'in:App\Models\ClientTask,App\Models\Project,App\Models\ProjectTask'],
            'commentable_id' => ['required', 'integer'],
            'parent_id' => ['nullable', 'exists:comments,id']
        ];
    }

    public function messages(): array
    {
        return [
            'content.required' => 'Комментарий не может быть пустым',
            'content.max' => 'Комментарий не может превышать 2000 символов'
        ];
    }
}