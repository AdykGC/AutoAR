<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolePermissionSeeder extends Seeder {
    public function run(): void {
        // Создаем разрешения и роли
        $permissions = [
            'user.create',
            'user.read', 
            'user.update',
            'user.delete',
            'company.create',
            'company.read',
            'company.update',
            'company.delete',
            'project.create',
            'project.read',
            'project.update',
            'project.delete',
            'WORK 24/7',
        ];
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
        ];
        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }
        foreach ($roles as $role) {
            Role::firstOrCreate([ 'guard_name' => 'sanctum', 'name' => $role ]);
        }

        // Создаем роли и назначаем разрешения
        $Role_0 = Role::firstOrCreate(['name' => 'admin']);
        $Role_0->givePermissionTo(Permission::all());

        $Role_1 = Role::firstOrCreate(['name' => 'HR']);
        $Role_1->givePermissionTo([
            'user.read',
            'user.update',
            'company.read',
            'project.read',
        ]);

        $Role_2 = Role::firstOrCreate(['name' => 'Manager']);
        $Role_2->givePermissionTo([
            'project.create', 'user.update',
            'company.create', 'company.read', 'company.update', 'company.delete',
            'project.create', 'project.read', 'project.update', 'project.delete',
        ]);

        $Role_3 = Role::firstOrCreate(['name' => 'Slave']);
        $Role_3->givePermissionTo([
            'WORK 24/7',
        ]);
    }
}
