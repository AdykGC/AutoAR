<?php namespace App\Http\Controllers\Product;

use App\Models\Machine;
use App\Http\Controllers\Product\BaseController;

use Illuminate\Support\Facades\Auth;

class ShowMachinesController extends BaseController {
    public function __invoke($id) {
        $machine = Machine::where('user_id', Auth::id())->findOrFail($id);
        return response()->json($machine);
    }
}