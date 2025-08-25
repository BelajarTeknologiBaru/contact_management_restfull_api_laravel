<?php

use App\Http\Controllers\UserController;
use App\Http\Middleware\ApiAuthMiddleware;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
//     return $request->user();
// });

Route::get("/auth/session", function () {
    return response()->json([
        "data" => [
            "id" => uuid_create(UUID_TYPE_RANDOM),
            "name" => "Ahmad Zidni",
            "avatarUrl" => "https://avatars.githubusercontent.com/u/55963299?v=4",
            "email" => "ahmad@gmail.com"

        ]
    ], 200);
});

Route::post("/users", [UserController::class, 'register']);
Route::post("/users/login", [UserController::class, 'login']);

Route::middleware(ApiAuthMiddleware::class)->group(function () {
    Route::get("/users/current", [UserController::class, 'getUser']);
    Route::patch("/users/current", [UserController::class, 'updateUser']);
});
