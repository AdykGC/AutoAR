<?php

namespace App\Http\Requests\Team;

use Illuminate\Foundation\Http\FormRequest;

class CreateTeamRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Только менеджеры и выше могут создавать команды
        return auth()->user()->hasRole('Manager') || 
               auth()->user()->hasRole('Admin') || 
               auth()->user()->hasRole('Owner') || 
               auth()->user()->hasRole('CEO');
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255', 'unique:teams,name'],
            'description' => ['required', 'string', 'min:10'],
            'department' => ['nullable', 'string', 'max:100'],
            
            // Начальные участники команды
            'members' => ['sometimes', 'array'],
            'members.*.user_id' => ['exists:users,id'],
            'members.*.role' => ['in:member,senior,lead']
        ];
    }

    public function messages(): array
    {
        return [
            'name.unique' => 'Команда с таким названием уже существует',
            'members.*.user_id.exists' => 'Пользователь не найден',
            'members.*.role.in' => 'Роль должна быть: member, senior или lead'
        ];
    }
}