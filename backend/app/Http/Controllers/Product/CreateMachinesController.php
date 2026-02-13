<?php namespace App\Http\Controllers\Product;

use App\Models\Machine;
use App\Http\Controllers\Product\BaseController;
use App\Http\Requests\Product\CreateRequest;

use Illuminate\Support\Facades\Auth;

class CreateMachinesController extends BaseController{

    // Список аппаратов текущего пользователя
    public function __invoke(CreateRequest $request) {
        $data = $request->validated();
        $data['user_id'] = Auth::id();
        $machine = Machine::create($data);
        return response()->json($machine, 201);
    }
}