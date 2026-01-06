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
        Schema::create('payment_qr_codes', function (Blueprint $table) {
            $table->id('qrId');
            $table->unsignedBigInteger('eventId');
            $table->unsignedBigInteger('userId'); // Organizer who created it
            $table->string('token', 64)->unique(); // Unique token for QR code
            $table->enum('ticketType', ['gold', 'silver', 'general'])->default('general');
            $table->string('qrCodeData', 500); // The actual QR code data (deep link URL)
            $table->datetime('expiresAt')->nullable(); // Optional expiry date
            $table->integer('maxUses')->nullable(); // Optional max number of scans
            $table->integer('currentUses')->default(0); // Track usage
            $table->boolean('isActive')->default(true);
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();

            // Indexes
            $table->index('eventId');
            $table->index('userId');
            $table->index('token');
            $table->index('isActive');

            // Foreign keys (optional, if you want referential integrity)
            // $table->foreign('eventId')->references('eventId')->on('events');
            // $table->foreign('userId')->references('userId')->on('mstuser');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payment_qr_codes');
    }
};

