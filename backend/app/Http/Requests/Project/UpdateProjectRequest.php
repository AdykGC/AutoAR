<?php

namespace App\Http\Requests\Project;

use Illuminate\Foundation\Http\FormRequest;
use App\Models\Project;

class UpdateProjectRequest extends FormRequest
{
    public function authorize(): bool
    {
        $project = Project::find($this->route('id'));
        
        // Только менеджер проекта может его редактировать
        return $project && $project->manager_id === auth()->id();
    }

    public function rules(): array
    {
        $projectId = $this->route('id');

        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'description' => ['sometimes', 'string', 'min:10'],
            'team_id' => ['sometimes', 'exists:teams,id'],
            'status' => ['sometimes', 'in:planning,active,on_hold,completed,cancelled'],
            'start_date' => ['sometimes', 'date'],
            'deadline' => ['sometimes', 'date', 'after:start_date']
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $project = Project::find($this->route('id'));
            
            if ($project && $project->status === 'completed') {
                $validator->errors()->add(
                    'status', 
                    'Нельзя редактировать завершенный проект'
                );
            }
        });
    }
}