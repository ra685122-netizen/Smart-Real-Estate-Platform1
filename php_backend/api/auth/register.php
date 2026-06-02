<?php
require_once '../../config/db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
    exit();
}

$data = json_decode(file_get_contents("php://input"));

if (empty($data->name) || empty($data->email) || empty($data->password) || empty($data->role)) {
    http_response_code(400);
    echo json_encode(["message" => "Unable to create user. Data is incomplete."]);
    exit();
}

$email = htmlspecialchars(strip_tags($data->email));

$check = $conn->prepare("SELECT id FROM users WHERE email = :email LIMIT 1");
$check->bindParam(':email', $email);
$check->execute();
if ($check->rowCount() > 0) {
    http_response_code(400);
    echo json_encode(["message" => "User already exists with this email."]);
    exit();
}

$name          = htmlspecialchars(strip_tags($data->name));
$role          = htmlspecialchars(strip_tags($data->role));
$password_hash = password_hash($data->password, PASSWORD_BCRYPT);

$stmt = $conn->prepare("
    INSERT INTO users (name, email, password_hash, role)
    VALUES (:name, :email, :password_hash, :role)
");
$stmt->bindParam(':name',          $name);
$stmt->bindParam(':email',         $email);
$stmt->bindParam(':password_hash', $password_hash);
$stmt->bindParam(':role',          $role);

if (!$stmt->execute()) {
    http_response_code(503);
    echo json_encode(["message" => "Unable to create user."]);
    exit();
}

$newId = (int)$conn->lastInsertId();

$sel = $conn->prepare("
    SELECT id, name, email, role, phone, avatar, bio, is_verified, is_active, created_at
    FROM users WHERE id = :id
");
$sel->execute([':id' => $newId]);
$user = $sel->fetch(PDO::FETCH_ASSOC);

http_response_code(201);
echo json_encode([
    "message" => "User was created.",
    "user" => [
        "id"          => (int)$user['id'],
        "name"        => $user['name'],
        "email"       => $user['email'],
        "role"        => $user['role'],
        "phone"       => $user['phone'],
        "avatar"      => $user['avatar'],
        "bio"         => $user['bio'],
        "is_verified" => (bool)$user['is_verified'],
        "is_active"   => (bool)$user['is_active'],
        "created_at"  => $user['created_at'],
    ]
]);
?>
