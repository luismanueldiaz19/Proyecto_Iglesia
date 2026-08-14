<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use App\Models\User;

class ProfileController extends Controller
{
    /**
     * Update the authenticated user's name.
     */
    public function updateProfile(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'current_password' => 'required|string',
        ]);

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'message' => 'La contraseña actual es incorrecta.'
            ], 403);
        }

        $user->name = $request->name;
        $user->save();

        return response()->json([
            'message' => 'Perfil actualizado exitosamente.',
            'user' => [
                'username' => $user->username,
                'name' => $user->name,
                'roles' => $user->getRoleNames(),
                'profile_photo_url' => $user->profile_photo_url,
            ]
        ]);
    }

    /**
     * Change the authenticated user's password.
     */
    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required|string',
            'password' => 'required|string|min:6|confirmed',
        ]);

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'message' => 'La contraseña actual es incorrecta.'
            ], 403);
        }

        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json([
            'message' => 'Contraseña cambiada exitosamente.'
        ]);
    }

    /**
     * Get the active sessions for the authenticated user.
     */
    public function getSessions(Request $request)
    {
        $sessions = DB::table('sessions')
            ->where('user_id', $request->user()->id)
            ->orderBy('last_activity', 'desc')
            ->get()
            ->map(function ($session) {
                return [
                    'id' => $session->id,
                    'ip_address' => $session->ip_address,
                    'user_agent' => $session->user_agent,
                    'last_activity' => \Carbon\Carbon::createFromTimestamp($session->last_activity)->toDateTimeString(),
                    // El token actual podría ser diferente, pero indicamos si coincide si fuera sesión normal.
                    // Para sanctum, 'sessions' tabla se usa si config/session.php usa database.
                ];
            });

        return response()->json($sessions);
    }

    /**
     * Get the permissions for the authenticated user.
     */
    public function getPermissions(Request $request)
    {
        $user = $request->user();
        // Obtener todos los permisos directos o vía roles (Spatie)
        $permissions = $user->getAllPermissions()->pluck('name');
        
        return response()->json($permissions);
    }

    /**
     * Upload and update the authenticated user's profile photo.
     */
    public function uploadPhoto(Request $request)
    {
        $request->validate([
            'photo' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        $user = $request->user();

        // Borrar la foto anterior si existe
        if ($user->profile_photo_path) {
            Storage::delete($user->profile_photo_path);
        }

        $path = $request->file('photo')->store('profile-photos');

        $user->profile_photo_path = $path;
        $user->save();

        return response()->json([
            'message' => 'Foto de perfil actualizada.',
            'profile_photo_url' => $user->profile_photo_url,
        ]);
    }

    /**
     * Get the authenticated user's profile photo.
     */
    public function getPhoto($filename, Request $request)
    {
        $path = 'profile-photos/' . $filename;
        
        if (!Storage::exists($path)) {
            abort(404);
        }

        return Storage::response($path);
    }
}
