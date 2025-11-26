<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use Illuminate\Support\Facades\DB;
use App\Models\User;

class EventSearchTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected $user;
    protected $token;

    protected function setUp(): void
    {
        parent::setUp();

        // Create a test user directly
        $this->user = User::create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => bcrypt('password'),
            'verificationCode' => 1234,
            'emailVerified' => 1,
        ]);

        // Create a token for the user
        $this->token = $this->user->createToken('test-token')->plainTextToken;
    }

    /**
     * Test search by category
     */
    public function test_search_by_category()
    {
        // Create test events
        DB::table('events')->insert([
            [
                'userId' => $this->user->userId,
                'eventTitle' => 'Music Concert',
                'startDate' => '2024-01-15',
                'startTime' => '19:00:00',
                'endTime' => '22:00:00',
                'description' => 'Amazing music concert',
                'category' => 'Music',
                'address' => '123 Music Street',
                'city' => 'New York',
                'latitude' => '40.7128',
                'longitude' => '-74.0060',
                'isActive' => 1,
                'addDate' => now(),
                'editDate' => now(),
            ],
            [
                'userId' => $this->user->userId,
                'eventTitle' => 'Sports Game',
                'startDate' => '2024-01-20',
                'startTime' => '15:00:00',
                'endTime' => '18:00:00',
                'description' => 'Exciting sports game',
                'category' => 'Sports',
                'address' => '456 Sports Ave',
                'city' => 'Los Angeles',
                'latitude' => '34.0522',
                'longitude' => '-118.2437',
                'isActive' => 1,
                'addDate' => now(),
                'editDate' => now(),
            ]
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/events/search', [
            'category' => 'Music'
        ]);

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'data',
                    'total',
                    'page',
                    'limit',
                    'message'
                ]);

        $this->assertCount(1, $response->json('data'));
        $this->assertEquals('Music Concert', $response->json('data.0.eventTitle'));
    }

    /**
     * Test search by city
     */
    public function test_search_by_city()
    {
        // Create test events
        DB::table('events')->insert([
            [
                'userId' => $this->user->userId,
                'eventTitle' => 'New York Event',
                'startDate' => '2024-01-15',
                'startTime' => '19:00:00',
                'endTime' => '22:00:00',
                'description' => 'New York event',
                'category' => 'Music',
                'address' => '123 NY Street',
                'city' => 'New York',
                'latitude' => '40.7128',
                'longitude' => '-74.0060',
                'isActive' => 1,
                'addDate' => now(),
                'editDate' => now(),
            ],
            [
                'userId' => $this->user->userId,
                'eventTitle' => 'LA Event',
                'startDate' => '2024-01-20',
                'startTime' => '15:00:00',
                'endTime' => '18:00:00',
                'description' => 'LA event',
                'category' => 'Sports',
                'address' => '456 LA Ave',
                'city' => 'Los Angeles',
                'latitude' => '34.0522',
                'longitude' => '-118.2437',
                'isActive' => 1,
                'addDate' => now(),
                'editDate' => now(),
            ]
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/events/search', [
            'city' => 'New York'
        ]);

        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertEquals('New York Event', $response->json('data.0.eventTitle'));
    }

    /**
     * Test get categories endpoint
     */
    public function test_get_categories()
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/events/categories');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'data',
                    'message'
                ]);

        $categories = $response->json('data');
        $this->assertContains('Music', $categories);
        $this->assertContains('Sports', $categories);
    }

    /**
     * Test get cities endpoint
     */
    public function test_get_cities()
    {
        // Create test events with cities
        DB::table('events')->insert([
            [
                'userId' => $this->user->userId,
                'eventTitle' => 'Event 1',
                'startDate' => '2024-01-15',
                'startTime' => '19:00:00',
                'endTime' => '22:00:00',
                'description' => 'Event 1 description',
                'address' => '123 Street',
                'city' => 'New York',
                'isActive' => 1,
                'addDate' => now(),
                'editDate' => now(),
            ],
            [
                'userId' => $this->user->userId,
                'eventTitle' => 'Event 2',
                'startDate' => '2024-01-20',
                'startTime' => '15:00:00',
                'endTime' => '18:00:00',
                'description' => 'Event 2 description',
                'address' => '456 Avenue',
                'city' => 'Los Angeles',
                'isActive' => 1,
                'addDate' => now(),
                'editDate' => now(),
            ]
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/events/cities');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'data',
                    'message'
                ]);

        $cities = $response->json('data');
        $this->assertContains('New York', $cities);
        $this->assertContains('Los Angeles', $cities);
    }
}
