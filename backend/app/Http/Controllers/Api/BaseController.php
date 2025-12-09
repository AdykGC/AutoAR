<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

class BaseController extends Controller
{
    /**
     * Успешный ответ
     */
    protected function success($data = null, string $message = '', int $code = 200): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], $code);
    }

    /**
     * Ошибка
     */
    protected function error(string $message = '', int $code = 400, $errors = null): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors' => $errors
        ], $code);
    }

    /**
     * Проверка прав доступа
     */
    protected function checkPermission($permission): bool
    {
        return auth()->user()->can($permission);
    }

    /**
     * Проверка роли
     */
    protected function hasRole($role): bool
    {
        return auth()->user()->hasRole($role);
    }
}