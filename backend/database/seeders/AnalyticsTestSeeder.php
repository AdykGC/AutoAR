<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Machine;
use App\Models\Product;
use App\Models\Sale;
use Carbon\Carbon;

class AnalyticsTestSeeder extends Seeder {
    public function run() {
        // Создаём товары
        $products = [
            ['name' => 'Snacks', 'price' => 50],
            ['name' => 'Drinks', 'price' => 70],
            ['name' => 'Coffee', 'price' => 120],
            ['name' => 'Other', 'price' => 30],
        ];

        foreach ($products as $p) {
            Product::create($p);
        }

        // Берём первый аппарат (или создаём)
        $machine = Machine::first();
        if (!$machine) {
            $machine = Machine::factory()->create(); // если есть фабрика, иначе руками
        }

        // Генерируем продажи за последние 30 дней
        $start = Carbon::now()->subDays(30);
        $products = Product::all();

        for ($i = 0; $i < 100; $i++) {
            $date = $start->copy()->addDays(rand(0, 30))->addHours(rand(0, 23));
            $product = $products->random();
            $quantity = rand(1, 5);
            $total = $product->price * $quantity;

            Sale::create([
                'machine_id' => $machine->id,
                'product_id' => $product->id,
                'quantity' => $quantity,
                'total' => $total,
                'created_at' => $date,
                'updated_at' => $date,
            ]);
        }
    }
}