<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('mstuser', function (Blueprint $table) {
            $table->id('userId');
            $table->string('email', 50)->unique();
            $table->string('name', 255)->nullable();
            $table->string('phoneNumber', 20)->nullable();
            $table->string('password', 200);
            $table->integer('verificationCode')->nullable();
            $table->string('profileImageUrl', 255)->nullable();
            $table->string('shortBio', 255)->nullable();
            $table->longText('interests')->nullable();
            $table->integer('isActive')->default(1);
            $table->integer('emailVerified')->default(0);
            $table->datetime('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('mstuser');
    }
};
