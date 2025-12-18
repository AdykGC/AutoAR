<?php

namespace App\Http\Requests\ClientTask;

use Illuminate\Foundation\Http\FormRequest;

class FilterTasksRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        return [
            'status' => ['sometimes', 'in:pending,approved,in_progress,completed,rejected,cancelled'],
            'priority' => ['sometimes', 'in:low,medium,high'],
            'date_from' => ['sometimes', 'date'],
            'date_to' => ['sometimes', 'date', 'after_or_equal:date_from'],
            'search' => ['sometimes', 'string', 'max:100'],
            'sort_by' => ['sometimes', 'in:created_at,deadline,priority,budget'],
            'sort_order' => ['sometimes', 'in:asc,desc']
        ];
    }
}