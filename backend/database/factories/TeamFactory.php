<?php

namespace Database\Factories;

use App\Models\Team;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class TeamFactory extends Factory
{
    protected $model = Team::class;

    public function definition(): array
    {
        $departments = ['IT', 'Дизайн', 'Маркетинг', 'Продажи', 'Поддержка', 'Разработка'];

        return [
            'name' => 'Команда ' . $this->faker->word() . ' ' . $this->faker->numberBetween(1, 10),
            'description' => $this->faker->sentence(),
            'leader_id' => User::factory()->manager(),
            'department' => $this->faker->randomElement($departments),
            'created_at' => now(),
            'updated_at' => now(),
        ];
    }

    // Специализированные команды
    public function webDevelopment()
    {
        return $this->state([
            'name' => 'Веб-разработка',
            'description' => 'Команда веб-разработчиков',
            'department' => 'IT',
        ]);
    }

    public function design()
    {
        return $this->state([
            'name' => 'Дизайн студия',
            'description' => 'UI/UX дизайнеры',
            'department' => 'Дизайн',
        ]);
    }

    public function marketing()
    {
        return $this->state([
            'name' => 'Маркетинг',
            'description' => 'Маркетинг и продвижение',
            'department' => 'Маркетинг',
        ]);
    }

    public function sales()
    {
        return $this->state([
            'name' => 'Отдел продаж',
            'description' => 'Продажи и работа с клиентами',
            'department' => 'Продажи',
        ]);
    }
}