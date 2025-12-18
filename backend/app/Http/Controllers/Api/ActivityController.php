<?php

namespace App\Http\Controllers\Api;

use App\Services\ActivityService;
use Illuminate\Http\Request;

class ActivityController extends BaseController
{
    protected $activityService;

    public function __construct(ActivityService $activityService)
    {
        $this->activityService = $activityService;
        $this->middleware('auth:sanctum');
    }

    public function myActivity(Request $request)
    {
        $activities = $this->activityService->getUserActivity(
            auth()->id(), 
            $request->all()
        );
        return $this->success($activities);
    }

    public function recent()
    {
        $activities = $this->activityService->getRecentActivity([
            'per_page' => 20
        ]);
        return $this->success($activities);
    }

    public function stats()
    {
        $stats = $this->activityService->getActivityStats();
        return $this->success($stats);
    }
}