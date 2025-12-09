<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        // Сначала удаляем все существующие разрешения и роли (осторожно!)
        Permission::query()->delete();
        Role::query()->delete();

        // Создаем ВСЕ разрешения которые могут понадобиться
        $allPermissions = [
            // === СИСТЕМНЫЕ ===
            'system.settings', 'system.analytics', 'system.backup',
            
            // === ПОЛЬЗОВАТЕЛИ ===
            'user.create', 'user.read', 'user.update', 'user.delete', 'user.manage',
            
            // === КЛИЕНТЫ ===
            'client.create', 'client.read', 'client.update', 'client.delete', 'client.manage',
            
            // === КОМПАНИЯ ===
            'company.read', 'company.update', 'company.delete', 'company.settings',
            'company.analytics', 'company.export',
            
            // === ФИНАНСЫ ===
            'budget.create', 'budget.read', 'budget.update', 'budget.delete', 'budget.approve',
            'salary.create', 'salary.read', 'salary.update', 'salary.delete', 'salary.manage',
            'salary.analytics', 'salary.export',
            'invoice.create', 'invoice.read', 'invoice.update', 'invoice.delete', 'invoice.pay',
            'expense.create', 'expense.read', 'expense.update', 'expense.delete', 'expense.approve',
            
            // === ПРОЕКТЫ ===
            'project.create', 'project.read', 'project.update', 'project.delete', 'project.manage',
            'project.budget', 'project.timeline', 'project.analytics', 'project.export',
            
            // === ЦЕЛИ ===
            'goal.create', 'goal.read', 'goal.update', 'goal.delete', 'goal.manage',
            'goal.analytics', 'goal.export', 'goal.review',
            
            // === ЗАДАЧИ ===
            'task.create', 'task.read', 'task.update', 'task.delete', 'task.manage',
            'task.assign', 'task.complete', 'task.analytics',
            
            // === КОМАНДЫ ===
            'team.create', 'team.read', 'team.update', 'team.delete', 'team.manage',
            'team.member.add', 'team.member.remove',
            
            // === АКТИВНОСТИ ===
            'activity.create', 'activity.read', 'activity.update', 'activity.delete',
            'activity.manage', 'activity.analytics',
            
            // === КАЛЕНДАРЬ ===
            'calendar.create', 'calendar.read', 'calendar.update', 'calendar.delete',
            'calendar.manage',
            
            // === СООБЩЕНИЯ ===
            'message.send', 'message.read', 'message.delete',
            
            // === ФАЙЛЫ ===
            'file.upload', 'file.download', 'file.delete',
            
            // === РОЛИ И РАЗРЕШЕНИЯ ===
            'role.manage', 'permission.manage',
        ];

        $this->command->info('Creating permissions...');
        
        // Создаем разрешения
        foreach ($allPermissions as $permission) {
            Permission::create([
                'name' => $permission,
                'guard_name' => 'sanctum'
            ]);
            $this->command->line("✓ Permission created: {$permission}");
        }

        $this->command->info('Creating roles...');

        // Создаем роли
        $roles = [
            'Owner',
            'Ceo', 
            'Admin',
            'Lawyer',
            'HR',
            'Counter',
            'Manager', 
            'Seller',
            'Slave',
            'Client',
            'Client VIP'
        ];

        foreach ($roles as $role) {
            Role::create([
                'name' => $role,
                'guard_name' => 'sanctum'
            ]);
            $this->command->line("✓ Role created: {$role}");
        }

        $this->command->info('Assigning permissions to roles...');

        // Назначаем разрешения ролям (сначала получаем все роли)
        $owner = Role::where('name', 'Owner')->first();
        $ceo = Role::where('name', 'Ceo')->first();
        $admin = Role::where('name', 'Admin')->first();
        $manager = Role::where('name', 'Manager')->first();
        $hr = Role::where('name', 'HR')->first();
        $counter = Role::where('name', 'Counter')->first();
        $seller = Role::where('name', 'Seller')->first();
        $slave = Role::where('name', 'Slave')->first();
        $client = Role::where('name', 'Client')->first();
        $clientVip = Role::where('name', 'Client VIP')->first();

        // Владелец получает все права
        $owner->syncPermissions(Permission::all());
        $this->command->info('✓ Owner got all permissions');

        // CEO - почти все права
        $ceoPermissions = array_filter($allPermissions, function($perm) {
            return !str_starts_with($perm, 'system.') && $perm !== 'role.manage' && $perm !== 'permission.manage';
        });
        $ceo->syncPermissions($ceoPermissions);
        $this->command->info('✓ CEO permissions assigned');

        // Админ - административные права
        $admin->syncPermissions([
            'user.create', 'user.read', 'user.update', 'user.delete', 'user.manage',
            'client.create', 'client.read', 'client.update', 'client.manage',
            'project.create', 'project.read', 'project.update', 'project.delete', 'project.manage',
            'task.create', 'task.read', 'task.update', 'task.delete', 'task.manage',
            'team.create', 'team.read', 'team.update', 'team.manage',
            'goal.create', 'goal.read', 'goal.update', 'goal.manage',
            'role.manage',
        ]);
        $this->command->info('✓ Admin permissions assigned');

        // Менеджер
        $manager->syncPermissions([
            'user.read', 'user.update',
            'client.read', 'client.update',
            'project.create', 'project.read', 'project.update', 'project.manage',
            'task.create', 'task.read', 'task.update', 'task.delete', 'task.manage', 'task.assign',
            'team.read', 'team.member.add', 'team.member.remove',
            'goal.create', 'goal.read', 'goal.update', 'goal.manage',
        ]);
        $this->command->info('✓ Manager permissions assigned');

        // HR
        $hr->syncPermissions([
            'user.create', 'user.read', 'user.update', 'user.manage',
            'salary.create', 'salary.read', 'salary.update', 'salary.manage',
            'team.manage',
        ]);
        $this->command->info('✓ HR permissions assigned');

        // Бухгалтер
        $counter->syncPermissions([
            'budget.create', 'budget.read', 'budget.update',
            'salary.create', 'salary.read', 'salary.update',
            'invoice.create', 'invoice.read', 'invoice.update', 'invoice.pay',
            'expense.create', 'expense.read', 'expense.update', 'expense.approve',
        ]);
        $this->command->info('✓ Counter permissions assigned');

        // Продавец
        $seller->syncPermissions([
            'client.create', 'client.read', 'client.update',
            'sale.create', 'sale.read', 'sale.update',
        ]);
        $this->command->info('✓ Seller permissions assigned');

        // Обычный сотрудник (Slave)
        $slave->syncPermissions([
            'user.read', 'user.update',
            'project.read',
            'task.read', 'task.update',
            'goal.read',
        ]);
        $this->command->info('✓ Slave permissions assigned');

        // Клиент
        $client->syncPermissions([
            'project.read',
            'task.read',
            'goal.create', 'goal.read',
            'message.send', 'message.read',
            'file.upload',
        ]);
        $this->command->info('✓ Client permissions assigned');

        // VIP Клиент
        $clientVip->syncPermissions([
            'project.create', 'project.read',
            'task.create', 'task.read',
            'goal.create', 'goal.read', 'goal.update',
            'message.send', 'message.read',
            'file.upload', 'file.download',
        ]);
        $this->command->info('✓ Client VIP permissions assigned');

        $this->command->info('✅ All roles and permissions created successfully!');
    }
}