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
        Schema::create('booking', function (Blueprint $table) {
            $table->id('bookingId');
            $table->unsignedBigInteger('userId');
            $table->unsignedBigInteger('eventId');
            $table->datetime('bookingDate')->useCurrent();
            $table->enum('ticketType', ['gold', 'silver', 'general']);
            $table->integer('quantity');
            $table->decimal('totalAmount', 10, 2);
            $table->string('squarePaymentId', 255);
            $table->enum('status', ['pending', 'confirmed', 'cancelled'])->default('confirmed');
            $table->decimal('basePrice', 10, 2);
            $table->decimal('subtotal', 10, 2);
            $table->decimal('serviceFee', 10, 2);
            $table->decimal('processingFee', 10, 2);
            $table->text('feeBreakdown')->nullable();

            // Indexes
            $table->index('userId');
            $table->index('eventId');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('booking');
    }
};
