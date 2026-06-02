<?php
require_once '../../config/db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : null;

    if ($id) {
        $stmt = $conn->prepare("SELECT id, name, email, role, phone, avatar, bio, is_verified, is_active, created_at FROM users WHERE id = :id");
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($user) {
            $user['id']          = (int)$user['id'];
            $user['is_verified'] = (bool)$user['is_verified'];
            $user['is_active']   = (bool)$user['is_active'];
            http_response_code(200);
            echo json_encode($user);
        } else {
            http_response_code(404);
            echo json_encode(["message" => "User not found"]);
        }
    } else {
        $stmt = $conn->query("SELECT id, name, email, role, phone, avatar, bio, is_verified, is_active, created_at FROM users ORDER BY created_at DESC");
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $users = array_map(function($u) {
            $u['id']          = (int)$u['id'];
            $u['is_verified'] = (bool)$u['is_verified'];
            $u['is_active']   = (bool)$u['is_active'];
            return $u;
        }, $users);
        http_response_code(200);
        echo json_encode($users);
    }

} elseif ($method === 'PUT') {
    $rawInput = file_get_contents("php://input");

    if (empty($rawInput)) {
        http_response_code(400);
        echo json_encode(["message" => "Empty request body"]);
        exit();
    }

    $data = json_decode($rawInput);

    if ($data === null) {
        http_response_code(400);
        echo json_encode(["message" => "Invalid JSON: " . json_last_error_msg()]);
        exit();
    }

    if (empty($data->id)) {
        http_response_code(400);
        echo json_encode(["message" => "User ID required"]);
        exit();
    }

    $userId = (int)$data->id;

    $fields = [];
    $params = [':id' => $userId];

    if (isset($data->name)      && $data->name !== '')     { $fields[] = "name = :name";           $params[':name']      = trim($data->name); }
    if (isset($data->phone))                               { $fields[] = "phone = :phone";          $params[':phone']     = trim($data->phone); }
    if (isset($data->bio))                                 { $fields[] = "bio = :bio";              $params[':bio']       = trim($data->bio); }
    if (isset($data->role))                                { $fields[] = "role = :role";            $params[':role']      = $data->role; }
    if (isset($data->avatar))                              { $fields[] = "avatar = :avatar";        $params[':avatar']    = $data->avatar; }
    if (isset($data->is_active))                           { $fields[] = "is_active = :is_active";  $params[':is_active'] = (int)$data->is_active; }
    if (isset($data->email) && $data->email !== '') {
        $newEmail = strtolower(trim($data->email));
        $chk = $conn->prepare("SELECT id FROM users WHERE email = :email AND id != :id LIMIT 1");
        $chk->execute([':email' => $newEmail, ':id' => $userId]);
        if ($chk->rowCount() > 0) {
            http_response_code(400);
            echo json_encode(["message" => "Email already used by another account"]);
            exit();
        }
        $fields[] = "email = :email";
        $params[':email'] = $newEmail;
    }

    if (empty($fields)) {
        http_response_code(400);
        echo json_encode(["message" => "No fields to update"]);
        exit();
    }

    try {
        $sql  = "UPDATE users SET " . implode(', ', $fields) . " WHERE id = :id";
        $stmt = $conn->prepare($sql);
        $stmt->execute($params);

        $rowCount = $stmt->rowCount();

        $stmt2 = $conn->prepare("SELECT id, name, email, role, phone, avatar, bio, is_verified, is_active, created_at FROM users WHERE id = :id");
        $stmt2->bindParam(':id', $userId, PDO::PARAM_INT);
        $stmt2->execute();
        $row2 = $stmt2->fetch(PDO::FETCH_ASSOC);

        if (!$row2) {
            http_response_code(404);
            echo json_encode(["message" => "User not found after update"]);
            exit();
        }

        http_response_code(200);
        echo json_encode([
            "message"      => "User updated",
            "rows_affected" => $rowCount,
            "user" => [
                "id"          => (int)$row2['id'],
                "name"        => $row2['name'],
                "email"       => $row2['email'],
                "role"        => $row2['role'],
                "phone"       => $row2['phone'],
                "avatar"      => $row2['avatar'],
                "bio"         => $row2['bio'],
                "is_verified" => (bool)$row2['is_verified'],
                "is_active"   => (bool)$row2['is_active'],
                "created_at"  => $row2['created_at'],
            ]
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(["message" => "DB error: " . $e->getMessage()]);
    }

} elseif ($method === 'DELETE') {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : null;
    if (!$id) {
        http_response_code(400);
        echo json_encode(["message" => "User ID required"]);
        exit();
    }
    try {
        $stmt = $conn->prepare("DELETE FROM users WHERE id = :id");
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        http_response_code(200);
        echo json_encode(["message" => "User deleted", "rows_affected" => $stmt->rowCount()]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(["message" => "DB error: " . $e->getMessage()]);
    }
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
