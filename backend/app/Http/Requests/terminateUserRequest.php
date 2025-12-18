<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class terminateUserRequest extends FormRequest {
    public function authorize(): bool {
        // Проверяем права текущего пользователя
        return $this->user()->hasAnyRole(['Admin', 'HR', 'Owner', 'Ceo']);
    }
        /** * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string> */
    public function rules(): array {
        return [
            'reason' => 'sometimes|string|max:500',
            'termination_date' => 'sometimes|date',
            'final_salary_paid' => 'sometimes|boolean',
        ];
    }
    public function messages(): array {
        return [
            'reason.max' => 'Причина увольнения не должна превышать 500 символов',
            'termination_date.date' => 'Некорректная дата увольнения',
        ];
    }
}
