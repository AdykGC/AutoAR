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
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('surname')->nullable();
            $table->string('email')->unique();
            $table->string('phone')->nullable();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');

            // Пункт увольнение
            $table->boolean('is_active')->default(true);
            $table->timestamp('deactivated_at')->nullable();
            $table->text('termination_reason')->nullable(); // ← ДОБАВЬТЕ ЭТО
            $table->timestamp('termination_date')->nullable(); // ← И ЭТО
            $table->softDeletes();
            
            // Сессия
            $table->rememberToken();
            $table->timestamps();
        });

        Schema::create('password_reset_tokens', function (Blueprint $table) {
            $table->string('email')->primary();
            $table->string('token');
            $table->timestamp('created_at')->nullable();
        });

        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity')->index();
        });

        Schema::create('termination_records', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('terminated_by')->constrained('users')->onDelete('cascade');
            $table->text('reason')->nullable();
            $table->date('termination_date');
            $table->boolean('final_salary_paid')->default(false);
            $table->json('metadata')->nullable();
            $table->timestamps();
        });

        Schema::create('goals', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            $table->enum('type', ['kpi', 'okr', 'personal', 'team']);
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('assigned_by')->nullable()->constrained('users'); // Кто поставил цель
            $table->decimal('target_value', 10, 2);
            $table->decimal('current_value', 10, 2)->default(0);
            $table->string('unit')->default('%');
            $table->date('start_date');
            $table->date('end_date');
            $table->enum('status', ['not_started', 'in_progress', 'completed', 'failed', 'on_hold']);
            $table->json('metrics')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::create('projects', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->foreignId('manager_id')->constrained('users'); // Руководитель проекта
            $table->foreignId('client_id')->nullable()->constrained('users'); // Клиент (User с ролью Client)
            $table->decimal('budget', 15, 2)->nullable();
            $table->decimal('spent', 15, 2)->default(0);
            $table->date('start_date');
            $table->date('deadline');
            $table->enum('priority', ['low', 'medium', 'high', 'critical']);
            $table->enum('status', ['planning', 'active', 'on_hold', 'completed', 'cancelled']);
            $table->json('tags')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::create('teams', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->foreignId('leader_id')->constrained('users'); // Лидер команды
            $table->string('department')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
        
        // Связующая таблица пользователей и команд
        Schema::create('team_user', function (Blueprint $table) {
            $table->id();
            $table->foreignId('team_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('role_in_team')->default('member'); // leader, member, observer
            $table->timestamps();
        });
        
        Schema::create('tasks', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            $table->foreignId('project_id')->constrained()->onDelete('cascade');
            $table->foreignId('assignee_id')->nullable()->constrained('users'); // Исполнитель
            $table->foreignId('creator_id')->constrained('users'); // Создатель
            $table->foreignId('goal_id')->nullable()->constrained('goals'); // Связанная цель
            $table->integer('estimated_hours')->nullable();
            $table->integer('actual_hours')->default(0);
            $table->enum('priority', ['low', 'medium', 'high', 'critical']);
            $table->enum('status', ['todo', 'in_progress', 'review', 'completed', 'blocked']);
            $table->date('due_date');
            $table->date('completed_at')->nullable();
            $table->json('checklist')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
        
        
        
        Schema::create('salaries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->decimal('base_salary', 12, 2);
            $table->decimal('bonus', 12, 2)->default(0);
            $table->decimal('commission', 12, 2)->default(0);
            $table->string('currency')->default('USD');
            $table->enum('period', ['hourly', 'daily', 'weekly', 'monthly', 'annually']);
            $table->date('effective_from');
            $table->date('effective_to')->nullable();
            $table->boolean('is_active')->default(true);
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
        
        Schema::create('activities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->nullableMorphs('activityable'); // task, goal, project
            $table->string('type'); // task_completed, goal_updated, project_milestone
            $table->text('description');
            $table->json('metadata')->nullable();
            $table->timestamps();
        });
        
        Schema::create('progress_tracking', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->nullableMorphs('trackable'); // goal, project, task
            $table->date('track_date')->default(now());
            $table->decimal('progress', 5, 2)->default(0); // 0-100%
            $table->json('metrics')->nullable();
            $table->timestamps();
            
            $table->unique(['user_id', 'trackable_id', 'trackable_type', 'track_date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
        Schema::dropIfExists('password_reset_tokens');
        Schema::dropIfExists('sessions');
    }
};
