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
        Schema::create('follows', function (Blueprint $table) {
            $table->id('followId');
            $table->unsignedBigInteger('follower_id');
            $table->unsignedBigInteger('followee_id');
            $table->datetime('created_at');

            // Indexes
            $table->index('follower_id');
            $table->index('followee_id');

            // Unique constraint to prevent duplicate follows
            $table->unique(['follower_id', 'followee_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('follows');
    }
};
