<?php namespace App\Http\Controllers\Product;

use App\Http\Controllers\Product\BaseController;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Machine;
use Illuminate\Support\Facades\Auth;

class MachineController extends BaseController{

    // Список аппаратов текущего пользователя
    public function index()
    {
        $machines = Machine::where('user_id', Auth::id())->get();
        return response()->json($machines);
    }

    // Получение одного аппарата
    public function show($id)
    {
        $machine = Machine::where('user_id', Auth::id())->findOrFail($id);
        return response()->json($machine);
    }




    // Удаление аппарата
    public function destroy($id)
    {
        $machine = Machine::where('user_id', Auth::id())->findOrFail($id);
        $machine->delete();

        return response()->json(['message' => 'Machine deleted successfully']);
    }
}
