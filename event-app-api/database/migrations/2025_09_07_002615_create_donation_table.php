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
        Schema::create('donation', function (Blueprint $table) {
            $table->id('donationId');
            $table->unsignedBigInteger('userId');
            $table->string('title', 255);
            $table->string('imageUrl', 200);
            $table->string('description', 3000);
            $table->decimal('amount', 10, 2);
            $table->integer('isActive')->default(1);
            $table->datetime('addDate')->useCurrent();
            $table->timestamp('updated_at', 5)->nullable();

            // Indexes
            $table->index('userId');
            $table->index('isActive');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('donation');
    }
};
