<?php
require_once '../../config/db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $convId = isset($_GET['conversation_id']) ? (int)$_GET['conversation_id'] : 0;
    $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;

    if (!$convId) {
        http_response_code(400);
        echo json_encode(["message" => "conversation_id required"]);
        exit();
    }

    $sql = "
        SELECT m.id, m.conversation_id, m.sender_id, m.message, m.is_read, m.created_at,
               u.name AS sender_name, u.avatar AS sender_avatar
        FROM messages m
        JOIN users u ON u.id = m.sender_id
        WHERE m.conversation_id = :cid
        ORDER BY m.created_at ASC
    ";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':cid', $convId, PDO::PARAM_INT);
    $stmt->execute();
    $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($userId) {
        $markRead = $conn->prepare("UPDATE messages SET is_read = 1 WHERE conversation_id = :cid AND sender_id != :uid AND is_read = 0");
        $markRead->execute([':cid' => $convId, ':uid' => $userId]);
    }

    http_response_code(200);
    echo json_encode($messages);

} elseif ($method === 'POST') {
    $data = json_decode(file_get_contents("php://input"));

    $convId    = isset($data->conversation_id) ? (int)$data->conversation_id : 0;
    $senderId  = isset($data->sender_id) ? (int)$data->sender_id : 0;
    $message   = isset($data->message) ? trim($data->message) : '';

    if (!$convId || !$senderId || empty($message)) {
        http_response_code(400);
        echo json_encode(["message" => "conversation_id, sender_id, message required"]);
        exit();
    }

    $stmt = $conn->prepare("INSERT INTO messages (conversation_id, sender_id, message) VALUES (:cid, :sid, :msg)");
    $stmt->execute([':cid' => $convId, ':sid' => $senderId, ':msg' => $message]);
    $msgId = $conn->lastInsertId();

    $stmt2 = $conn->prepare("
        SELECT m.id, m.conversation_id, m.sender_id, m.message, m.is_read, m.created_at,
               u.name AS sender_name
        FROM messages m JOIN users u ON u.id = m.sender_id
        WHERE m.id = :id
    ");
    $stmt2->bindParam(':id', $msgId, PDO::PARAM_INT);
    $stmt2->execute();
    $newMsg = $stmt2->fetch(PDO::FETCH_ASSOC);

    http_response_code(201);
    echo json_encode($newMsg);
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
