<?php namespace App\Http\Controllers\Product;

use App\Models\Machine;
use App\Http\Controllers\Product\BaseController;
use App\Http\Requests\Product\UpdateRequest;

use Illuminate\Support\Facades\Auth;

class UpdateMachinesController extends BaseController{

    // Список аппаратов текущего пользователя
    public function __invoke(UpdateRequest $request, $id) {
        $machine = Machine::where('user_id', Auth::id())->findOrFail($id); // защита от чужих аппаратов
        $data = $request->validated();
        $machine->update($data);
        return response()->json($machine);
    }
}