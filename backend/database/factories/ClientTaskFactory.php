<?php

namespace Database\Factories;

use App\Models\ClientTask;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class ClientTaskFactory extends Factory
{
    protected $model = ClientTask::class;

    public function definition(): array
    {
        $statuses = ['pending', 'approved', 'in_progress', 'completed', 'rejected'];
        $priorities = ['low', 'medium', 'high'];

        return [
            'title' => $this->faker->sentence(4),
            'description' => $this->faker->paragraph(3),
            'client_id' => User::factory()->client(),
            'status' => $this->faker->randomElement($statuses),
            'budget' => $this->faker->numberBetween(10000, 500000),
            'deadline' => $this->faker->dateTimeBetween('+1 month', '+6 months'),
            'progress' => $this->faker->numberBetween(0, 100),
            'created_at' => $this->faker->dateTimeBetween('-3 months', 'now'),
            'updated_at' => now(),
        ];
    }

    // Состояния для разных статусов
    public function pending()
    {
        return $this->state([
            'status' => 'pending',
            'manager_id' => null,
            'assigned_at' => null,
            'progress' => 0,
        ]);
    }

    public function approved()
    {
        return $this->state([
            'status' => 'approved',
            'manager_id' => User::factory()->manager(),
            'assigned_at' => now(),
            'progress' => 0,
        ]);
    }

    public function inProgress()
    {
        return $this->state([
            'status' => 'in_progress',
            'manager_id' => User::factory()->manager(),
            'assigned_at' => $this->faker->dateTimeBetween('-1 month', '-1 week'),
            'progress' => $this->faker->numberBetween(10, 80),
        ]);
    }

    public function completed()
    {
        return $this->state([
            'status' => 'completed',
            'manager_id' => User::factory()->manager(),
            'assigned_at' => $this->faker->dateTimeBetween('-2 months', '-1 month'),
            'progress' => 100,
        ]);
    }

    // Для срочных задач
    public function urgent()
    {
        return $this->state([
            'title' => '[СРОЧНО] ' . $this->faker->sentence(3),
            'budget' => $this->faker->numberBetween(50000, 200000),
            'deadline' => $this->faker->dateTimeBetween('+3 days', '+1 week'),
        ]);
    }

    // Для больших бюджетов
    public function largeBudget()
    {
        return $this->state([
            'title' => '[КРУПНЫЙ] ' . $this->faker->sentence(3),
            'budget' => $this->faker->numberBetween(300000, 1000000),
            'deadline' => $this->faker->dateTimeBetween('+3 months', '+1 year'),
        ]);
    }
}