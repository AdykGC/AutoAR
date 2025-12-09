<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. КОМАНДЫ (группы сотрудников)
        Schema::create('teams', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            
            // Лидер команды (менеджер)
            $table->foreignId('leader_id')->constrained('users');
            
            $table->string('department')->nullable();
            
            $table->timestamps();
            $table->softDeletes();
        });


        // 2. ЗАДАЧИ ОТ КЛИЕНТОВ (основная сущность MVP)
        Schema::create('client_tasks', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            
            // Кто создал (клиент)
            $table->foreignId('client_id')->constrained('users')->onDelete('cascade');
            
            // Статус: новая → в работе → выполнена
            $table->enum('status', [
                'pending',      // на рассмотрении
                'approved',     // одобрена менеджером
                'in_progress',  // в работе
                'completed',    // выполнена
                'rejected',     // отклонена
                'cancelled'     // отменена
            ])->default('pending');
            
            $table->decimal('budget', 12, 2)->nullable();
            $table->date('deadline')->nullable();
            
            // Когда менеджер взял в работу
            $table->foreignId('manager_id')->nullable()->constrained('users');
            $table->timestamp('assigned_at')->nullable();
            
            // Прогресс выполнения (0-100%)
            $table->integer('progress')->default(0);
            
            $table->timestamps();
            $table->softDeletes();
        });


        // 3. ПРОЕКТЫ (менеджер создает для выполнения задачи)
        Schema::create('projects', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            
            // Связь с задачей клиента
            $table->foreignId('client_task_id')->constrained('client_tasks')->onDelete('cascade');
            
            // Ответственный менеджер
            $table->foreignId('manager_id')->constrained('users')->onDelete('cascade');
            
            // Команда исполнителей
            $table->foreignId('team_id')->nullable()->constrained();
            
            $table->enum('status', [
                'planning',     // планирование
                'active',       // в работе
                'on_hold',      // приостановлен
                'completed',    // завершен
                'cancelled'     // отменен
            ])->default('planning');
            
            $table->date('start_date')->nullable();
            $table->date('deadline')->nullable();
            
            $table->timestamps();
            $table->softDeletes();
        });


        // 4. ПОДЗАДАЧИ ПРОЕКТА (что нужно сделать)
        Schema::create('project_tasks', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            
            // К какому проекту относится
            $table->foreignId('project_id')->constrained()->onDelete('cascade');
            
            // Кто должен выполнить (сотрудник)
            $table->foreignId('assignee_id')->nullable()->constrained('users');
            
            // Кто создал (менеджер)
            $table->foreignId('creator_id')->constrained('users');
            
            $table->enum('status', [
                'todo',         // к выполнению
                'in_progress',  // в работе
                'review',       // на проверке
                'completed',    // выполнена
                'blocked'       // заблокирована
            ])->default('todo');
            
            $table->integer('estimated_hours')->nullable();
            $table->integer('actual_hours')->default(0);
            
            $table->date('due_date')->nullable();
            $table->timestamp('completed_at')->nullable();
            
            // Приоритет для сортировки
            $table->integer('priority')->default(0);
            
            $table->timestamps();
            $table->softDeletes();
        });




        // 6. СОСТАВ КОМАНД (связь многие-ко-многим)
        Schema::create('team_members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('team_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('role')->default('member'); // member, senior, lead
            $table->timestamps();
            
            $table->unique(['team_id', 'user_id']);
        });


        // 7. АКТИВНОСТИ (лог событий)
        Schema::create('activities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            
            // Делаем поля nullable для системных событий (регистрация, вход и т.д.)
            $table->string('activityable_type')->nullable();
            $table->unsignedBigInteger('activityable_id')->nullable();
            
            $table->string('type'); // created, updated, assigned, completed, etc
            $table->text('description');
            
            // Старые и новые значения для изменений
            $table->json('old_values')->nullable();
            $table->json('new_values')->nullable();
            
            $table->timestamps();
            
            // Для быстрого поиска активностей по сущности
            $table->index(['activityable_type', 'activityable_id', 'created_at']);
        });


        // 8. КОММЕНТАРИИ/ЧАТ (обсуждение задач)
        Schema::create('comments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            
            // К чему относится комментарий
            $table->morphs('commentable'); // client_task, project, project_task
            
            $table->text('content');
            
            // Для ответов на комментарии
            $table->foreignId('parent_id')->nullable()->constrained('comments')->onDelete('cascade');
            
            $table->timestamps();
            $table->softDeletes();
        });


        // 9. ФАЙЛЫ (прикрепления к задачам/проектам)
        Schema::create('attachments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            
            // К чему прикреплен файл
            $table->morphs('attachable'); // client_task, project, project_task
            
            $table->string('filename');
            $table->string('path');
            $table->string('mime_type');
            $table->integer('size');
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // В обратном порядке удаления
        Schema::dropIfExists('attachments');
        Schema::dropIfExists('comments');
        Schema::dropIfExists('activities');
        Schema::dropIfExists('team_members');
        Schema::dropIfExists('teams');
        Schema::dropIfExists('project_tasks');
        Schema::dropIfExists('projects');
        Schema::dropIfExists('client_tasks');
    }
};
