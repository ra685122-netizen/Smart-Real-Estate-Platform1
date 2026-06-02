<?php
header("Content-Type: text/html; charset=UTF-8");
$host     = 'localhost';
$username = 'root';
$password = 'root';
$dbName   = 'smart_real_estate';

echo "<h2>🔧 Smart Real Estate — DB Setup</h2>";

try {
    $conn = new PDO("mysql:host={$host};charset=utf8mb4", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);

    $conn->exec("CREATE DATABASE IF NOT EXISTS `{$dbName}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    $conn->exec("USE `{$dbName}`");
    echo "<p>✅ Database <b>{$dbName}</b> ready</p>";

    $schemaFile = __DIR__ . '/database/schema.sql';
    if (file_exists($schemaFile)) {
        $sql = file_get_contents($schemaFile);
        $sql = str_replace("CREATE DATABASE IF NOT EXISTS smart_real_estate", "-- skip create db", $sql);
        $sql = str_replace("USE smart_real_estate;", "-- skip use", $sql);

        foreach (explode(';', $sql) as $stmt) {
            $stmt = trim($stmt);
            if (empty($stmt) || strpos($stmt, '--') === 0) continue;
            try {
                $conn->exec($stmt);
            } catch (PDOException $e) {
                echo "<p>⚠️ " . htmlspecialchars($e->getMessage()) . "</p>";
            }
        }
        echo "<p>✅ Schema applied from schema.sql</p>";
    } else {
        echo "<p>⚠️ schema.sql not found — creating essential tables manually</p>";
    }

    $tables = $conn->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
    echo "<p>📋 Tables: <b>" . implode(', ', $tables) . "</b></p>";

    $userCount = (int)$conn->query("SELECT COUNT(*) FROM users")->fetchColumn();
    echo "<p>👤 Users in DB: <b>{$userCount}</b></p>";

    if ($userCount === 0) {
        $hash = password_hash('password', PASSWORD_BCRYPT);
        $conn->exec("INSERT INTO users (name, email, password_hash, role, is_verified, is_active) VALUES
            ('Admin User',       'admin@aqari.com',   '{$hash}', 'admin',  1, 1),
            ('Ahmed Al-Malki',   'ahmed@aqari.com',   '{$hash}', 'owner',  1, 1),
            ('Sara Al-Zahrani',  'sara@aqari.com',    '{$hash}', 'buyer',  1, 1),
            ('Fatima Al-Otaibi', 'fatima@aqari.com',  '{$hash}', 'tenant', 1, 1),
            ('Mohammed Seller',  'seller@aqari.com',  '{$hash}', 'seller', 1, 1)
        ");
        echo "<p>✅ Seeded 5 test users (password: <b>password</b>)</p>";
    } else {
        echo "<p>ℹ️ Users already exist — skipping seed</p>";

        $stmt = $conn->prepare("SELECT email, password_hash FROM users WHERE email = 'admin@aqari.com' LIMIT 1");
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row) {
            $pwdOk  = password_verify('password',    $row['password_hash']) ? '✅ password=OK'    : '❌ password=FAIL';
            $pwd123 = password_verify('password123', $row['password_hash']) ? '✅ password123=OK' : '❌ password123=FAIL';
            echo "<p>🔑 Admin password check: <b>{$pwdOk}</b> | <b>{$pwd123}</b></p>";
        }
    }

    $hash2 = password_hash('password', PASSWORD_BCRYPT);
    $conn->exec("UPDATE users SET password_hash = '{$hash2}' WHERE password_hash LIKE '\$2y\$10\$92IXUNpkjO0rOQ5byMi%'");
    $affected = $conn->query("SELECT ROW_COUNT()")->fetchColumn();
    if ($affected > 0) {
        echo "<p>🔄 Updated {$affected} user(s) with Laravel default hash → valid bcrypt for <b>password</b></p>";
    }

    echo "<h3>✅ Setup Complete!</h3>";
    echo "<p>Test accounts (all use password: <b>password</b>):</p>";
    echo "<ul>";
    echo "<li>admin@aqari.com</li>";
    echo "<li>ahmed@aqari.com</li>";
    echo "<li>sara@aqari.com</li>";
    echo "<li>fatima@aqari.com</li>";
    echo "<li>seller@aqari.com</li>";
    echo "</ul>";
    echo "<p>🔗 Test API: <a href='/Smart%20Real%20Estate%20Platform1/php_backend/test_api.php'>test_api.php</a></p>";

} catch (PDOException $e) {
    echo "<p>❌ <b>DB Error:</b> " . htmlspecialchars($e->getMessage()) . "</p>";
}
?>
