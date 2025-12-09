<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('🔐 Настройка ролей и разрешений...');

        // 1. Создаем разрешения для MVP
        $this->createPermissions();
        
        // 2. Создаем роли
        $this->createRoles();
        
        // 3. Назначаем разрешения
        $this->assignPermissions();
    }

    private function createPermissions(): void
    {
        $permissions = [
            // Пользователи
            'user.view', 'user.create', 'user.edit', 'user.delete',
            
            // Задачи клиентов
            'task.view', 'task.create', 'task.edit', 'task.delete', 'task.assign',
            
            // Проекты
            'project.view', 'project.create', 'project.edit', 'project.delete', 'project.manage',
            
            // Подзадачи
            'subtask.view', 'subtask.create', 'subtask.edit', 'subtask.delete', 'subtask.complete',
            
            // Команды
            'team.view', 'team.create', 'team.edit', 'team.delete', 'team.member.manage',
            
            // Комментарии
            'comment.create', 'comment.view', 'comment.delete',
            
            // Файлы
            'file.upload', 'file.download', 'file.delete',
            
            // Дашборд
            'dashboard.view',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate([
                'name' => $permission,
                'guard_name' => 'sanctum'
            ]);
        }

        $this->command->info('   ✅ Разрешения созданы: ' . count($permissions));
    }

    private function createRoles(): void
    {
        $roles = [
            'Owner',
            'Manager', 
            'Client',
            'Client VIP',
            'Employee', // Общая роль для всех сотрудников
            'Slave',
            'Seller',
            'Counter',
            'Lawyer', 
            'HR',
        ];

        foreach ($roles as $role) {
            Role::firstOrCreate([
                'name' => $role,
                'guard_name' => 'sanctum'
            ]);
        }

        $this->command->info('   ✅ Роли созданы: ' . count($roles));
    }

    private function assignPermissions(): void
    {
        // Owner - все права
        $owner = Role::where('name', 'Owner')->first();
        $owner->syncPermissions(Permission::all());
        $this->command->info('   👑 Owner: все права');

        // Manager - управление проектами и задачами
        $manager = Role::where('name', 'Manager')->first();
        $manager->syncPermissions([
            'user.view',
            'task.view', 'task.create', 'task.edit', 'task.delete', 'task.assign',
            'project.view', 'project.create', 'project.edit', 'project.delete', 'project.manage',
            'subtask.view', 'subtask.create', 'subtask.edit', 'subtask.delete',
            'team.view', 'team.member.manage',
            'comment.create', 'comment.view',
            'file.upload', 'file.download',
            'dashboard.view',
        ]);
        $this->command->info('   👨‍💼 Manager: права управления');

        // Client - базовые права
        $client = Role::where('name', 'Client')->first();
        $client->syncPermissions([
            'task.view', 'task.create',
            'project.view',
            'subtask.view',
            'comment.create', 'comment.view',
            'file.upload',
            'dashboard.view',
        ]);
        $this->command->info('   👤 Client: базовые права');

        // Client VIP - больше прав
        $clientVip = Role::where('name', 'Client VIP')->first();
        $clientVip->syncPermissions([
            'task.view', 'task.create', 'task.edit',
            'project.view',
            'subtask.view',
            'comment.create', 'comment.view',
            'file.upload', 'file.download',
            'dashboard.view',
        ]);
        $this->command->info('   💎 Client VIP: расширенные права');

        // Employee (общая роль для всех сотрудников)
        $employee = Role::where('name', 'Employee')->first();
        $employee->syncPermissions([
            'task.view',
            'project.view',
            'subtask.view', 'subtask.edit', 'subtask.complete',
            'comment.create', 'comment.view',
            'file.upload', 'file.download',
            'dashboard.view',
        ]);
        $this->command->info('   👷 Employee: права сотрудника');

        // Наследуем Employee права для специализированных ролей
        $specializedRoles = ['Slave', 'Seller', 'Counter', 'Lawyer', 'HR'];
        foreach ($specializedRoles as $roleName) {
            $role = Role::where('name', $roleName)->first();
            $role->syncPermissions($employee->permissions);
            $this->command->info("   🔧 {$roleName}: наследует Employee");
        }

        $this->command->info('   ✅ Назначение прав завершено');
    }
}