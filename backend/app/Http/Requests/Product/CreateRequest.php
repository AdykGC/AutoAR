<?php namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class CreateRequest extends FormRequest {
    public function authorize(): bool {
        return true;
    }
    /** * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string> */
    public function rules(): array {
        return [
            'name' => 'required|string|max:255',
            'machine_number' => 'required|string|unique:machines',
            'location' => 'nullable|string',
            'status' => 'in:active,inactive,maintenance',
            'last_service' => 'nullable|date',
            'type' => 'nullable|string',
            'capacity' => 'nullable|integer',
            'current_balance' => 'nullable|numeric',
            'connectivity_status' => 'in:online,offline',
            'maintenance_notes' => 'nullable|string',
        ];
    }
}
