<?php
$host     = 'localhost';
$db_name  = 'smart_real_estate';
$username = 'root';
$password = 'root';

try {
    $conn = new PDO("mysql:host={$host};dbname={$db_name};charset=utf8mb4", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);
} catch (PDOException $e) {
    die("Connection error: " . $e->getMessage() . "\n");
}

$users = [
    ['name' => 'Admin User',        'email' => 'admin@aqari.com',    'role' => 'admin'],
    ['name' => 'Ahmed Al-Malki',    'email' => 'ahmed@aqari.com',    'role' => 'owner'],
    ['name' => 'Sara Al-Zahrani',   'email' => 'sara@aqari.com',     'role' => 'buyer'],
    ['name' => 'Fatima Al-Otaibi',  'email' => 'fatima@aqari.com',   'role' => 'tenant'],
    ['name' => 'Mohammed Seller',   'email' => 'seller@aqari.com',   'role' => 'seller'],
];

$sql = "INSERT INTO users (name, email, password_hash, role, is_verified, is_active)
        VALUES (:name, :email, :hash, :role, 1, 1)
        ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash), name = VALUES(name), is_active = 1";

$stmt = $conn->prepare($sql);
$hash = password_hash('password123', PASSWORD_BCRYPT);

foreach ($users as $u) {
    $stmt->execute([
        ':name'  => $u['name'],
        ':email' => $u['email'],
        ':hash'  => $hash,
        ':role'  => $u['role'],
    ]);
    echo "Inserted/Updated: {$u['email']} | role: {$u['role']}\n";
}

echo "\nDone! All users password: password123\n";
echo "Test accounts:\n";
echo "  admin@aqari.com  / password123  (admin)\n";
echo "  ahmed@aqari.com  / password123  (owner)\n";
echo "  sara@aqari.com   / password123  (buyer)\n";
echo "  fatima@aqari.com / password123  (tenant)\n";
echo "  seller@aqari.com / password123  (seller)\n";
?>
