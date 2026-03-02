<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Team;
use App\Models\ClientTask;
use App\Models\Project;
use App\Models\ProjectTask;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('🚀 Запуск сидинга базы данных MVP CRM...');

        // 1. Создание ролей и разрешений
        $this->call(RolePermissionSeeder::class);
        
        // 2. Создание основных пользователей (ВРУЧНУЮ, без фабрик)
        $this->createCoreUsers();
        
        // 3. Создание команд
        $this->createTeams();
        
        // 4. Создание задач клиентов
        $this->createClientTasks();
        
        // 5. Создание проектов
        $this->createProjects();
        
        // 6. Создание подзадач проектов
        $this->createProjectTasks();
        
        // 7. Назначение пользователей командам
        $this->assignUsersToTeams();

        $this->command->info('✅ Сидинг завершен успешно!');
    }

    private function createCoreUsers(): void
    {
        $this->command->info('👥 Создание основных пользователей...');

        // Владелец
        $owner = User::create([
            'name' => 'Александр Владелец',
            'surname' => 'Петров',
            'email' => 'owner@company.com',
            'phone' => '+7 999 111-22-33',
            'password' => Hash::make('password123'),
            'is_active' => true,
        ]);
        $owner->assignRole('Owner');
        $this->command->info("   ✓ Владелец: {$owner->email}");

        // Менеджеры (3 человека)
        $managers = [];
        for ($i = 1; $i <= 3; $i++) {
            $manager = User::create([
                'name' => "Менеджер $i",
                'surname' => 'Сидоров',
                'email' => "manager$i@company.com",
                'phone' => '+7 999 222-33-4' . $i,
                'password' => Hash::make('password123'),
                'is_active' => true,
            ]);
            $manager->assignRole('Manager');
            $managers[] = $manager;
        }
        $this->command->info('   ✓ Менеджеры: 3 создано');

        // Клиенты (10 человек)
        $clients = [];
        for ($i = 1; $i <= 10; $i++) {
            $client = User::create([
                'name' => "Клиент $i",
                'surname' => 'Иванов',
                'email' => "client$i@client.com",
                'phone' => '+7 999 333-44-5' . $i,
                'password' => Hash::make('password123'),
                'is_active' => true,
            ]);
            $client->assignRole('Client');
            $clients[] = $client;
        }
        $this->command->info('   ✓ Клиенты: 10 создано');

        // Сотрудники (15 человек)
        $employees = [];
        $employeeRoles = ['Slave', 'Seller', 'Counter', 'Lawyer', 'HR'];
        for ($i = 1; $i <= 15; $i++) {
            $role = $employeeRoles[$i % count($employeeRoles)];
            $employee = User::create([
                'name' => "Сотрудник $i ($role)",
                'surname' => 'Работников',
                'email' => "employee$i@company.com",
                'phone' => '+7 999 444-55-6' . $i,
                'password' => Hash::make('password123'),
                'is_active' => true,
            ]);
            $employee->assignRole($role);
            $employees[] = $employee;
        }
        $this->command->info('   ✓ Сотрудники: 15 создано');

        // VIP Клиент
        $vipClient = User::create([
            'name' => 'VIP Клиент',
            'surname' => 'Особенный',
            'email' => 'vip@client.com',
            'phone' => '+7 999 000-11-22',
            'password' => Hash::make('password123'),
            'is_active' => true,
        ]);
        $vipClient->assignRole('Client VIP');
        $this->command->info("   ✓ VIP Клиент: {$vipClient->email}");

        // Сохраняем ссылки для использования в других методах
        $this->managers = $managers;
        $this->clients = $clients;
        $this->employees = $employees;
    }

    private function createTeams(): void
    {
        $this->command->info('👥 Создание команд...');

        $teamsData = [
            ['name' => 'Веб-разработка', 'department' => 'IT'],
            ['name' => 'Мобильная разработка', 'department' => 'IT'],
            ['name' => 'Дизайн студия', 'department' => 'Дизайн'],
            ['name' => 'Маркетинг', 'department' => 'Маркетинг'],
            ['name' => 'Поддержка', 'department' => 'Поддержка'],
        ];

        $this->teams = [];
        foreach ($teamsData as $i => $teamData) {
            $team = Team::create([
                'name' => $teamData['name'],
                'description' => "Команда {$teamData['name']}",
                'leader_id' => $this->managers[$i % count($this->managers)]->id,
                'department' => $teamData['department'],
            ]);
            $this->teams[] = $team;
            $this->command->info("   ✓ Команда: {$team->name}");
        }
    }

    private function createClientTasks(): void
    {
        $this->command->info('📝 Создание задач клиентов...');

        $taskTitles = [
            'Разработать интернет-магазин',
            'Создать мобильное приложение',
            'Дизайн лендинга',
            'Настройка рекламной кампании',
            'Разработка CRM системы',
            'Создание корпоративного сайта',
            'Интеграция с 1С',
            'SEO оптимизация',
            'Разработка чат-бота',
            'Создание видео-ролика',
        ];

        $statuses = ['pending', 'approved', 'in_progress', 'completed'];
        
        foreach ($taskTitles as $i => $title) {
            $client = $this->clients[$i % count($this->clients)];
            $manager = $i > 2 ? $this->managers[$i % count($this->managers)] : null;
            
            $task = ClientTask::create([
                'title' => $title,
                'description' => "Описание задачи: $title. Детали выполнения.",
                'client_id' => $client->id,
                'status' => $statuses[$i % count($statuses)],
                'budget' => rand(10000, 500000),
                'deadline' => now()->addDays(rand(30, 180))->format('Y-m-d'),
                'manager_id' => $manager?->id,
                'assigned_at' => $manager ? now() : null,
                'progress' => $manager ? rand(0, 100) : 0,
            ]);
            
            $this->command->info("   ✓ Задача: {$task->title} ({$task->status})");
        }
    }

    private function createProjects(): void
    {
        $this->command->info('🏗️ Создание проектов...');

        // Берем задачи со статусом approved или in_progress
        $clientTasks = ClientTask::whereIn('status', ['approved', 'in_progress'])->get();

        foreach ($clientTasks as $i => $task) {
            $project = Project::create([
                'name' => "Проект: {$task->title}",
                'description' => "Проект для выполнения задачи: {$task->title}",
                'client_task_id' => $task->id,
                'manager_id' => $task->manager_id ?? $this->managers[0]->id,
                'team_id' => $this->teams[$i % count($this->teams)]->id,
                'status' => $task->status === 'approved' ? 'planning' : 'active',
                'start_date' => now()->format('Y-m-d'),
                'deadline' => $task->deadline,
            ]);
            
            $this->command->info("   ✓ Проект: {$project->name}");
        }
    }

    private function createProjectTasks(): void
    {
        $this->command->info('✅ Создание подзадач проектов...');

        $projects = Project::all();
        
        foreach ($projects as $project) {
            $subTasks = [
                ['title' => 'Анализ требований', 'estimated_hours' => 8],
                ['title' => 'Планирование', 'estimated_hours' => 16],
                ['title' => 'Дизайн', 'estimated_hours' => 24],
                ['title' => 'Разработка', 'estimated_hours' => 40],
                ['title' => 'Тестирование', 'estimated_hours' => 16],
                ['title' => 'Документация', 'estimated_hours' => 8],
            ];

            foreach ($subTasks as $j => $subTaskData) {
                $assignee = $j < count($this->employees) ? $this->employees[$j]->id : null;
                
                ProjectTask::create([
                    'title' => $subTaskData['title'],
                    'description' => "{$subTaskData['title']} для проекта {$project->name}",
                    'project_id' => $project->id,
                    'assignee_id' => $assignee,
                    'creator_id' => $project->manager_id,
                    'status' => $assignee ? ($j < 3 ? 'completed' : 'in_progress') : 'todo',
                    'estimated_hours' => $subTaskData['estimated_hours'],
                    'actual_hours' => $assignee ? rand(8, 40) : 0,
                    'due_date' => now()->addDays(rand(7, 30))->format('Y-m-d'),
                    'completed_at' => $j < 3 ? now() : null,
                    'priority' => $j + 1,
                ]);
            }
            
            $this->command->info("   📊 Проект '{$project->name}': 6 подзадач создано");
        }
    }

    private function assignUsersToTeams(): void
    {
        $this->command->info('🤝 Назначение пользователей командам...');

        foreach ($this->teams as $team) {
            // Добавляем лидера команды
            $team->members()->attach($team->leader_id, ['role' => 'leader']);

            // Добавляем 3-5 случайных сотрудников
            $randomEmployees = collect($this->employees)->random(rand(3, 5));
            foreach ($randomEmployees as $employee) {
                $team->members()->attach($employee->id, ['role' => 'member']);
            }

            $this->command->info("   👥 Команда '{$team->name}': {$team->members()->count()} участников");
        }
    }
}