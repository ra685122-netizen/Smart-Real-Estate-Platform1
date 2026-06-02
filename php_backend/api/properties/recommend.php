<?php
require_once '../../config/db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
    exit();
}

try {
    $query = "SELECT p.*,
                     u.name  AS owner_name,
                     u.phone AS owner_phone,
                     GROUP_CONCAT(pi.image_url ORDER BY pi.sort_order SEPARATOR ',') AS images_raw
              FROM properties p
              LEFT JOIN users u           ON u.id = p.owner_id
              LEFT JOIN property_images pi ON pi.property_id = p.id
              WHERE p.admin_approved = 1 AND p.status = 'available'
              GROUP BY p.id
              ORDER BY p.is_featured DESC, RAND()
              LIMIT 6";

    $stmt = $conn->prepare($query);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $properties = array_map(function($row) {
        $images = [];
        if (!empty($row['images_raw'])) {
            $images = explode(',', $row['images_raw']);
        } elseif (!empty($row['virtual_tour_url'])) {
            $images = [$row['virtual_tour_url']];
        }
        $row['images'] = $images;
        unset($row['images_raw']);
        return $row;
    }, $rows);

    http_response_code(200);
    echo json_encode($properties);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["message" => "DB error: " . $e->getMessage()]);
}
?>
