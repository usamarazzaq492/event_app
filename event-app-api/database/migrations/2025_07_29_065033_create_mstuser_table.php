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
            $table->string('name');
            $table->string('email')->unique();
            $table->string('password');
            $table->text('shortBio')->nullable();
            $table->string('profileImageUrl')->nullable();
            $table->integer('verificationCode')->nullable();
            $table->boolean('emailVerified')->default(false);
            $table->json('interests')->nullable();
            $table->string('phoneNumber')->nullable();

            // No timestamps as per User model
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
