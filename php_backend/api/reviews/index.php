<?php
require_once '../../config/db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $propertyId = isset($_GET['property_id']) ? (int)$_GET['property_id'] : 0;
    $agencyId   = isset($_GET['agency_id'])   ? (int)$_GET['agency_id']   : 0;
    $ownerId    = isset($_GET['owner_id'])     ? (int)$_GET['owner_id']    : 0;

    if ($propertyId) {
        $stmt = $conn->prepare("
            SELECT r.id, r.user_id, r.property_id, r.rating, r.comment, r.created_at,
                   u.name AS user_name, u.avatar AS user_avatar
            FROM reviews r JOIN users u ON u.id = r.user_id
            WHERE r.property_id = :pid ORDER BY r.created_at DESC
        ");
        $stmt->bindParam(':pid', $propertyId, PDO::PARAM_INT);
    } elseif ($agencyId) {
        $stmt = $conn->prepare("
            SELECT r.id, r.user_id, r.agency_id, r.rating, r.comment, r.created_at,
                   u.name AS user_name, u.avatar AS user_avatar
            FROM reviews r JOIN users u ON u.id = r.user_id
            WHERE r.agency_id = :aid ORDER BY r.created_at DESC
        ");
        $stmt->bindParam(':aid', $agencyId, PDO::PARAM_INT);
    } else {
        $stmt = $conn->query("
            SELECT r.id, r.user_id, r.property_id, r.agency_id, r.rating, r.comment, r.created_at,
                   u.name AS user_name
            FROM reviews r JOIN users u ON u.id = r.user_id
            ORDER BY r.created_at DESC LIMIT 50
        ");
    }
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    http_response_code(200);
    echo json_encode($rows);

} elseif ($method === 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    $userId     = isset($data->user_id)     ? (int)$data->user_id     : 0;
    $rating     = isset($data->rating)      ? (int)$data->rating      : 0;
    $comment    = isset($data->comment)     ? trim($data->comment)    : '';
    $propertyId = isset($data->property_id) ? (int)$data->property_id : null;
    $agencyId   = isset($data->agency_id)   ? (int)$data->agency_id   : null;

    if (!$userId || !$rating || (!$propertyId && !$agencyId)) {
        http_response_code(400);
        echo json_encode(["message" => "user_id, rating, and property_id or agency_id required"]);
        exit();
    }

    $stmt = $conn->prepare("
        INSERT INTO reviews (user_id, property_id, agency_id, rating, comment)
        VALUES (:uid, :pid, :aid, :rating, :comment)
    ");
    $stmt->execute([
        ':uid'     => $userId,
        ':pid'     => $propertyId,
        ':aid'     => $agencyId,
        ':rating'  => $rating,
        ':comment' => $comment,
    ]);
    $newId = $conn->lastInsertId();

    $stmt2 = $conn->prepare("
        SELECT r.id, r.user_id, r.property_id, r.rating, r.comment, r.created_at, u.name AS user_name
        FROM reviews r JOIN users u ON u.id = r.user_id WHERE r.id = :id
    ");
    $stmt2->bindParam(':id', $newId, PDO::PARAM_INT);
    $stmt2->execute();
    $review = $stmt2->fetch(PDO::FETCH_ASSOC);

    http_response_code(201);
    echo json_encode($review);

} elseif ($method === 'DELETE') {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if (!$id) { http_response_code(400); echo json_encode(["message" => "id required"]); exit(); }
    $conn->prepare("DELETE FROM reviews WHERE id = :id")->execute([':id' => $id]);
    http_response_code(200);
    echo json_encode(["message" => "Review deleted"]);
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
