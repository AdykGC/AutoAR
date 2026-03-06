<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('machines', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('type');
            $table->string('location')->nullable();
            $table->string('serial_number')->nullable();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');

            $table->string('connection_type')->nullable();
            $table->decimal('install_price', 10, 2)->nullable();
            $table->decimal('price_adjustment', 10, 2)->nullable();
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->boolean('is_active')->default(true);

            $table->timestamps();
        });
    }

    public function down(): void {
        Schema::dropIfExists('machines');
    }
};
