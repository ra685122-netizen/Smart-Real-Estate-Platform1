<?php
require_once '../../config/db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $type     = isset($_GET['type'])     ? $_GET['type']     : null;
        $location = isset($_GET['location']) ? $_GET['location'] : null;
        $ownerId  = isset($_GET['owner_id']) ? (int)$_GET['owner_id'] : null;

        $query = "SELECT p.*,
                         u.name  AS owner_name,
                         u.phone AS owner_phone,
                         GROUP_CONCAT(pi.image_url ORDER BY pi.sort_order SEPARATOR ',') AS images_raw
                  FROM properties p
                  LEFT JOIN users u          ON u.id = p.owner_id
                  LEFT JOIN property_images pi ON pi.property_id = p.id
                  WHERE 1=1";

        if ($ownerId) {
            $query .= " AND p.owner_id = :owner_id";
        } else {
            $query .= " AND p.admin_approved = 1 AND p.status = 'available'";
        }

        if ($type) {
            $query .= " AND p.property_type = :type";
        }
        if ($location) {
            $query .= " AND (p.location LIKE :location OR p.city LIKE :location2)";
        }

        $query .= " GROUP BY p.id ORDER BY p.is_featured DESC, p.created_at DESC";

        $stmt = $conn->prepare($query);

        if ($ownerId) {
            $stmt->bindParam(':owner_id', $ownerId, PDO::PARAM_INT);
        }
        if ($type) {
            $stmt->bindParam(':type', $type);
        }
        if ($location) {
            $locParam = "%" . $location . "%";
            $stmt->bindValue(':location',  $locParam);
            $stmt->bindValue(':location2', $locParam);
        }

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

} elseif ($method === 'POST') {
    $data = json_decode(file_get_contents("php://input"));

    if (!empty($data->title) && !empty($data->price) && !empty($data->owner_id)) {
        $query = "INSERT INTO properties
                    (owner_id, title, description, price, listing_type, property_type, location, city, bedrooms, bathrooms, area, virtual_tour_url)
                  VALUES
                    (:owner_id, :title, :description, :price, :listing_type, :property_type, :location, :city, :bedrooms, :bathrooms, :area, :virtual_tour_url)";
        $stmt = $conn->prepare($query);

        $stmt->execute([
            ':owner_id'        => $data->owner_id,
            ':title'           => $data->title,
            ':description'     => $data->description     ?? '',
            ':price'           => $data->price,
            ':listing_type'    => $data->listing_type    ?? 'sale',
            ':property_type'   => $data->property_type   ?? 'apartment',
            ':location'        => $data->location        ?? null,
            ':city'            => $data->city            ?? null,
            ':bedrooms'        => $data->bedrooms        ?? 0,
            ':bathrooms'       => $data->bathrooms       ?? 0,
            ':area'            => $data->area            ?? null,
            ':virtual_tour_url'=> $data->virtual_tour_url ?? null,
        ]);

        $newId = $conn->lastInsertId();
        http_response_code(201);
        echo json_encode(["message" => "Property created.", "id" => $newId]);
    } else {
        http_response_code(400);
        echo json_encode(["message" => "Incomplete property data."]);
    }

} elseif ($method === 'PUT') {
    $data = json_decode(file_get_contents("php://input"));
    $id = isset($data->id) ? (int)$data->id : 0;

    if (!$id) {
        http_response_code(400);
        echo json_encode(["message" => "Property id required."]);
        exit();
    }

    $fields = [];
    $params = [':id' => $id];

    if (isset($data->title))         { $fields[] = 'title = :title';                 $params[':title']         = $data->title; }
    if (isset($data->description))   { $fields[] = 'description = :description';     $params[':description']   = $data->description; }
    if (isset($data->price))         { $fields[] = 'price = :price';                 $params[':price']         = (float)$data->price; }
    if (isset($data->property_type)) { $fields[] = 'property_type = :property_type'; $params[':property_type'] = $data->property_type; }
    if (isset($data->listing_type))  { $fields[] = 'listing_type = :listing_type';   $params[':listing_type']  = $data->listing_type; }
    if (isset($data->location))      { $fields[] = 'location = :location';           $params[':location']      = $data->location; }
    if (isset($data->city))          { $fields[] = 'city = :city';                   $params[':city']          = $data->city; }
    if (isset($data->bedrooms))      { $fields[] = 'bedrooms = :bedrooms';           $params[':bedrooms']      = (int)$data->bedrooms; }
    if (isset($data->bathrooms))     { $fields[] = 'bathrooms = :bathrooms';         $params[':bathrooms']     = (int)$data->bathrooms; }
    if (isset($data->area))          { $fields[] = 'area = :area';                   $params[':area']          = (float)$data->area; }
    if (isset($data->status))        { $fields[] = 'status = :status';               $params[':status']        = $data->status; }

    if (empty($fields)) {
        http_response_code(400);
        echo json_encode(["message" => "No fields to update."]);
        exit();
    }

    $stmt = $conn->prepare("UPDATE properties SET " . implode(', ', $fields) . " WHERE id = :id");
    $stmt->execute($params);

    http_response_code(200);
    echo json_encode(["message" => "Property updated."]);

} elseif ($method === 'DELETE') {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if (!$id) {
        http_response_code(400);
        echo json_encode(["message" => "id required"]);
        exit();
    }
    $conn->prepare("DELETE FROM properties WHERE id = :id")->execute([':id' => $id]);
    http_response_code(200);
    echo json_encode(["message" => "Property deleted."]);

} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
