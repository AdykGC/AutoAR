<?php

namespace App\Http\Requests\ProjectTask;

use Illuminate\Foundation\Http\FormRequest;
use App\Models\ProjectTask;

class UpdateProjectTaskRequest extends FormRequest
{
    public function authorize(): bool
    {
        $task = ProjectTask::find($this->route('id'));
        
        if (!$task) {
            return false;
        }

        $user = auth()->user();
        
        // Доступ: исполнитель, создатель или менеджер проекта
        return $task->assignee_id === $user->id || 
               $task->creator_id === $user->id || 
               $task->project->manager_id === $user->id;
    }

    public function rules(): array
    {
        $taskId = $this->route('id');

        return [
            'title' => ['sometimes', 'string', 'max:255'],
            'description' => ['sometimes', 'string', 'min:10'],
            'status' => ['sometimes', 'in:todo,in_progress,review,completed,blocked'],
            'estimated_hours' => ['sometimes', 'integer', 'min:1'],
            'actual_hours' => ['sometimes', 'integer', 'min:0'],
            'due_date' => ['sometimes', 'date'],
            'priority' => ['sometimes', 'integer', 'min:1', 'max:10']
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $task = ProjectTask::find($this->route('id'));
            
            if ($task && $task->status === 'completed' && $this->has('status')) {
                if ($this->input('status') !== 'completed') {
                    $validator->errors()->add(
                        'status', 
                        'Нельзя изменить статус завершенной задачи'
                    );
                }
            }
        });
    }
}