<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CategoriesSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            'Dating',
            'Sell Items',
            'Religion',
            'Sports',
            'Parties',
            'Food',
            'Music',
            'Youth events',
            'Social Circle',
            'Business',
            'Education',
            'Travel'
        ];

        foreach ($categories as $category) {
            DB::table('categories')->updateOrInsert(
                ['name' => $category],
                [
                    'name' => $category,
                    'description' => ucfirst($category) . ' events and activities',
                    'created_at' => now(),
                    'updated_at' => now()
                ]
            );
        }
    }
}
