<?php

namespace App\Http\Requests\ProjectTask;

use Illuminate\Foundation\Http\FormRequest;
use App\Models\ProjectTask;

class AssignTaskRequest extends FormRequest
{
    public function authorize(): bool
    {
        $task = ProjectTask::find($this->route('id'));
        
        if (!$task) {
            return false;
        }

        // Только менеджер проекта может назначать задачи
        return auth()->user()->id === $task->project->manager_id;
    }

    public function rules(): array
    {
        return [
            'assignee_id' => ['required', 'exists:users,id']
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $task = ProjectTask::find($this->route('id'));
            
            if ($task && $task->status === 'completed') {
                $validator->errors()->add(
                    'task', 
                    'Нельзя назначать исполнителя на завершенную задачу'
                );
            }
        });
    }
}