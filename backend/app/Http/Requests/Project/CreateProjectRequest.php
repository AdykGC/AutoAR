<?php

namespace App\Http\Requests\Project;

use Illuminate\Foundation\Http\FormRequest;
use App\Models\ClientTask;

class CreateProjectRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Только менеджеры могут создавать проекты
        if (!auth()->user()->hasRole('Manager')) {
            return false;
        }

        $clientTask = ClientTask::find($this->input('client_task_id'));
        
        // Проверяем что задача существует и можно создать проект
        return $clientTask && $clientTask->status === 'approved';
    }

    public function rules(): array
    {
        return [
            'client_task_id' => ['required', 'exists:client_tasks,id'],
            'name' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string', 'min:10'],
            'team_id' => ['required', 'exists:teams,id'],
            'start_date' => ['required', 'date', 'after_or_equal:today'],
            'deadline' => ['required', 'date', 'after:start_date'],
            
            // Можно сразу создать стандартные подзадачи
            'create_default_tasks' => ['boolean']
        ];
    }

    public function messages(): array
    {
        return [
            'client_task_id.exists' => 'Задача клиента не найдена',
            'team_id.exists' => 'Команда не найдена',
            'deadline.after' => 'Дедлайн проекта должен быть после даты начала'
        ];
    }
}