<?php
require_once '../../config/db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
    exit();
}

$data = json_decode(file_get_contents("php://input"));

if (empty($data->email) || empty($data->password)) {
    http_response_code(400);
    echo json_encode(["message" => "Incomplete login data."]);
    exit();
}

$email = htmlspecialchars(strip_tags($data->email));

$stmt = $conn->prepare("
    SELECT id, name, email, password_hash, role, phone, avatar, bio,
           is_verified, is_active, created_at
    FROM users
    WHERE email = :email
    LIMIT 1
");
$stmt->bindParam(':email', $email);
$stmt->execute();

if ($stmt->rowCount() === 0) {
    http_response_code(404);
    echo json_encode(["message" => "Login failed. User not found."]);
    exit();
}

$row = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$row['is_active']) {
    http_response_code(403);
    echo json_encode(["message" => "Account is deactivated."]);
    exit();
}

if (!password_verify($data->password, $row['password_hash'])) {
    http_response_code(401);
    echo json_encode(["message" => "Login failed. Incorrect password."]);
    exit();
}

$conn->prepare("UPDATE users SET last_login_at = NOW() WHERE id = :id")
     ->execute([':id' => $row['id']]);

http_response_code(200);
echo json_encode([
    "message" => "Successful login.",
    "user" => [
        "id"          => (int)$row['id'],
        "name"        => $row['name'],
        "email"       => $row['email'],
        "role"        => $row['role'],
        "phone"       => $row['phone'],
        "avatar"      => $row['avatar'],
        "bio"         => $row['bio'],
        "is_verified" => (bool)$row['is_verified'],
        "is_active"   => (bool)$row['is_active'],
        "created_at"  => $row['created_at'],
    ],
    "token" => bin2hex(random_bytes(32))
]);
?>
