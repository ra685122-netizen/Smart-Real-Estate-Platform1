<?php
require_once '../../config/db.php';

function safeCount(PDO $conn, string $sql): int {
    try { return (int)$conn->query($sql)->fetchColumn(); }
    catch (PDOException $e) { return 0; }
}

$totalProperties = safeCount($conn, "SELECT COUNT(*) FROM properties");
$activeListings  = safeCount($conn, "SELECT COUNT(*) FROM properties WHERE status = 'available' AND admin_approved = 1");
$totalUsers      = safeCount($conn, "SELECT COUNT(*) FROM users");
$totalReviews    = safeCount($conn, "SELECT COUNT(*) FROM reviews");
$soldProperties  = safeCount($conn, "SELECT COUNT(*) FROM properties WHERE status = 'sold'");
$pendingApproval = safeCount($conn, "SELECT COUNT(*) FROM properties WHERE admin_approved = 0");
$monthlyViews    = safeCount($conn, "SELECT COUNT(*) FROM property_views WHERE viewed_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)");
$totalMessages   = safeCount($conn, "SELECT COUNT(*) FROM messages");

http_response_code(200);
echo json_encode([
    'totalProperties'  => $totalProperties,
    'activeListings'   => $activeListings,
    'totalUsers'       => $totalUsers,
    'totalReviews'     => $totalReviews,
    'soldProperties'   => $soldProperties,
    'pendingApproval'  => $pendingApproval,
    'monthlyViews'     => $monthlyViews,
    'monthlyInquiries' => $totalMessages,
    'revenue'          => 0,
]);
?>
