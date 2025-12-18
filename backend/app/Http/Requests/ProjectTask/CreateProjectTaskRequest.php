<?php

namespace App\Http\Requests\ProjectTask;

use Illuminate\Foundation\Http\FormRequest;
use App\Models\Project;

class CreateProjectTaskRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Только менеджеры проекта могут создавать подзадачи
        if (!auth()->user()->hasRole('Manager')) {
            return false;
        }

        $project = Project::find($this->input('project_id'));
        
        return $project && $project->manager_id === auth()->id();
    }

    public function rules(): array
    {
        return [
            'project_id' => ['required', 'exists:projects,id'],
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string', 'min:10'],
            'assignee_id' => ['nullable', 'exists:users,id'],
            'estimated_hours' => ['required', 'integer', 'min:1', 'max:240'], // до 30 дней
            'due_date' => ['required', 'date', 'after:today'],
            'priority' => ['sometimes', 'integer', 'min:1', 'max:10']
        ];
    }

    public function messages(): array
    {
        return [
            'project_id.exists' => 'Проект не найден',
            'estimated_hours.max' => 'Оценка не может превышать 240 часов',
            'due_date.after' => 'Срок выполнения должен быть в будущем'
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $project = Project::find($this->input('project_id'));
            
            if ($project && $project->status === 'completed') {
                $validator->errors()->add(
                    'project', 
                    'Нельзя добавлять задачи в завершенный проект'
                );
            }
        });
    }
}