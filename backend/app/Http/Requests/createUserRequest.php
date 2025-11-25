<?php namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class createUserRequest extends FormRequest {
    public function authorize(): bool {
        return true;
    }
    /** * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string> */
    public function rules(): array {
        return [
            'name'              =>  'required|string|max:255',
            'surname'           =>  'required|string|max:255',
            'email'             =>  'required|email|unique:users,email',
            'phone'             =>  'required|string|max:25',
            'password'          =>  'required|string|min:8|confirmed',
        ];
    }
}
