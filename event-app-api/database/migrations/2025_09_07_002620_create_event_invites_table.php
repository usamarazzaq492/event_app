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
        Schema::create('event_invites', function (Blueprint $table) {
            $table->id('inviteId');
            $table->unsignedBigInteger('eventId');
            $table->unsignedBigInteger('inviterId');
            $table->unsignedBigInteger('inviteeId');
            $table->enum('status', ['pending', 'accepted', 'declined'])->default('pending');
            $table->datetime('created_at')->useCurrent();

            // Indexes
            $table->index('eventId');
            $table->index('inviterId');
            $table->index('inviteeId');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('event_invites');
    }
};
