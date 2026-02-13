<?php namespace App\Http\Controllers\Product;

use App\Models\Machine;
use App\Http\Controllers\Product\BaseController;

use Illuminate\Support\Facades\Auth;

class DeleteMachinesController extends BaseController {
    public function __invoke($id) {
        $machine = Machine::where('user_id', Auth::id())->findOrFail($id);
        $machine->delete();
        return response()->json([
            'message' => 'Machine deleted successfully'
        ]);
    }
}