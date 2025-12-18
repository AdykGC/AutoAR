<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Comment\CommentRequest;
use App\Services\CommentService;

class CommentController extends BaseController
{
    protected $commentService;

    public function __construct(CommentService $commentService)
    {
        $this->commentService = $commentService;
        $this->middleware('auth:sanctum');
    }

    public function store(CommentRequest $request)
    {
        $data = $request->validated();
        $data['user_id'] = auth()->id();
        
        $comment = $this->commentService->createComment($data);
        return $this->success($comment, 'Комментарий добавлен', 201);
    }

    public function entityComments($type, $id)
    {
        $comments = $this->commentService->getEntityComments($type, $id);
        return $this->success($comments);
    }
}