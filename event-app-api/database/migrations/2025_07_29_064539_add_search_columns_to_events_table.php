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
        // Only run if events table exists
        if (Schema::hasTable('events')) {
            Schema::table('events', function (Blueprint $table) {
                // Add search columns if they don't exist
                if (!Schema::hasColumn('events', 'latitude')) {
                    $table->decimal('latitude', 10, 8)->nullable()->after('city');
                }

                if (!Schema::hasColumn('events', 'longitude')) {
                    $table->decimal('longitude', 11, 8)->nullable()->after('latitude');
                }

                if (!Schema::hasColumn('events', 'category')) {
                    $table->string('category', 50)->nullable()->after('description');
                }
            });

            // Add indexes for better performance
            Schema::table('events', function (Blueprint $table) {
                $table->index('category', 'idx_events_category');
                $table->index('city', 'idx_events_city');
                $table->index(['latitude', 'longitude'], 'idx_events_location');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasTable('events')) {
            Schema::table('events', function (Blueprint $table) {
                // Remove indexes
                $table->dropIndex('idx_events_category');
                $table->dropIndex('idx_events_city');
                $table->dropIndex('idx_events_location');

                // Remove columns
                $table->dropColumn(['latitude', 'longitude', 'category']);
            });
        }
    }
};
