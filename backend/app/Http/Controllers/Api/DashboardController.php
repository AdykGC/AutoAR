<?php

namespace App\Http\Controllers\Api;

use App\Services\DashboardService;
use Illuminate\Http\JsonResponse;

class DashboardController extends BaseController
{
    protected $dashboardService;

    public function __construct(DashboardService $dashboardService)
    {
        $this->dashboardService = $dashboardService;
        $this->middleware('auth:sanctum');
    }

    /**
     * Дашборд клиента
     */
    public function clientDashboard(): JsonResponse
    {
        try {
            $stats = $this->dashboardService->getClientStats(auth()->id());
            return $this->success($stats);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Дашборд менеджера
     */
    public function managerDashboard(): JsonResponse
    {
        try {
            $stats = $this->dashboardService->getManagerStats(auth()->id());
            return $this->success($stats);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Дашборд сотрудника
     */
    public function employeeDashboard(): JsonResponse
    {
        try {
            $stats = $this->dashboardService->getEmployeeStats(auth()->id());
            return $this->success($stats);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }
}