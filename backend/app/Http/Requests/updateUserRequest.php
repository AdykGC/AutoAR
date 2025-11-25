<?php namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class updateUserRequest extends FormRequest {
    public function authorize(): bool {
        return true;
    }
    /** * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string> */
    public function rules(): array {
        return [
            'name'              =>  'sometimes|string|max:255',
            'surname'           =>  'sometimes|string|max:255',
            'phone'             =>  'sometimes|string|max:25',
        ];
    }
}
