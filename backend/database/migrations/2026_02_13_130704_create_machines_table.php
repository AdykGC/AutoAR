<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('machines', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('machine_number')->unique();
            $table->string('location')->nullable();
            $table->enum('status', ['active', 'inactive', 'maintenance'])->default('active');
            $table->dateTime('last_service')->nullable();
            $table->string('type')->nullable(); // кофе, снэки, напитки
            $table->integer('capacity')->nullable();
            $table->decimal('current_balance', 10, 2)->default(0);
            $table->enum('connectivity_status', ['online', 'offline'])->default('online');
            $table->text('maintenance_notes')->nullable();
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // привязка к пользователю
            $table->timestamps();
        });
    }

    public function down(): void {
        Schema::dropIfExists('machines');
    }
};
