<?php
require_once '../../config/db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;
    if (!$userId) {
        http_response_code(400);
        echo json_encode(["message" => "user_id required"]);
        exit();
    }

    $sql = "
        SELECT
            c.id AS conversation_id,
            c.property_id,
            p.title AS property_title,
            other_u.id AS other_user_id,
            other_u.name AS other_user_name,
            other_u.avatar AS other_user_avatar,
            m.message AS last_message,
            m.created_at AS last_message_time,
            m.sender_id AS last_sender_id,
            (SELECT COUNT(*) FROM messages mm
             WHERE mm.conversation_id = c.id
               AND mm.sender_id != :uid_unread
               AND mm.is_read = 0) AS unread_count
        FROM conversations c
        JOIN conversation_participants cp ON cp.conversation_id = c.id AND cp.user_id = :uid
        JOIN conversation_participants cp2 ON cp2.conversation_id = c.id AND cp2.user_id != :uid2
        JOIN users other_u ON other_u.id = cp2.user_id
        LEFT JOIN properties p ON p.id = c.property_id
        LEFT JOIN messages m ON m.id = (
            SELECT id FROM messages WHERE conversation_id = c.id ORDER BY created_at DESC LIMIT 1
        )
        ORDER BY last_message_time DESC
    ";

    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':uid', $userId, PDO::PARAM_INT);
    $stmt->bindParam(':uid2', $userId, PDO::PARAM_INT);
    $stmt->bindParam(':uid_unread', $userId, PDO::PARAM_INT);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    http_response_code(200);
    echo json_encode($rows);

} elseif ($method === 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    $userId = isset($data->user_id) ? (int)$data->user_id : 0;
    $otherUserId = isset($data->other_user_id) ? (int)$data->other_user_id : 0;
    $propertyId = isset($data->property_id) ? (int)$data->property_id : null;

    if (!$userId || !$otherUserId) {
        http_response_code(400);
        echo json_encode(["message" => "user_id and other_user_id required"]);
        exit();
    }

    $sql = "
        SELECT c.id FROM conversations c
        JOIN conversation_participants cp1 ON cp1.conversation_id = c.id AND cp1.user_id = :uid1
        JOIN conversation_participants cp2 ON cp2.conversation_id = c.id AND cp2.user_id = :uid2
        LIMIT 1
    ";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':uid1', $userId, PDO::PARAM_INT);
    $stmt->bindParam(':uid2', $otherUserId, PDO::PARAM_INT);
    $stmt->execute();
    $existing = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($existing) {
        http_response_code(200);
        echo json_encode(["conversation_id" => $existing['id']]);
    } else {
        $stmt2 = $conn->prepare("INSERT INTO conversations (property_id) VALUES (:pid)");
        $stmt2->bindParam(':pid', $propertyId, PDO::PARAM_INT);
        $stmt2->execute();
        $convId = $conn->lastInsertId();

        $stmt3 = $conn->prepare("INSERT INTO conversation_participants (conversation_id, user_id) VALUES (:cid, :uid)");
        $stmt3->execute([':cid' => $convId, ':uid' => $userId]);
        $stmt3->execute([':cid' => $convId, ':uid' => $otherUserId]);

        http_response_code(201);
        echo json_encode(["conversation_id" => $convId]);
    }
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
