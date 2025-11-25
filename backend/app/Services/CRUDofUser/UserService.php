<?php namespace App\Services\CRUDofUser;

use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;
use Illuminate\Support\Collection;
use Illuminate\Database\Seeder\RoleSeeder;

use App\Models\{
    User,
    Courses,
};

use Spatie\Permission\Models\Permission;

class UserService {
    public function create($request){
        $data = User::create([
            'name'               => $request->name,
            'surname'            => $request->surname,
            'email'              => $request->email,
            'phone'              => $request->phone,
            'password'           => Hash::make($request->password),
        ]);

        return response()->json([
            'message' => 'Пользователь успешно зарегистрирован',
            'user' => $data 
        ]);
    }
    public function read($request){
        $data = User::where('email', $request->email)->first();
        if (!$data || !Hash::check($request->password, $data->password)) {
            return response()->json([
                'status' => 'auth_error',
                'message' => 'Неверное имя пользователя или пароль.',
            ], 401);
        }
        $token = $data->createToken('Token');
        $token->accessToken->expires_at = now()->addDays(7);
        $token->accessToken->save();
        return response()->json([ 
            'message' => 'Вход выполнен успешно',
            'token' => $token->plainTextToken,
            'user' => [
                'id' => $data->id,
                'name' => $data->name,
                'surname' => $data->surname,
                'email' => $data->email,
            ],
        ]);
    }
    public function update(){}
    public function delete(){}
}