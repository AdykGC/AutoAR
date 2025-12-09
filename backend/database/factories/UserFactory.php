<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => $this->faker->firstName(),
            'surname' => $this->faker->lastName(),
            'email' => $this->faker->unique()->safeEmail(),
            'phone' => $this->faker->phoneNumber(),
            'email_verified_at' => now(),
            'password' => Hash::make('password123'),
            'is_active' => true,
            'remember_token' => Str::random(10),
            'created_at' => now(),
            'updated_at' => now(),
        ];
    }

    public function owner()
    {
        return $this->state([
            'name' => 'Владелец Компании',
            'email' => 'owner@company.com',
        ]);
    }

    public function manager()
    {
        return $this->state([
            'name' => $this->faker->firstName() . ' Менеджер',
            'email' => $this->faker->unique()->userName() . '@company.com',
        ]);
    }

    public function client()
    {
        return $this->state([
            'name' => $this->faker->firstName() . ' Клиент',
            'email' => $this->faker->unique()->userName() . '@client.com',
        ]);
    }

    public function employee()
    {
        return $this->state([
            'name' => $this->faker->firstName() . ' Сотрудник',
            'email' => $this->faker->unique()->userName() . '@employee.com',
        ]);
    }

    public function inactive()
    {
        return $this->state([
            'is_active' => false,
            'deleted_at' => now(),
        ]);
    }
}