<?php

namespace Database\Factories;

use App\Models\Project;
use App\Models\ClientTask;
use App\Models\User;
use App\Models\Team;
use Illuminate\Database\Eloquent\Factories\Factory;

class ProjectFactory extends Factory
{
    protected $model = Project::class;

    public function definition(): array
    {
        $statuses = ['planning', 'active', 'on_hold', 'completed', 'cancelled'];

        return [
            'name' => 'Проект: ' . $this->faker->words(3, true),
            'description' => $this->faker->paragraph(2),
            'client_task_id' => ClientTask::factory(),
            'manager_id' => User::factory()->manager(),
            'team_id' => Team::factory(),
            'status' => $this->faker->randomElement($statuses),
            'start_date' => $this->faker->dateTimeBetween('-2 months', 'now'),
            'deadline' => $this->faker->dateTimeBetween('+1 month', '+6 months'),
            'created_at' => now(),
            'updated_at' => now(),
        ];
    }

    // Состояния для разных статусов проектов
    public function planning()
    {
        return $this->state([
            'status' => 'planning',
            'start_date' => null,
        ]);
    }

    public function active()
    {
        return $this->state([
            'status' => 'active',
            'start_date' => $this->faker->dateTimeBetween('-1 month', '-1 week'),
        ]);
    }

    public function completed()
    {
        return $this->state([
            'status' => 'completed',
            'start_date' => $this->faker->dateTimeBetween('-3 months', '-2 months'),
            'deadline' => $this->faker->dateTimeBetween('-1 month', 'now'),
        ]);
    }

    // Срочный проект
    public function urgent()
    {
        return $this->state([
            'name' => '[СРОЧНЫЙ] ' . $this->faker->words(3, true),
            'deadline' => $this->faker->dateTimeBetween('+1 week', '+2 weeks'),
        ]);
    }

    // Долгосрочный проект
    public function longTerm()
    {
        return $this->state([
            'name' => '[ДОЛГОСРОЧНЫЙ] ' . $this->faker->words(3, true),
            'deadline' => $this->faker->dateTimeBetween('+6 months', '+1 year'),
        ]);
    }
}