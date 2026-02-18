<?php namespace App\Http\Requests\User;

use Illuminate\Foundation\Http\FormRequest;

class registerUserRequest extends FormRequest {
    public function authorize(): bool {
        return true;
    }
    /** * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string> */
    public function rules(): array {
        return [
            // 'name'              =>  'sometimes|string|max:50',
            // 'surname'           =>  'sometimes|string|max:50',
            'email'             =>  'required|email|unique:users,email',
            'password'          =>  'required|string|min:8|confirmed',
        ];
    }
}
