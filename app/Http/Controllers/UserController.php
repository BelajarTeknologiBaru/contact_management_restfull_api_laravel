<?php

namespace App\Http\Controllers;

use App\Http\Requests\UserLoginRequest;
use App\Http\Requests\UserRegisterRequest;
use App\Http\Requests\UserUpdateRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
class UserController extends Controller
{
    public function register(UserRegisterRequest $request)  {
        $data = $request->validated();

        if(User::where("username", $data["username"])->count() == 1) {
            // Ada di database?

            throw new HttpResponseException(response([
                "errors"=>[
                    "username"=>"Username already registered"
                ]
            ],400));
        }

        $user = new User($data);
        $user->password = Hash::make($data["password"]);
        $user->save();

        return (new UserResource($user))->response()->setStatusCode(201);
        
    }
    public function login(UserLoginRequest $request):UserResource{
        $data = $request->validated();

        $user = User::where("username", $data["username"])->first();

        if(!$user || !Hash::check($data["password"], $user->password)) {
            throw new HttpResponseException(response([
                "errors"=>[
                    "message"=>["Invalid username or password"
                    ]
                ]
            ], 401));
        }

        $user->token = Str::uuid()->toString();
        $user->save();

        return new UserResource($user);
    }
    public function getUser(Request $request):UserResource
    {
        $user = Auth::user();
        return new UserResource($user);
    }
    public function updateUser(UserUpdateRequest $request):UserResource
    {
        $data = $request->validated();
        $user_id = Auth::user()->id;

        $user = User::find($user_id);

        if(isset($data["name"])){
            $user->name = $data["name"];
        }

        if(isset($data["password"])){
            $user->password = Hash::make($data["password"]);
        }

        $user->save();
        return new UserResource($user);
    }
}
