<?php
require_once '../../config/db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $userId    = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;
    $paymentId = isset($_GET['id'])      ? (int)$_GET['id']      : 0;

    if ($paymentId) {
        $stmt = $conn->prepare("
            SELECT py.*, p.title AS property_title,
                   b.name AS payer_name, s.name AS payee_name
            FROM payments py
            LEFT JOIN properties p ON p.id = py.property_id
            JOIN users b ON b.id = py.payer_id
            JOIN users s ON s.id = py.payee_id
            WHERE py.id = :id
        ");
        $stmt->execute([':id' => $paymentId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) {
            http_response_code(404);
            echo json_encode(['message' => 'Payment not found']);
            exit();
        }
        http_response_code(200);
        echo json_encode(_formatPayment($row));
        exit();
    }

    if (!$userId) {
        http_response_code(400);
        echo json_encode(['message' => 'user_id required']);
        exit();
    }

    $stmt = $conn->prepare("
        SELECT py.*, p.title AS property_title,
               b.name AS payer_name, s.name AS payee_name
        FROM payments py
        LEFT JOIN properties p ON p.id = py.property_id
        JOIN users b ON b.id = py.payer_id
        JOIN users s ON s.id = py.payee_id
        WHERE py.payer_id = :uid OR py.payee_id = :uid2
        ORDER BY py.created_at DESC
    ");
    $stmt->execute([':uid' => $userId, ':uid2' => $userId]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    http_response_code(200);
    echo json_encode(array_map('_formatPayment', $rows));

} elseif ($method === 'POST') {
    $data = json_decode(file_get_contents('php://input'));

    $payerId     = isset($data->payer_id)    ? (int)$data->payer_id    : 0;
    $payeeId     = isset($data->payee_id)    ? (int)$data->payee_id    : 0;
    $propertyId  = isset($data->property_id) ? (int)$data->property_id : null;
    $contractId  = isset($data->contract_id) ? (int)$data->contract_id : null;
    $amount      = isset($data->amount)      ? (float)$data->amount    : 0;
    $method_pay  = isset($data->method)      ? trim($data->method)     : 'credit_card';
    $notes       = isset($data->notes)       ? trim($data->notes)      : '';

    if (!$payerId || !$payeeId || !$amount) {
        http_response_code(400);
        echo json_encode(['message' => 'payer_id, payee_id, amount required']);
        exit();
    }

    $transactionId = 'TXN-' . strtoupper(uniqid()) . '-' . rand(1000, 9999);

    $methodMap = [
        'creditCard'   => 'credit_card',
        'bankTransfer' => 'bank_transfer',
        'stcPay'       => 'stc_pay',
        'applePay'     => 'apple_pay',
        'googlePay'    => 'apple_pay',
        'qrCode'       => 'qr_code',
    ];
    $dbMethod = $methodMap[$method_pay] ?? $method_pay;

    $qrPayload = json_encode([
        'transaction_id' => $transactionId,
        'amount'         => $amount,
        'property_id'    => $propertyId,
        'payer_id'       => $payerId,
        'paid_at'        => date('Y-m-d H:i:s'),
    ]);

    $stmt = $conn->prepare("
        INSERT INTO payments
            (transaction_id, contract_id, payer_id, payee_id, property_id, amount, method, status, qr_payload, notes, paid_at)
        VALUES
            (:txn, :cid, :pid, :sid, :prop, :amount, :method, 'completed', :qr, :notes, NOW())
    ");
    $stmt->execute([
        ':txn'    => $transactionId,
        ':cid'    => $contractId,
        ':pid'    => $payerId,
        ':sid'    => $payeeId,
        ':prop'   => $propertyId,
        ':amount' => $amount,
        ':method' => $dbMethod,
        ':qr'     => $qrPayload,
        ':notes'  => $notes,
    ]);
    $newId = $conn->lastInsertId();

    if ($contractId) {
        $conn->prepare("UPDATE contracts SET status = 'signed' WHERE id = :id")
             ->execute([':id' => $contractId]);
    }

    $stmt2 = $conn->prepare("
        SELECT py.*, p.title AS property_title,
               b.name AS payer_name, s.name AS payee_name
        FROM payments py
        LEFT JOIN properties p ON p.id = py.property_id
        JOIN users b ON b.id = py.payer_id
        JOIN users s ON s.id = py.payee_id
        WHERE py.id = :id
    ");
    $stmt2->execute([':id' => $newId]);
    $row = $stmt2->fetch(PDO::FETCH_ASSOC);

    http_response_code(201);
    echo json_encode(_formatPayment($row));

} else {
    http_response_code(405);
    echo json_encode(['message' => 'Method not allowed']);
}

function _formatPayment(array $row): array {
    return [
        'id'             => (int)$row['id'],
        'transaction_id' => $row['transaction_id'],
        'contract_id'    => $row['contract_id'] ? (int)$row['contract_id'] : null,
        'payer_id'       => (int)$row['payer_id'],
        'payee_id'       => (int)$row['payee_id'],
        'property_id'    => $row['property_id'] ? (int)$row['property_id'] : null,
        'property_title' => $row['property_title'] ?? '',
        'payer_name'     => $row['payer_name'] ?? '',
        'payee_name'     => $row['payee_name'] ?? '',
        'amount'         => (float)$row['amount'],
        'currency'       => $row['currency'] ?? 'SAR',
        'method'         => $row['method'],
        'status'         => $row['status'],
        'qr_payload'     => $row['qr_payload'],
        'notes'          => $row['notes'],
        'paid_at'        => $row['paid_at'],
        'created_at'     => $row['created_at'],
    ];
}
?>
