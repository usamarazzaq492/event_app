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
        Schema::table('booking', function (Blueprint $table) {
            // Commission and payout fields
            $table->decimal('appOwnerCommission', 10, 2)->nullable()->after('totalAmount');
            $table->decimal('organizerPayout', 10, 2)->nullable()->after('appOwnerCommission');
            $table->string('organizerSquareMerchantId', 255)->nullable()->after('organizerPayout');
            $table->string('organizerSquareLocationId', 255)->nullable()->after('organizerSquareMerchantId');
            $table->enum('paymentType', ['direct', 'split'])->default('direct')->after('organizerSquareLocationId');
            $table->text('splitPaymentDetails')->nullable()->after('paymentType');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('booking', function (Blueprint $table) {
            $table->dropColumn([
                'appOwnerCommission',
                'organizerPayout',
                'organizerSquareMerchantId',
                'organizerSquareLocationId',
                'paymentType',
                'splitPaymentDetails'
            ]);
        });
    }
};

