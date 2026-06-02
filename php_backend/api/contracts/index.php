<?php
require_once '../../config/db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $userId     = isset($_GET['user_id'])   ? (int)$_GET['user_id']   : 0;
    $contractId = isset($_GET['id'])        ? (int)$_GET['id']        : 0;

    if ($contractId) {
        $stmt = $conn->prepare("
            SELECT c.*,
                   p.title  AS property_title,
                   pi.image_url AS property_image,
                   b.name   AS buyer_name,
                   s.name   AS seller_name
            FROM contracts c
            JOIN properties p ON p.id = c.property_id
            LEFT JOIN property_images pi ON pi.property_id = p.id AND pi.is_primary = 1
            JOIN users b ON b.id = c.buyer_id
            JOIN users s ON s.id = c.seller_id
            WHERE c.id = :id
        ");
        $stmt->execute([':id' => $contractId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) {
            http_response_code(404);
            echo json_encode(['message' => 'Contract not found']);
            exit();
        }
        http_response_code(200);
        echo json_encode(_formatContract($row));
        exit();
    }

    if (!$userId) {
        http_response_code(400);
        echo json_encode(['message' => 'user_id required']);
        exit();
    }

    $stmt = $conn->prepare("
        SELECT c.*,
               p.title  AS property_title,
               pi.image_url AS property_image,
               b.name   AS buyer_name,
               s.name   AS seller_name
        FROM contracts c
        JOIN properties p ON p.id = c.property_id
        LEFT JOIN property_images pi ON pi.property_id = p.id AND pi.is_primary = 1
        JOIN users b ON b.id = c.buyer_id
        JOIN users s ON s.id = c.seller_id
        WHERE c.buyer_id = :uid OR c.seller_id = :uid2
        ORDER BY c.created_at DESC
    ");
    $stmt->execute([':uid' => $userId, ':uid2' => $userId]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    http_response_code(200);
    echo json_encode(array_map('_formatContract', $rows));

} elseif ($method === 'POST') {
    $data = json_decode(file_get_contents('php://input'));

    $propertyId = isset($data->property_id) ? (int)$data->property_id : 0;
    $buyerId    = isset($data->buyer_id)    ? (int)$data->buyer_id    : 0;
    $sellerId   = isset($data->seller_id)   ? (int)$data->seller_id   : 0;
    $type       = isset($data->type)        ? trim($data->type)       : 'sale';
    $amount     = isset($data->amount)      ? (float)$data->amount    : 0;
    $notes      = isset($data->notes)       ? trim($data->notes)      : '';
    $startDate  = isset($data->start_date)  ? trim($data->start_date) : null;
    $endDate    = isset($data->end_date)    ? trim($data->end_date)   : null;
    $expiryDate = isset($data->expiry_date) ? trim($data->expiry_date): null;

    if (!$propertyId || !$buyerId || !$sellerId || !$amount) {
        http_response_code(400);
        echo json_encode(['message' => 'property_id, buyer_id, seller_id, amount required']);
        exit();
    }

    $contractNumber = 'CON-' . date('Y') . '-' . strtoupper(substr(uniqid(), -6));

    $stmt = $conn->prepare("
        INSERT INTO contracts
            (contract_number, property_id, buyer_id, seller_id, type, status, amount, start_date, end_date, expiry_date, notes)
        VALUES
            (:cn, :pid, :bid, :sid, :type, 'pending', :amount, :sd, :ed, :exp, :notes)
    ");
    $stmt->execute([
        ':cn'     => $contractNumber,
        ':pid'    => $propertyId,
        ':bid'    => $buyerId,
        ':sid'    => $sellerId,
        ':type'   => $type,
        ':amount' => $amount,
        ':sd'     => $startDate,
        ':ed'     => $endDate,
        ':exp'    => $expiryDate,
        ':notes'  => $notes,
    ]);
    $newId = $conn->lastInsertId();

    $stmt2 = $conn->prepare("
        SELECT c.*,
               p.title AS property_title,
               pi.image_url AS property_image,
               b.name AS buyer_name,
               s.name AS seller_name
        FROM contracts c
        JOIN properties p ON p.id = c.property_id
        LEFT JOIN property_images pi ON pi.property_id = p.id AND pi.is_primary = 1
        JOIN users b ON b.id = c.buyer_id
        JOIN users s ON s.id = c.seller_id
        WHERE c.id = :id
    ");
    $stmt2->execute([':id' => $newId]);
    $row = $stmt2->fetch(PDO::FETCH_ASSOC);

    http_response_code(201);
    echo json_encode(_formatContract($row));

} elseif ($method === 'PUT') {
    $data = json_decode(file_get_contents('php://input'));

    $contractId = isset($data->id) ? (int)$data->id : 0;
    if (!$contractId) {
        http_response_code(400);
        echo json_encode(['message' => 'contract id required']);
        exit();
    }

    if (isset($data->sign) && $data->sign) {
        $userId       = isset($data->user_id)       ? (int)$data->user_id   : 0;
        $role         = isset($data->role)           ? trim($data->role)     : '';
        $signatureB64 = isset($data->signature_b64) ? $data->signature_b64  : '';

        if (!$userId || !in_array($role, ['buyer', 'seller'])) {
            http_response_code(400);
            echo json_encode(['message' => 'user_id and role (buyer|seller) required']);
            exit();
        }

        $sigStmt = $conn->prepare("
            INSERT INTO contract_signatures (contract_id, user_id, role, signature_b64, ip_address, user_agent)
            VALUES (:cid, :uid, :role, :sig, :ip, :ua)
            ON DUPLICATE KEY UPDATE signature_b64 = :sig2, signed_at = CURRENT_TIMESTAMP
        ");
        $sigStmt->execute([
            ':cid'  => $contractId,
            ':uid'  => $userId,
            ':role' => $role,
            ':sig'  => $signatureB64,
            ':ip'   => $_SERVER['REMOTE_ADDR'] ?? null,
            ':ua'   => $_SERVER['HTTP_USER_AGENT'] ?? null,
            ':sig2' => $signatureB64,
        ]);

        $field = ($role === 'buyer') ? 'buyer_signed' : 'seller_signed';
        $conn->prepare("UPDATE contracts SET {$field} = 1 WHERE id = :id")->execute([':id' => $contractId]);

        $check = $conn->prepare("SELECT buyer_signed, seller_signed FROM contracts WHERE id = :id");
        $check->execute([':id' => $contractId]);
        $c = $check->fetch(PDO::FETCH_ASSOC);
        if ($c['buyer_signed'] && $c['seller_signed']) {
            $conn->prepare("UPDATE contracts SET status = 'signed', signed_at = NOW() WHERE id = :id")
                 ->execute([':id' => $contractId]);
        }

        http_response_code(200);
        echo json_encode(['message' => 'Signed successfully']);
        exit();
    }

    $status = isset($data->status) ? trim($data->status) : null;
    if ($status) {
        $conn->prepare("UPDATE contracts SET status = :s WHERE id = :id")
             ->execute([':s' => $status, ':id' => $contractId]);
    }

    http_response_code(200);
    echo json_encode(['message' => 'Updated']);

} elseif ($method === 'DELETE') {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if (!$id) { http_response_code(400); echo json_encode(['message' => 'id required']); exit(); }
    $conn->prepare("DELETE FROM contracts WHERE id = :id")->execute([':id' => $id]);
    http_response_code(200);
    echo json_encode(['message' => 'Deleted']);
} else {
    http_response_code(405);
    echo json_encode(['message' => 'Method not allowed']);
}

function _formatContract(array $row): array {
    return [
        'id'              => (int)$row['id'],
        'contract_number' => $row['contract_number'],
        'property_id'     => (int)$row['property_id'],
        'property_title'  => $row['property_title'] ?? '',
        'property_image'  => $row['property_image'] ?? '',
        'buyer_id'        => (int)$row['buyer_id'],
        'buyer_name'      => $row['buyer_name'] ?? '',
        'seller_id'       => (int)$row['seller_id'],
        'seller_name'     => $row['seller_name'] ?? '',
        'type'            => $row['type'],
        'status'          => $row['status'],
        'amount'          => (float)$row['amount'],
        'start_date'      => $row['start_date'],
        'end_date'        => $row['end_date'],
        'expiry_date'     => $row['expiry_date'],
        'notes'           => $row['notes'],
        'buyer_signed'    => (bool)$row['buyer_signed'],
        'seller_signed'   => (bool)$row['seller_signed'],
        'signed_at'       => $row['signed_at'],
        'created_at'      => $row['created_at'],
    ];
}
?>
