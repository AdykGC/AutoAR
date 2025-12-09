<?php

namespace App\Http\Controllers\Api;

use App\Services\AttachmentService;
use Illuminate\Http\Request;

class AttachmentController extends BaseController
{
    protected $attachmentService;

    public function __construct(AttachmentService $attachmentService)
    {
        $this->attachmentService = $attachmentService;
        $this->middleware('auth:sanctum');
    }

    public function store(Request $request)
    {
        $request->validate([
            'file' => 'required|file|max:10240', // 10MB
            'attachable_type' => 'required|string',
            'attachable_id' => 'required|integer'
        ]);

        $file = $request->file('file');
        $attachment = $this->attachmentService->upload(
            $file,
            $request->attachable_type,
            $request->attachable_id
        );

        return $this->success($attachment, 'Файл загружен', 201);
    }

    public function entityAttachments($type, $id)
    {
        $attachments = $this->attachmentService->getEntityAttachments($type, $id);
        return $this->success($attachments);
    }
}