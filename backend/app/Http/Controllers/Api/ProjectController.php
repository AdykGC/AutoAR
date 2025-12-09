<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Project\CreateProjectRequest;
use App\Http\Requests\Project\UpdateProjectRequest;
use App\Services\ProjectService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProjectController extends BaseController
{
    protected $projectService;

    public function __construct(ProjectService $projectService)
    {
        $this->projectService = $projectService;
        $this->middleware('auth:sanctum');
        $this->middleware('role:Manager|Admin|Owner|CEO')->except(['myProjects', 'show']);
    }

    /**
     * Список проектов для менеджера
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $projects = $this->projectService->getAllProjects($request->all());
            return $this->success($projects);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Мои проекты (где я менеджер)
     */
    public function myProjects(): JsonResponse
    {
        try {
            $projects = $this->projectService->getManagerProjects(auth()->id());
            return $this->success($projects);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Создать проект для задачи (менеджер)
     */
    public function store(CreateProjectRequest $request): JsonResponse
    {
        try {
            $data = $request->validated();
            $data['manager_id'] = auth()->id();
            
            $project = $this->projectService->createProject($data);
            return $this->success($project, 'Проект создан', 201);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Просмотр проекта
     */
    public function show($id): JsonResponse
    {
        try {
            $project = $this->projectService->getProjectWithDetails($id);
            
            if (!$project) {
                return $this->error('Проект не найден', 404);
            }

            // Проверка доступа
            $user = auth()->user();
            if ($project->manager_id !== $user->id && 
                !$project->team->hasMember($user) && 
                $project->clientTask->client_id !== $user->id &&
                !$user->hasRole('Admin')) {
                return $this->error('Доступ запрещен', 403);
            }

            return $this->success($project);
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Обновить проект
     */
    public function update(UpdateProjectRequest $request, $id): JsonResponse
    {
        try {
            $project = $this->projectService->findProject($id);
            
            if (!$project) {
                return $this->error('Проект не найден', 404);
            }

            if ($project->manager_id !== auth()->id()) {
                return $this->error('Вы не менеджер этого проекта', 403);
            }

            $updatedProject = $this->projectService->updateProject($project, $request->validated());
            return $this->success($updatedProject, 'Проект обновлен');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Запустить проект (начать работу)
     */
    public function start($id): JsonResponse
    {
        try {
            $project = $this->projectService->findProject($id);
            
            if (!$project) {
                return $this->error('Проект не найден', 404);
            }

            if ($project->manager_id !== auth()->id()) {
                return $this->error('Вы не менеджер этого проекта', 403);
            }

            $this->projectService->startProject($project);
            return $this->success(null, 'Проект запущен');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Завершить проект
     */
    public function complete($id): JsonResponse
    {
        try {
            $project = $this->projectService->findProject($id);
            
            if (!$project) {
                return $this->error('Проект не найден', 404);
            }

            if ($project->manager_id !== auth()->id()) {
                return $this->error('Вы не менеджер этого проекта', 403);
            }

            $this->projectService->completeProject($project);
            return $this->success(null, 'Проект завершен');
        } catch (\Exception $e) {
            return $this->error($e->getMessage(), 500);
        }
    }
}