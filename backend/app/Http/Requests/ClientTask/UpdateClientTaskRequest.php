<?php

namespace App\Http\Requests\ClientTask;

use Illuminate\Foundation\Http\FormRequest;
use App\Models\ClientTask;

class UpdateClientTaskRequest extends FormRequest
{
    public function authorize(): bool
    {
        $clientTask = ClientTask::find($this->route('id'));
        
        // Только владелец задачи может её редактировать
        return $clientTask && $clientTask->client_id === auth()->id();
    }

    public function rules(): array
    {
        return [
            'title' => ['sometimes', 'string', 'max:255'],
            'description' => ['sometimes', 'string', 'min:10'],
            'budget' => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'deadline' => ['sometimes', 'nullable', 'date', 'after:today'],
            
            // Можно редактировать только поля, не связанные с выполнением
            'attachments' => ['sometimes', 'array'],
            'attachments.*' => ['file', 'max:10240']
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $clientTask = ClientTask::find($this->route('id'));
            
            if ($clientTask && $clientTask->status !== 'pending') {
                $validator->errors()->add(
                    'status', 
                    'Можно редактировать только задачи со статусом "На рассмотрении"'
                );
            }
        });
    }
}