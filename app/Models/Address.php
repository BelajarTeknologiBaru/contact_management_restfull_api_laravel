<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Address extends Model
{
    protected $table = "addresses";
    protected $primaryKey = "id";
    protected $keyType ="int";
    protected $timestamps = true ;
    protected $incrementing = true ;

    public function contacts():BelongsTo
    {
        return $this->belongsTo(Contact::class,"contact_id","id");
    }
}
