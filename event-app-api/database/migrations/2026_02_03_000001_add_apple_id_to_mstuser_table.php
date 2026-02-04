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
        if (!Schema::hasColumn('mstuser', 'apple_id')) {
            Schema::table('mstuser', function (Blueprint $table) {
                $table->string('apple_id', 255)->nullable()->unique()->after('password');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasColumn('mstuser', 'apple_id')) {
            Schema::table('mstuser', function (Blueprint $table) {
                $table->dropColumn('apple_id');
            });
        }
    }
};
