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
        Schema::create('events', function (Blueprint $table) {
            $table->id('eventId');
            $table->unsignedBigInteger('userId');
            $table->string('eventTitle', 500);
            $table->date('startDate');
            $table->date('endDate')->nullable();
            $table->time('startTime');
            $table->time('endTime');
            $table->decimal('eventPrice', 10, 2)->nullable();
            $table->string('description', 1000);
            $table->string('category', 50);
            $table->string('address', 500);
            $table->string('city', 50);
            $table->string('latitude', 50)->nullable();
            $table->string('longitude', 50)->nullable();
            $table->string('eventImage', 200);
            $table->integer('isActive')->default(1);
            $table->datetime('addDate');
            $table->datetime('editDate')->nullable();

            // Indexes for better performance
            $table->index('userId');
            $table->index('category');
            $table->index('city');
            $table->index('isActive');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('events');
    }
};
