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
            $table->text('description');
            $table->string('category', 50)->nullable();
            $table->string('address', 500);
            $table->string('city', 50);
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->string('eventImage')->nullable();
            $table->boolean('isActive')->default(true);
            $table->timestamp('addDate')->useCurrent();
            $table->timestamp('editDate')->useCurrent();

            // Indexes for better performance
            $table->index('userId');
            $table->index('category', 'idx_events_category');
            $table->index('city', 'idx_events_city');
            $table->index(['latitude', 'longitude'], 'idx_events_location');
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
