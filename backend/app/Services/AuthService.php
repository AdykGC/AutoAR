<?php

namespace App\Services;

use App\Models\User;
use App\Models\Activity;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Spatie\Permission\Models\Role;

class AuthService
{
    /**
     * Регистрация пользователя с ролью
     */
    public function register(array $data): User
    {
        return DB::transaction(function () use ($data) {
            // Создаем пользователя
            $user = User::create([
                'name' => $data['name'],
                'surname' => $data['surname'] ?? null,
                'email' => $data['email'],
                'phone' => $data['phone'] ?? null,
                'password' => Hash::make($data['password']),
                'is_active' => true
            ]);

            // Назначаем роль
            $role = Role::where('name', $data['role'])->first();
            if ($role) {
                $user->assignRole($role);
            }

            // Логируем регистрацию (БЕЗ ПЕРЕДАЧИ МОДЕЛИ)
            Activity::log($user, 'registered', "Пользователь {$user->email} зарегистрирован");

            return $user;
        });
    }

    /**
     * Авторизация пользователя
     */
    public function login(array $credentials): array
    {
        $user = User::where('email', $credentials['email'])->first();

        if (!$user || !Hash::check($credentials['password'], $user->password)) {
            throw new \Exception('Неверный email или пароль');
        }

        if (!$user->is_active) {
            throw new \Exception('Аккаунт деактивирован');
        }

        // Создаем токен
        $token = $user->createToken('auth_token')->plainTextToken;

        // Логируем вход (БЕЗ ПЕРЕДАЧИ МОДЕЛИ)
        Activity::log($user, 'logged_in', 'Пользователь вошел в систему');

        return [
            'user' => $user->load('roles'),
            'token' => $token,
            'permissions' => $user->getAllPermissions()->pluck('name')
        ];
    }

    /**
     * Выход из системы
     */
    public function logout(): void
    {
        $user = auth()->user();
        
        if ($user) {
            $user->currentAccessToken()->delete();
            // Логируем выход (БЕЗ ПЕРЕДАЧИ МОДЕЛИ)
            Activity::log($user, 'logged_out', 'Пользователь вышел из системы');
        }
    }

    /**
     * Активация/деактивация пользователя
     */
    public function toggleUserStatus(int $userId, bool $status): User
    {
        $user = User::findOrFail($userId);
        $user->update(['is_active' => $status]);

        $action = $status ? 'активирован' : 'деактивирован';
        Activity::log(auth()->user(), 'user_status_changed', 
            "Пользователь {$user->email} {$action}");

        return $user;
    }
}