<?php namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class UpdateRequest extends FormRequest {
    public function authorize(): bool {
        return true;
    }
    /** * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string> */
    public function rules(): array {
        $machineId = $this->route('id'); // получаем id из URL

        return [
            'name' => 'sometimes|string|max:255',
            'machine_number' => 'sometimes|string|unique:machines,machine_number,' . $machineId . ',id',
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
