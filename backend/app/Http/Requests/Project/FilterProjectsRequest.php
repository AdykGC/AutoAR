<?php

namespace App\Http\Requests\Project;

use Illuminate\Foundation\Http\FormRequest;

class FilterProjectsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        return [
            'status' => ['sometimes', 'in:planning,active,on_hold,completed,cancelled'],
            'team_id' => ['sometimes', 'exists:teams,id'],
            'client_id' => ['sometimes', 'exists:users,id'],
            'date_from' => ['sometimes', 'date'],
            'date_to' => ['sometimes', 'date', 'after_or_equal:date_from'],
            'search' => ['sometimes', 'string', 'max:100']
        ];
    }
}