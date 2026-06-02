<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$host     = 'localhost';
$db_name  = 'smart_real_estate';
$username = 'root';
$password = 'root';

$results = [];

// 1. Test DB connection
try {
    $conn = new PDO(
        "mysql:host={$host};dbname={$db_name};charset=utf8mb4",
        $username, $password,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
    $results['db_connection'] = 'OK';
} catch (PDOException $e) {
    $results['db_connection'] = 'FAILED: ' . $e->getMessage();
    echo json_encode($results, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit();
}

// 2. Test users table
try {
    $stmt = $conn->query("SELECT COUNT(*) as total FROM users");
    $row  = $stmt->fetch(PDO::FETCH_ASSOC);
    $results['users_count'] = (int)$row['total'];
} catch (PDOException $e) {
    $results['users_count'] = 'FAILED: ' . $e->getMessage();
}

// 3. Test UPDATE (write test - update bio then revert)
try {
    $stmt = $conn->prepare("SELECT bio FROM users WHERE id = 1");
    $stmt->execute();
    $oldBio = $stmt->fetchColumn();

    $newBio = 'test_' . time();
    $upd = $conn->prepare("UPDATE users SET bio = :bio WHERE id = 1");
    $upd->execute([':bio' => $newBio]);

    $stmt2 = $conn->prepare("SELECT bio FROM users WHERE id = 1");
    $stmt2->execute();
    $updatedBio = $stmt2->fetchColumn();

    $rev = $conn->prepare("UPDATE users SET bio = :bio WHERE id = 1");
    $rev->execute([':bio' => $oldBio]);

    $results['update_test'] = ($updatedBio === $newBio)
        ? 'OK - DB write works!'
        : 'FAILED - value did not change';
} catch (PDOException $e) {
    $results['update_test'] = 'FAILED: ' . $e->getMessage();
}

// 4. Test password verification
try {
    $stmt = $conn->prepare("SELECT password_hash FROM users WHERE email = 'admin@aqari.com'");
    $stmt->execute();
    $hash = $stmt->fetchColumn();
    $results['password_hash_preview']  = $hash ? substr($hash, 0, 20) . '...' : 'NOT FOUND';
    $results['verify_password']        = password_verify('password', $hash)    ? 'password=OK'    : 'password=FAIL';
    $results['verify_password123']     = password_verify('password123', $hash) ? 'password123=OK' : 'password123=FAIL';
} catch (PDOException $e) {
    $results['password_check'] = 'FAILED: ' . $e->getMessage();
}

// 5. Server info
$results['php_version']    = PHP_VERSION;
$results['server_name']    = $_SERVER['SERVER_NAME'] ?? 'unknown';
$results['document_root']  = $_SERVER['DOCUMENT_ROOT'] ?? 'unknown';
$results['put_api_url']    = 'http://' . ($_SERVER['HTTP_HOST'] ?? 'localhost')
                           . '/Smart%20Real%20Estate%20Platform1/php_backend/api/users/index.php';

echo json_encode($results, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
?>
