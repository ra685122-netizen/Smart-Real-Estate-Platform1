<?php
require_once '../../config/db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $stmt = $conn->query("
        SELECT p.*, u.name AS owner_name,
               GROUP_CONCAT(pi.image_url ORDER BY pi.sort_order SEPARATOR ',') AS images_raw
        FROM properties p
        LEFT JOIN users u ON u.id = p.owner_id
        LEFT JOIN property_images pi ON pi.property_id = p.id
        GROUP BY p.id ORDER BY p.created_at DESC
    ");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $properties = array_map(function($row) {
        $row['images'] = !empty($row['images_raw']) ? explode(',', $row['images_raw']) : [];
        unset($row['images_raw']);
        return $row;
    }, $rows);
    http_response_code(200);
    echo json_encode($properties);

} elseif ($method === 'PUT') {
    $data = json_decode(file_get_contents("php://input"));
    $id = isset($data->id) ? (int)$data->id : 0;
    if (!$id) { http_response_code(400); echo json_encode(["message" => "id required"]); exit(); }

    $fields = [];
    $params = [':id' => $id];
    if (isset($data->admin_approved)) { $fields[] = "admin_approved = :approved"; $params[':approved'] = $data->admin_approved; }
    if (isset($data->status))         { $fields[] = "status = :status";           $params[':status']   = $data->status; }
    if (isset($data->is_featured))    { $fields[] = "is_featured = :featured";    $params[':featured'] = $data->is_featured; }

    if (empty($fields)) { http_response_code(400); echo json_encode(["message" => "No fields to update"]); exit(); }

    $conn->prepare("UPDATE properties SET " . implode(', ', $fields) . " WHERE id = :id")->execute($params);
    http_response_code(200);
    echo json_encode(["message" => "Property updated"]);

} elseif ($method === 'DELETE') {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if (!$id) { http_response_code(400); echo json_encode(["message" => "id required"]); exit(); }
    $conn->prepare("DELETE FROM properties WHERE id = :id")->execute([':id' => $id]);
    http_response_code(200);
    echo json_encode(["message" => "Property deleted"]);
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
