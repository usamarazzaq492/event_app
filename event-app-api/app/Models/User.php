<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $table = 'mstuser';  // your table name

    protected $primaryKey = 'userId';  // your PK column

    protected $casts = [
        'interests' => 'array',
    ];

    public $timestamps = true;

    const CREATED_AT = 'created_at';
    const UPDATED_AT = 'updated_at';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'apple_id',
        'email',
        'name',
        'phoneNumber',
        'password',
        'profileImageUrl',
        'shortBio',
        'interests',
        'isActive',
        'emailVerified',
        'verificationCode',
        'terms_accepted_at',
        'terms_version_accepted',
    ];

     /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'verificationCode',
        'remember_token',
    ];

    public function getInterestsAttribute($value)
    {
        return json_decode($value, true) ?? [];
    }
}
