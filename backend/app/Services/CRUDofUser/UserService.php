<?php namespace App\Services\CRUDofUser;

use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Spatie\Permission\Models\Role;
use Illuminate\Support\Collection;
use Illuminate\Database\Seeder\RoleSeeder;
use Spatie\Permission\Models\Permission;
use App\Models\{
    User,
};


class UserService {
    public function register($request){
        $data = User::create([
            'name'               => $request->name,
            'surname'            => $request->surname,
            'email'              => $request->email,
            'phone'              => $request->phone,
            'password'           => Hash::make($request->password),
        ]);
        $role = $request->role ?? 'Slave';
        $data->assignRole($role);
        $data->load('roles.permissions');

        return response()->json([
            'message' => 'Пользователь успешно зарегистрирован',
            'user' => $data,
            'role' => $role,
            'permissions' => $data->getAllPermissions()->pluck('name'),
            
        ]);
    }


    public function login($request){
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


    public function read($user) {
        return response()->json([
            'user' => $user,
            'roles' => $user->getRoleNames(),
            'permissions' => $user->getAllPermissions()->pluck('name'),
            'is_active' => $user->is_active,
            'deactivated_at' => $user->deactivated_at,
        ]);
    }


    public function update($request, $user){
        $validatedData = $request->validated();
        if (empty($validatedData)) {
            return response()->json([ 'message' => 'Нет данных для обновления.' ], 422);
        }

        // Обновляем роль если она передана
        if (isset($validatedData['role'])) {
            $user->syncRoles([$validatedData['role']]);
            unset($validatedData['role']);
        }
    
        // Обновляем остальные данные и загружаем свежие данные
        $user->update($validatedData);
        $user->load('roles');

        return response()->json([
            'message' => 'Профиль успешно обновлён',
            'user' => $user->makeHidden(['roles', 'permissions']),
            'role' => $user->getRoleNames()->first(),
            'permissions' => $user->getAllPermissions()->pluck('name')
        ]);
    }


    public function logout(){
        return response()->json([
            'status' => 'success',
            'message' => 'Вы вышли из системы',
        ]);
    }


    public function terminate($request, $userToTerminate) {
        $currentUser = auth()->user();
        // Дополнительные проверки
        if ($currentUser->id === $userToTerminate->id) {
            return response()->json([
                'message' => 'Нельзя уволить самого себя'
            ], 422);
        }
        if ($userToTerminate->hasRole('Owner')) {
            return response()->json([
                'message' => 'Нельзя уволить владельца компании'
            ], 422);
        }
        // Проверяем иерархию ролей (младшие роли не могут увольнять старших)
        $roleHierarchy = [
            'Owner' => 100,
            'Ceo' => 90,
            'Admin' => 80,
            'HR' => 70,
            'Manager' => 60,
            'Counter' => 50,
            'Lawyer' => 40,
            'Seller' => 30,
            'Slave' => 10,
        ];
        $currentUserRoleLevel = $roleHierarchy[$currentUser->getRoleNames()->first()] ?? 0;
        $targetUserRoleLevel = $roleHierarchy[$userToTerminate->getRoleNames()->first()] ?? 0;
        if ($currentUserRoleLevel <= $targetUserRoleLevel) {
            return response()->json([
                'message' => 'Недостаточно прав для увольнения этого сотрудника'
            ], 403);
        }
        // Получаем данные из запроса
        $validatedData = $request->validated();
        // 1. Удаляем все активные токены пользователя
        $userToTerminate->tokens()->delete();
        // 2. Деактивируем аккаунт (если есть поле is_active)
        if (Schema::hasColumn('users', 'is_active')) {
            $userToTerminate->update([
                'is_active' => false,
                'deactivated_at' => now(),
                'termination_reason' => $validatedData['reason'] ?? null,
                'termination_date' => $validatedData['termination_date'] ?? now(),
            ]);
        }
        // 3. Записываем в историю увольнений
        $this->createTerminationRecord($currentUser, $userToTerminate, $validatedData);
        // 4. Отправляем уведомление (если настроена почта)
        // $userToTerminate->notify(new UserTerminatedNotification($validatedData['reason'] ?? null));
        // 5. Возвращаем ответ
        return response()->json([
            'message' => 'Сотрудник успешно уволен',
            'user' => [
                'id' => $userToTerminate->id,
                'name' => $userToTerminate->name,
                'email' => $userToTerminate->email,
                'termination_date' => $validatedData['termination_date'] ?? now()->format('Y-m-d'),
                'terminated_by' => $currentUser->name,
            ],
            'details' => [
                'role_hierarchy_check' => "{$currentUser->getRoleNames()->first()} ({$currentUserRoleLevel}) > {$userToTerminate->getRoleNames()->first()} ({$targetUserRoleLevel})",
                'tokens_deleted' => true,
                'account_deactivated' => true,
            ]
        ]);
    }
    private function createTerminationRecord($terminator, $terminatedUser, $data) {
        // Создаем запись об увольнении (можно в отдельную таблицу)
        \App\Models\TerminationRecord::create([
            'user_id' => $terminatedUser->id,
            'terminated_by' => $terminator->id,
            'reason' => $data['reason'] ?? null,
            'termination_date' => $data['termination_date'] ?? now(),
            'final_salary_paid' => $data['final_salary_paid'] ?? false,
            'metadata' => [
                'user_role' => $terminatedUser->getRoleNames()->first(),
                'terminator_role' => $terminator->getRoleNames()->first(),
                'user_data' => $terminatedUser->only(['name', 'email', 'phone']),
            ]
        ]);
    }
}