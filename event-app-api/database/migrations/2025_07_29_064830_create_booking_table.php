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
            $table->unsignedBigInteger('eventId');
            $table->unsignedBigInteger('userId');
            $table->string('ticketType')->nullable();
            $table->integer('quantity')->default(1);
            $table->decimal('basePrice', 10, 2)->nullable();
            $table->decimal('subtotal', 10, 2)->nullable();
            $table->decimal('serviceFee', 10, 2)->nullable();
            $table->decimal('processingFee', 10, 2)->nullable();
            $table->decimal('totalAmount', 10, 2)->nullable();
            $table->string('squarePaymentId')->nullable();
            $table->text('feeBreakdown')->nullable();
            $table->timestamp('bookingDate')->useCurrent();
            $table->string('status')->default('pending');

            $table->index('eventId');
            $table->index('userId');
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
