<?php

namespace App\Http\Requests\ClientTask;

use Illuminate\Foundation\Http\FormRequest;

class CreateClientTaskRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Только клиенты могут создавать задачи
        return auth()->check() && (auth()->user()->hasRole('Client') || auth()->user()->hasRole('Client VIP'));
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string', 'min:10'],
            'budget' => ['nullable', 'numeric', 'min:0'],
            'deadline' => ['nullable', 'date', 'after:today'],
            
            // Для VIP клиентов могут быть дополнительные поля
            'priority' => ['sometimes', 'in:low,medium,high'],
            'attachments' => ['sometimes', 'array'],
            'attachments.*' => ['file', 'max:10240'] // 10MB
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => 'Название задачи обязательно',
            'description.min' => 'Описание должно быть не менее 10 символов',
            'budget.min' => 'Бюджет не может быть отрицательным',
            'deadline.after' => 'Дедлайн должен быть в будущем'
        ];
    }
}