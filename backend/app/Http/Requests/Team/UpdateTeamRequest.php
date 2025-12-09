<?php

namespace App\Http\Requests\Team;

use Illuminate\Foundation\Http\FormRequest;
use App\Models\Team;

class UpdateTeamRequest extends FormRequest
{
    public function authorize(): bool
    {
        $team = Team::find($this->route('id'));
        
        // Только лидер команды или админ может редактировать
        return $team && (
            $team->leader_id === auth()->id() || 
            auth()->user()->hasRole('Admin') || 
            auth()->user()->hasRole('Owner')
        );
    }

    public function rules(): array
    {
        $teamId = $this->route('id');

        return [
            'name' => ['sometimes', 'string', 'max:255', "unique:teams,name,{$teamId}"],
            'description' => ['sometimes', 'string', 'min:10'],
            'department' => ['sometimes', 'nullable', 'string', 'max:100'],
            'leader_id' => ['sometimes', 'exists:users,id']
        ];
    }
}