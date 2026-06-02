<?php
require_once '../../config/db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;
    if (!$userId) { http_response_code(400); echo json_encode(["message" => "user_id required"]); exit(); }

    $sql = "
        SELECT p.*, u.name AS owner_name, u.phone AS owner_phone,
               GROUP_CONCAT(pi.image_url ORDER BY pi.sort_order SEPARATOR ',') AS images_raw
        FROM favorites f
        JOIN properties p ON p.id = f.property_id
        LEFT JOIN users u ON u.id = p.owner_id
        LEFT JOIN property_images pi ON pi.property_id = p.id
        WHERE f.user_id = :uid AND p.status = 'available'
        GROUP BY p.id
        ORDER BY f.created_at DESC
    ";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':uid', $userId, PDO::PARAM_INT);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $properties = array_map(function($row) {
        $row['images'] = !empty($row['images_raw']) ? explode(',', $row['images_raw']) : [];
        unset($row['images_raw']);
        return $row;
    }, $rows);

    http_response_code(200);
    echo json_encode($properties);

} elseif ($method === 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    $userId     = isset($data->user_id)     ? (int)$data->user_id     : 0;
    $propertyId = isset($data->property_id) ? (int)$data->property_id : 0;

    if (!$userId || !$propertyId) { http_response_code(400); echo json_encode(["message" => "user_id and property_id required"]); exit(); }

    $check = $conn->prepare("SELECT id FROM favorites WHERE user_id = :uid AND property_id = :pid");
    $check->execute([':uid' => $userId, ':pid' => $propertyId]);
    $exists = $check->fetch();

    if ($exists) {
        $conn->prepare("DELETE FROM favorites WHERE user_id = :uid AND property_id = :pid")->execute([':uid' => $userId, ':pid' => $propertyId]);
        http_response_code(200);
        echo json_encode(["message" => "removed", "is_favorite" => false]);
    } else {
        $conn->prepare("INSERT INTO favorites (user_id, property_id) VALUES (:uid, :pid)")->execute([':uid' => $userId, ':pid' => $propertyId]);
        http_response_code(201);
        echo json_encode(["message" => "added", "is_favorite" => true]);
    }
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
