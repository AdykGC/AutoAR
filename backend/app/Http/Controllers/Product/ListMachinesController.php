<?php namespace App\Http\Controllers\Product;

use App\Models\Machine;
use App\Http\Controllers\Product\BaseController;

use Illuminate\Support\Facades\Auth;

class ListMachinesController extends BaseController {
    public function __invoke() {
        $machines = Machine::where('user_id', Auth::id())->get();
        return response()->json($machines);
    }
}