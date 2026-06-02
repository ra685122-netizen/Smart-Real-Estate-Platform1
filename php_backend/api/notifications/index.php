<?php
require_once '../../config/db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;
    if (!$userId) { http_response_code(400); echo json_encode(["message" => "user_id required"]); exit(); }

    $stmt = $conn->prepare("SELECT * FROM notifications WHERE user_id = :uid ORDER BY created_at DESC LIMIT 50");
    $stmt->bindParam(':uid', $userId, PDO::PARAM_INT);
    $stmt->execute();
    http_response_code(200);
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));

} elseif ($method === 'PUT') {
    $data = json_decode(file_get_contents("php://input"));
    $userId = isset($data->user_id) ? (int)$data->user_id : 0;
    $id     = isset($data->id)      ? (int)$data->id      : 0;

    if ($id) {
        $conn->prepare("UPDATE notifications SET is_read = 1 WHERE id = :id")->execute([':id' => $id]);
    } elseif ($userId) {
        $conn->prepare("UPDATE notifications SET is_read = 1 WHERE user_id = :uid")->execute([':uid' => $userId]);
    }
    http_response_code(200);
    echo json_encode(["message" => "Marked as read"]);
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
