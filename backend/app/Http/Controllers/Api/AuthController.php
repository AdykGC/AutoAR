<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;

class AuthController extends BaseController
{
    protected $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    /**
     * Регистрация с ролью
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        try {
            $user = $this->authService->register($request->validated());
            return $this->success($user, 'Регистрация успешна', 201);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 400);
        }
    }

    /**
     * Вход
     */
    public function login(LoginRequest $request): JsonResponse
    {
        try {
            $data = $this->authService->login($request->validated());
            return $this->success($data, 'Вход успешен');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 401);
        }
    }

    /**
     * Выход
     */
    public function logout(): JsonResponse
    {
        try {
            $this->authService->logout();
            return $this->success(null, 'Выход успешен');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Информация о текущем пользователе
     */
    public function me(): JsonResponse
    {
        return $this->success([
            'user' => auth()->user()->load('roles'),
            'permissions' => auth()->user()->getAllPermissions()->pluck('name')
        ]);
    }
}