<?php
require_once '../config/db.php';

echo "<h2>Smart Real Estate Platform — Database Seeder</h2>";
echo "<hr>";

function insertIfNotExists(PDO $conn, string $table, string $checkCol, string $checkVal, string $sql, array $params): int {
    $check = $conn->prepare("SELECT id FROM `$table` WHERE `$checkCol` = :val LIMIT 1");
    $check->execute([':val' => $checkVal]);
    if ($check->rowCount() > 0) {
        $row = $check->fetch(PDO::FETCH_ASSOC);
        echo "[$table] Already exists: $checkVal<br>";
        return (int)$row['id'];
    }
    $stmt = $conn->prepare($sql);
    $stmt->execute($params);
    $id = (int)$conn->lastInsertId();
    echo "[$table] Inserted: $checkVal (id=$id)<br>";
    return $id;
}

try {
    $conn->exec("SET FOREIGN_KEY_CHECKS = 0");

    // ============================================================
    // TRUNCATE ALL TABLES (clean slate)
    // ============================================================
    $tables = [
        'payment_verifications','payments','contract_signatures','contracts',
        'market_stats','price_alerts',
        'search_history','property_views','user_preferences',
        'appointments','notifications','messages',
        'conversation_participants','conversations',
        'reviews','favorites','property_features',
        'property_images','properties','agencies','users'
    ];
    foreach ($tables as $t) {
        $conn->exec("TRUNCATE TABLE `$t`");
    }
    $conn->exec("SET FOREIGN_KEY_CHECKS = 1");
    echo "<b>All tables truncated.</b><br><hr>";

    // ============================================================
    // 1. USERS
    // ============================================================
    echo "<h3>Seeding Users...</h3>";

    $users = [
        ['name' => 'Admin User',        'email' => 'admin@aqari.com',       'role' => 'admin',   'phone' => '+966500000001'],
        ['name' => 'Ahmed Al-Malki',     'email' => 'ahmed@aqari.com',       'role' => 'owner',   'phone' => '+966500000002'],
        ['name' => 'Sara Al-Zahrani',    'email' => 'sara@aqari.com',        'role' => 'buyer',   'phone' => '+966500000003'],
        ['name' => 'Khalid Real Estate', 'email' => 'khalid@aqari.com',      'role' => 'agency',  'phone' => '+966500000004'],
        ['name' => 'Fatima Al-Otaibi',   'email' => 'fatima@aqari.com',      'role' => 'tenant',  'phone' => '+966500000005'],
        ['name' => 'Mohammed Al-Ghamdi', 'email' => 'mohammed@aqari.com',    'role' => 'seller',  'phone' => '+966500000006'],
        ['name' => 'Nora Al-Rashidi',    'email' => 'nora@aqari.com',        'role' => 'buyer',   'phone' => '+966500000007'],
        ['name' => 'Omar Al-Shehri',     'email' => 'omar@aqari.com',        'role' => 'owner',   'phone' => '+966500000008'],
    ];

    $userIds = [];
    $insertUserSql = "INSERT INTO users (name, email, password_hash, role, phone, is_verified, is_active) 
                      VALUES (:name, :email, :hash, :role, :phone, 1, 1)";

    foreach ($users as $u) {
        $check = $conn->prepare("SELECT id FROM users WHERE email = :email");
        $check->execute([':email' => $u['email']]);
        if ($check->rowCount() > 0) {
            $row = $check->fetch(PDO::FETCH_ASSOC);
            $userIds[$u['role'] === 'admin' ? 'admin' : $u['email']] = (int)$row['id'];
            echo "[users] Already exists: {$u['email']}<br>";
        } else {
            $stmt = $conn->prepare($insertUserSql);
            $stmt->execute([
                ':name'  => $u['name'],
                ':email' => $u['email'],
                ':hash'  => password_hash('password123', PASSWORD_BCRYPT),
                ':role'  => $u['role'],
                ':phone' => $u['phone'],
            ]);
            $id = (int)$conn->lastInsertId();
            $userIds[$u['email']] = $id;
            echo "[users] Inserted: {$u['email']} (id=$id)<br>";
        }
    }

    $adminId    = $userIds['admin@aqari.com'];
    $owner1Id   = $userIds['ahmed@aqari.com'];
    $buyer1Id   = $userIds['sara@aqari.com'];
    $agencyUId  = $userIds['khalid@aqari.com'];
    $tenant1Id  = $userIds['fatima@aqari.com'];
    $seller1Id  = $userIds['mohammed@aqari.com'];
    $buyer2Id   = $userIds['nora@aqari.com'];
    $owner2Id   = $userIds['omar@aqari.com'];

    // ============================================================
    // 2. AGENCIES
    // ============================================================
    echo "<h3>Seeding Agencies...</h3>";

    $agencyStmt = $conn->prepare(
        "INSERT INTO agencies (user_id, agency_name, license_number, description, city, rating_avg, total_reviews, is_verified)
         VALUES (:uid, :name, :lic, :desc, :city, :rating, :total, 1)"
    );
    $agencyStmt->execute([
        ':uid'    => $agencyUId,
        ':name'   => 'Khalid Real Estate Co.',
        ':lic'    => 'KSA-RE-2024-00412',
        ':desc'   => 'Leading real estate agency in Riyadh with over 15 years of experience in residential and commercial properties.',
        ':city'   => 'Riyadh',
        ':rating' => 4.70,
        ':total'  => 128,
    ]);
    $agencyId = (int)$conn->lastInsertId();
    echo "[agencies] Inserted: Khalid Real Estate Co. (id=$agencyId)<br>";

    // ============================================================
    // 3. PROPERTIES
    // ============================================================
    echo "<h3>Seeding Properties...</h3>";

    $properties = [
        [
            'owner_id'         => $owner1Id,
            'title'            => 'Luxury Villa with Private Pool',
            'description'      => 'A stunning 5-bedroom villa with a private swimming pool, landscaped garden, and state-of-the-art smart home features. Perfect for families seeking luxury living in Riyadh.',
            'price'            => 2500000.00,
            'listing_type'     => 'sale',
            'property_type'    => 'villa',
            'location'         => 'Riyadh, Al-Malqa District',
            'city'             => 'Riyadh',
            'district'         => 'Al-Malqa',
            'status'           => 'available',
            'bedrooms'         => 5,
            'bathrooms'        => 4,
            'area'             => 600.00,
            'floor'            => null,
            'total_floors'     => 2,
            'year_built'       => 2021,
            'is_furnished'     => 1,
            'latitude'         => 24.8130,
            'longitude'        => 46.6110,
            'virtual_tour_url' => 'https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=600&auto=format&fit=crop',
            'is_featured'      => 1,
        ],
        [
            'owner_id'         => $owner1Id,
            'title'            => 'Modern Downtown Apartment',
            'description'      => 'A sleek 2-bedroom apartment in the heart of Jeddah. Walking distance to malls, restaurants, and public transit. City views from every room.',
            'price'            => 850000.00,
            'listing_type'     => 'sale',
            'property_type'    => 'apartment',
            'location'         => 'Jeddah, Al-Balad',
            'city'             => 'Jeddah',
            'district'         => 'Al-Balad',
            'status'           => 'available',
            'bedrooms'         => 2,
            'bathrooms'        => 2,
            'area'             => 145.00,
            'floor'            => 8,
            'total_floors'     => 20,
            'year_built'       => 2020,
            'is_furnished'     => 0,
            'latitude'         => 21.4858,
            'longitude'        => 39.1925,
            'virtual_tour_url' => 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=600&auto=format&fit=crop',
            'is_featured'      => 1,
        ],
        [
            'owner_id'         => $seller1Id,
            'title'            => 'Prime Commercial Office Space',
            'description'      => 'Large open-plan office space ideal for startups or established businesses. High-speed fibre internet, dedicated parking, 24/7 security.',
            'price'            => 120000.00,
            'listing_type'     => 'rent',
            'property_type'    => 'commercial',
            'location'         => 'Dammam, King Fahd Road',
            'city'             => 'Dammam',
            'district'         => 'Al-Faisaliyah',
            'status'           => 'available',
            'bedrooms'         => 0,
            'bathrooms'        => 2,
            'area'             => 280.00,
            'floor'            => 4,
            'total_floors'     => 10,
            'year_built'       => 2019,
            'is_furnished'     => 1,
            'latitude'         => 26.4207,
            'longitude'        => 50.0888,
            'virtual_tour_url' => 'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop',
            'is_featured'      => 0,
        ],
        [
            'owner_id'         => $owner2Id,
            'title'            => 'Cozy Family Townhouse',
            'description'      => 'Quiet residential neighborhood, 3 bedrooms, fully renovated kitchen, private backyard with garden. Excellent schools nearby.',
            'price'            => 1150000.00,
            'listing_type'     => 'sale',
            'property_type'    => 'villa',
            'location'         => 'Riyadh, Al-Yasmin',
            'city'             => 'Riyadh',
            'district'         => 'Al-Yasmin',
            'status'           => 'available',
            'bedrooms'         => 3,
            'bathrooms'        => 3,
            'area'             => 320.00,
            'floor'            => null,
            'total_floors'     => 2,
            'year_built'       => 2018,
            'is_furnished'     => 0,
            'latitude'         => 24.8190,
            'longitude'        => 46.6430,
            'virtual_tour_url' => 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=600&auto=format&fit=crop',
            'is_featured'      => 0,
        ],
        [
            'owner_id'         => $owner2Id,
            'title'            => 'Sea View Penthouse — Jeddah Corniche',
            'description'      => 'Exclusive penthouse with panoramic Red Sea views. Private elevator, rooftop terrace, infinity pool access, and concierge service.',
            'price'            => 4200000.00,
            'listing_type'     => 'sale',
            'property_type'    => 'apartment',
            'location'         => 'Jeddah, Corniche',
            'city'             => 'Jeddah',
            'district'         => 'Al-Corniche',
            'status'           => 'available',
            'bedrooms'         => 4,
            'bathrooms'        => 4,
            'area'             => 380.00,
            'floor'            => 25,
            'total_floors'     => 25,
            'year_built'       => 2022,
            'is_furnished'     => 1,
            'latitude'         => 21.5645,
            'longitude'        => 39.1350,
            'virtual_tour_url' => 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=600&auto=format&fit=crop',
            'is_featured'      => 1,
        ],
        [
            'owner_id'         => $seller1Id,
            'title'            => 'Investment Land — North Riyadh',
            'description'      => 'Flat, fully documented land in a fast-growing area of North Riyadh. Zoned for residential development. Utilities connected to the boundary.',
            'price'            => 3800000.00,
            'listing_type'     => 'sale',
            'property_type'    => 'land',
            'location'         => 'Riyadh, North Ring Road',
            'city'             => 'Riyadh',
            'district'         => 'Al-Narjis',
            'status'           => 'available',
            'bedrooms'         => 0,
            'bathrooms'        => 0,
            'area'             => 1200.00,
            'floor'            => null,
            'total_floors'     => null,
            'year_built'       => null,
            'is_furnished'     => 0,
            'latitude'         => 24.8750,
            'longitude'        => 46.7100,
            'virtual_tour_url' => 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=600&auto=format&fit=crop',
            'is_featured'      => 0,
        ],
        [
            'owner_id'         => $owner1Id,
            'title'            => 'Furnished Studio — Near KAUST',
            'description'      => 'Fully furnished studio apartment near King Abdullah University. Ideal for students or young professionals. All utilities included in rent.',
            'price'            => 35000.00,
            'listing_type'     => 'rent',
            'property_type'    => 'apartment',
            'location'         => 'Thuwal, KAUST Area',
            'city'             => 'Thuwal',
            'district'         => 'University District',
            'status'           => 'available',
            'bedrooms'         => 1,
            'bathrooms'        => 1,
            'area'             => 55.00,
            'floor'            => 3,
            'total_floors'     => 6,
            'year_built'       => 2017,
            'is_furnished'     => 1,
            'latitude'         => 22.3003,
            'longitude'        => 39.1027,
            'virtual_tour_url' => 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=600&auto=format&fit=crop',
            'is_featured'      => 0,
        ],
        [
            'owner_id'         => $owner2Id,
            'title'            => 'Executive Office Suite — Olaya Tower',
            'description'      => 'Premium executive office in Olaya Tower with fully equipped meeting rooms, reception, and panoramic city views. Flexible lease terms.',
            'price'            => 85000.00,
            'listing_type'     => 'rent',
            'property_type'    => 'office',
            'location'         => 'Riyadh, Olaya District',
            'city'             => 'Riyadh',
            'district'         => 'Olaya',
            'status'           => 'available',
            'bedrooms'         => 0,
            'bathrooms'        => 1,
            'area'             => 120.00,
            'floor'            => 18,
            'total_floors'     => 35,
            'year_built'       => 2016,
            'is_furnished'     => 1,
            'latitude'         => 24.6938,
            'longitude'        => 46.6853,
            'virtual_tour_url' => 'https://images.unsplash.com/photo-1497366811353-6870744d04b2?q=80&w=600&auto=format&fit=crop',
            'is_featured'      => 1,
        ],
    ];

    $propSql = "INSERT INTO properties 
        (owner_id, title, description, price, listing_type, property_type,
         location, city, district, status, bedrooms, bathrooms, area,
         floor, total_floors, year_built, is_furnished, latitude, longitude,
         virtual_tour_url, is_featured, admin_approved)
        VALUES
        (:owner_id,:title,:description,:price,:listing_type,:property_type,
         :location,:city,:district,:status,:bedrooms,:bathrooms,:area,
         :floor,:total_floors,:year_built,:is_furnished,:latitude,:longitude,
         :virtual_tour_url,:is_featured,1)";

    $propStmt = $conn->prepare($propSql);
    $propertyIds = [];

    foreach ($properties as $p) {
        $propStmt->execute($p);
        $pid = (int)$conn->lastInsertId();
        $propertyIds[] = $pid;
        echo "[properties] Inserted: {$p['title']} (id=$pid)<br>";
    }

    // ============================================================
    // 4. PROPERTY IMAGES
    // ============================================================
    echo "<h3>Seeding Property Images...</h3>";

    $imageData = [
        $propertyIds[0] => [
            ['https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=800&auto=format&fit=crop', 1, 0],
            ['https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?q=80&w=800&auto=format&fit=crop', 0, 1],
            ['https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?q=80&w=800&auto=format&fit=crop', 0, 2],
        ],
        $propertyIds[1] => [
            ['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=800&auto=format&fit=crop', 1, 0],
            ['https://images.unsplash.com/photo-1502672023488-70e25813eb80?q=80&w=800&auto=format&fit=crop', 0, 1],
        ],
        $propertyIds[2] => [
            ['https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=800&auto=format&fit=crop', 1, 0],
            ['https://images.unsplash.com/photo-1497366754035-f200968a6e72?q=80&w=800&auto=format&fit=crop', 0, 1],
        ],
        $propertyIds[3] => [
            ['https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=800&auto=format&fit=crop', 1, 0],
            ['https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=800&auto=format&fit=crop', 0, 1],
        ],
        $propertyIds[4] => [
            ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=800&auto=format&fit=crop', 1, 0],
            ['https://images.unsplash.com/photo-1512918728672-1e37e9d4e3f5?q=80&w=800&auto=format&fit=crop', 0, 1],
            ['https://images.unsplash.com/photo-1600210491892-03d54c0aaf87?q=80&w=800&auto=format&fit=crop', 0, 2],
        ],
        $propertyIds[5] => [
            ['https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=800&auto=format&fit=crop', 1, 0],
        ],
        $propertyIds[6] => [
            ['https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=800&auto=format&fit=crop', 1, 0],
        ],
        $propertyIds[7] => [
            ['https://images.unsplash.com/photo-1497366811353-6870744d04b2?q=80&w=800&auto=format&fit=crop', 1, 0],
            ['https://images.unsplash.com/photo-1497366754035-f200968a6e72?q=80&w=800&auto=format&fit=crop', 0, 1],
        ],
    ];

    $imgStmt = $conn->prepare("INSERT INTO property_images (property_id, image_url, is_primary, sort_order) VALUES (:pid, :url, :primary, :sort)");
    foreach ($imageData as $pid => $images) {
        foreach ($images as [$url, $isPrimary, $sort]) {
            $imgStmt->execute([':pid' => $pid, ':url' => $url, ':primary' => $isPrimary, ':sort' => $sort]);
        }
    }
    echo "[property_images] Inserted images for " . count($imageData) . " properties.<br>";

    // ============================================================
    // 5. PROPERTY FEATURES
    // ============================================================
    echo "<h3>Seeding Property Features...</h3>";

    $featuresData = [
        $propertyIds[0] => ['Swimming Pool', 'Garden', 'Smart Home', 'Security System', 'Parking (3 Cars)', 'Gym', 'Maids Room'],
        $propertyIds[1] => ['City View', 'Elevator', 'Parking', 'Gym', 'Concierge'],
        $propertyIds[2] => ['High-Speed Internet', 'Parking (10 Cars)', '24/7 Security', 'Meeting Rooms', 'Reception Area'],
        $propertyIds[3] => ['Garden', 'Parking', 'Storage Room', 'Barbecue Area'],
        $propertyIds[4] => ['Sea View', 'Private Elevator', 'Rooftop Terrace', 'Infinity Pool', 'Concierge', 'Smart Home', 'Parking'],
        $propertyIds[5] => ['Utilities Connected', 'Street Access', 'Flat Terrain'],
        $propertyIds[6] => ['Fully Furnished', 'Internet Included', 'Utilities Included', 'Elevator', 'Security'],
        $propertyIds[7] => ['Panoramic City View', 'Meeting Rooms', 'Reception', 'Elevator', 'Parking', 'High-Speed Internet'],
    ];

    $featStmt = $conn->prepare("INSERT INTO property_features (property_id, feature_name) VALUES (:pid, :feature)");
    foreach ($featuresData as $pid => $features) {
        foreach ($features as $feature) {
            $featStmt->execute([':pid' => $pid, ':feature' => $feature]);
        }
    }
    echo "[property_features] Inserted features for " . count($featuresData) . " properties.<br>";

    // ============================================================
    // 6. FAVORITES
    // ============================================================
    echo "<h3>Seeding Favorites...</h3>";

    $favs = [
        [$buyer1Id,  $propertyIds[0]],
        [$buyer1Id,  $propertyIds[4]],
        [$buyer2Id,  $propertyIds[1]],
        [$buyer2Id,  $propertyIds[3]],
        [$tenant1Id, $propertyIds[6]],
    ];
    $favStmt = $conn->prepare("INSERT IGNORE INTO favorites (user_id, property_id) VALUES (:uid, :pid)");
    foreach ($favs as [$uid, $pid]) {
        $favStmt->execute([':uid' => $uid, ':pid' => $pid]);
    }
    echo "[favorites] Inserted " . count($favs) . " favorites.<br>";

    // ============================================================
    // 7. REVIEWS
    // ============================================================
    echo "<h3>Seeding Reviews...</h3>";

    $reviews = [
        [$buyer1Id,  $propertyIds[0], null,     5, 'Absolutely stunning villa! The pool and garden are breathtaking. Highly recommend.'],
        [$buyer2Id,  $propertyIds[1], null,     4, 'Great location and modern design. A bit pricey but worth it.'],
        [$tenant1Id, $propertyIds[6], null,     5, 'Perfect studio, very clean and close to campus. Will renew next year.'],
        [$buyer1Id,  null,            $agencyId, 5, 'Khalid Real Estate was incredibly professional and found us the perfect home quickly.'],
        [$buyer2Id,  null,            $agencyId, 4, 'Very responsive and knowledgeable. Made the buying process smooth.'],
        [$seller1Id, $propertyIds[4], null,     5, 'The penthouse is truly world-class. Exceptional sea views.'],
    ];

    $revStmt = $conn->prepare(
        "INSERT INTO reviews (user_id, property_id, agency_id, rating, comment) VALUES (:uid, :pid, :aid, :rating, :comment)"
    );
    foreach ($reviews as [$uid, $pid, $aid, $rating, $comment]) {
        $revStmt->execute([':uid' => $uid, ':pid' => $pid, ':aid' => $aid, ':rating' => $rating, ':comment' => $comment]);
    }
    echo "[reviews] Inserted " . count($reviews) . " reviews.<br>";

    // Update agency rating_avg
    $conn->exec(
        "UPDATE agencies SET rating_avg = (
            SELECT ROUND(AVG(rating), 2) FROM reviews WHERE agency_id = $agencyId
         ), total_reviews = (
            SELECT COUNT(*) FROM reviews WHERE agency_id = $agencyId
         ) WHERE id = $agencyId"
    );
    echo "[agencies] Updated rating averages.<br>";

    // ============================================================
    // 8. CONVERSATIONS & MESSAGES
    // ============================================================
    echo "<h3>Seeding Conversations & Messages...</h3>";

    $convStmt = $conn->prepare("INSERT INTO conversations (property_id) VALUES (:pid)");

    $convStmt->execute([':pid' => $propertyIds[0]]);
    $conv1 = (int)$conn->lastInsertId();

    $convStmt->execute([':pid' => $propertyIds[1]]);
    $conv2 = (int)$conn->lastInsertId();

    $partStmt = $conn->prepare("INSERT INTO conversation_participants (conversation_id, user_id) VALUES (:cid, :uid)");
    foreach ([[$conv1, $buyer1Id], [$conv1, $owner1Id], [$conv2, $buyer2Id], [$conv2, $owner1Id]] as [$cid, $uid]) {
        $partStmt->execute([':cid' => $cid, ':uid' => $uid]);
    }

    $msgStmt = $conn->prepare("INSERT INTO messages (conversation_id, sender_id, message, is_read) VALUES (:cid, :sid, :msg, :read)");
    $msgData = [
        [$conv1, $buyer1Id,  'Hello, is the villa still available for viewing this weekend?',        0],
        [$conv1, $owner1Id,  'Yes, it is! Are you available Saturday at 10 AM?',                    0],
        [$conv1, $buyer1Id,  'Perfect, Saturday 10 AM works great for me. See you then!',            1],
        [$conv2, $buyer2Id,  'Hi, I am interested in the downtown apartment. Can you share more details?', 0],
        [$conv2, $owner1Id,  'Sure! The apartment is on the 8th floor with full city views. Would you like a tour?', 0],
    ];
    foreach ($msgData as [$cid, $sid, $msg, $read]) {
        $msgStmt->execute([':cid' => $cid, ':sid' => $sid, ':msg' => $msg, ':read' => $read]);
    }
    echo "[conversations] Inserted 2 conversations with " . count($msgData) . " messages.<br>";

    // ============================================================
    // 9. NOTIFICATIONS
    // ============================================================
    echo "<h3>Seeding Notifications...</h3>";

    $notifData = [
        [$buyer1Id,  'New Message',         'Ahmed replied to your inquiry about the Luxury Villa.',         'message',     $propertyIds[0]],
        [$owner1Id,  'New Appointment',      'Sara Al-Zahrani requested a viewing for Luxury Villa with Pool.', 'appointment', $propertyIds[0]],
        [$buyer2Id,  'Price Reduced!',       'Modern Downtown Apartment price has been reduced by 5%.',        'property',    $propertyIds[1]],
        [$adminId,   'New Property Pending', 'A new property listing requires your approval.',                 'system',      null],
        [$tenant1Id, 'Welcome to Aqari!',    'Your account has been verified. Start exploring properties now.','system',      null],
        [$seller1Id, 'New Review',           'Someone left a 5-star review on Sea View Penthouse.',            'review',      $propertyIds[4]],
    ];

    $notifStmt = $conn->prepare(
        "INSERT INTO notifications (user_id, title, body, type, reference_id) VALUES (:uid, :title, :body, :type, :ref)"
    );
    foreach ($notifData as [$uid, $title, $body, $type, $ref]) {
        $notifStmt->execute([':uid' => $uid, ':title' => $title, ':body' => $body, ':type' => $type, ':ref' => $ref]);
    }
    echo "[notifications] Inserted " . count($notifData) . " notifications.<br>";

    // ============================================================
    // 10. APPOINTMENTS
    // ============================================================
    echo "<h3>Seeding Appointments...</h3>";

    $aptData = [
        [$propertyIds[0], $buyer1Id,  $owner1Id, '2026-04-05', '10:00:00', 'confirmed', 'Please bring the property documents.'],
        [$propertyIds[1], $buyer2Id,  $owner1Id, '2026-04-07', '14:00:00', 'pending',   null],
        [$propertyIds[6], $tenant1Id, $owner1Id, '2026-04-03', '11:00:00', 'completed', 'Great viewing, very happy with the studio.'],
    ];

    $aptStmt = $conn->prepare(
        "INSERT INTO appointments (property_id, user_id, owner_id, appointment_date, appointment_time, status, notes)
         VALUES (:pid, :uid, :oid, :date, :time, :status, :notes)"
    );
    foreach ($aptData as [$pid, $uid, $oid, $date, $time, $status, $notes]) {
        $aptStmt->execute([':pid' => $pid, ':uid' => $uid, ':oid' => $oid, ':date' => $date, ':time' => $time, ':status' => $status, ':notes' => $notes]);
    }
    echo "[appointments] Inserted " . count($aptData) . " appointments.<br>";

    // ============================================================
    // 11. USER PREFERENCES
    // ============================================================
    echo "<h3>Seeding User Preferences...</h3>";

    $prefData = [
        [$buyer1Id,  '["villa","apartment"]', 'sale', 800000,   3000000,  200, 700, 3, '["Riyadh","Jeddah"]'],
        [$buyer2Id,  '["apartment"]',         'sale', 500000,   1500000,  100, 300, 2, '["Jeddah"]'],
        [$tenant1Id, '["apartment"]',         'rent', 20000,    60000,    40,  100, 1, '["Thuwal","Jeddah"]'],
    ];

    $prefStmt = $conn->prepare(
        "INSERT INTO user_preferences (user_id, preferred_types, preferred_listing, min_price, max_price, min_area, max_area, min_bedrooms, preferred_cities)
         VALUES (:uid, :types, :listing, :minp, :maxp, :mina, :maxa, :minb, :cities)"
    );
    foreach ($prefData as [$uid, $types, $listing, $minp, $maxp, $mina, $maxa, $minb, $cities]) {
        $prefStmt->execute([':uid' => $uid, ':types' => $types, ':listing' => $listing, ':minp' => $minp, ':maxp' => $maxp, ':mina' => $mina, ':maxa' => $maxa, ':minb' => $minb, ':cities' => $cities]);
    }
    echo "[user_preferences] Inserted " . count($prefData) . " preference records.<br>";

    // ============================================================
    // 12. PROPERTY VIEWS
    // ============================================================
    echo "<h3>Seeding Property Views...</h3>";

    $viewData = [
        [$propertyIds[0], $buyer1Id],
        [$propertyIds[0], $buyer2Id],
        [$propertyIds[0], null],
        [$propertyIds[1], $buyer1Id],
        [$propertyIds[1], $tenant1Id],
        [$propertyIds[4], $buyer1Id],
        [$propertyIds[4], $buyer2Id],
        [$propertyIds[4], null],
        [$propertyIds[6], $tenant1Id],
        [$propertyIds[6], null],
    ];

    $viewStmt = $conn->prepare("INSERT INTO property_views (property_id, user_id) VALUES (:pid, :uid)");
    foreach ($viewData as [$pid, $uid]) {
        $viewStmt->execute([':pid' => $pid, ':uid' => $uid]);
    }

    $conn->exec("UPDATE properties p SET views_count = (SELECT COUNT(*) FROM property_views pv WHERE pv.property_id = p.id)");
    echo "[property_views] Inserted " . count($viewData) . " view records & updated counts.<br>";

    // ============================================================
    // 13. SEARCH HISTORY
    // ============================================================
    echo "<h3>Seeding Search History...</h3>";

    $searchData = [
        [$buyer1Id,  'villa Riyadh',   '{"property_type":"villa","city":"Riyadh","min_price":1000000}',       3],
        [$buyer1Id,  'apartment pool', '{"property_type":"apartment","features":["Swimming Pool"]}',            2],
        [$buyer2Id,  'Jeddah sea view','{"city":"Jeddah","listing_type":"sale"}',                               5],
        [$tenant1Id, 'furnished studio','{"property_type":"apartment","listing_type":"rent","is_furnished":1}', 4],
    ];

    $searchStmt = $conn->prepare(
        "INSERT INTO search_history (user_id, search_query, filters, results_count) VALUES (:uid, :query, :filters, :count)"
    );
    foreach ($searchData as [$uid, $query, $filters, $count]) {
        $searchStmt->execute([':uid' => $uid, ':query' => $query, ':filters' => $filters, ':count' => $count]);
    }
    echo "[search_history] Inserted " . count($searchData) . " search records.<br>";

    // ============================================================
    // 14. PRICE ALERTS
    // ============================================================
    echo "<h3>Seeding Price Alerts...</h3>";

    $alertData = [
        [$buyer1Id,  $propertyIds[0], null,     'drop'],
        [$buyer1Id,  $propertyIds[4], 4000000,  'drop'],
        [$buyer2Id,  $propertyIds[1], null,     'any'],
        [$buyer2Id,  $propertyIds[4], 3800000,  'drop'],
        [$tenant1Id, $propertyIds[6], 30000,    'drop'],
    ];

    $alertStmt = $conn->prepare(
        "INSERT INTO price_alerts (user_id, property_id, alert_price, direction, is_active)
         VALUES (:uid, :pid, :price, :dir, 1)"
    );
    foreach ($alertData as [$uid, $pid, $price, $dir]) {
        $alertStmt->execute([':uid' => $uid, ':pid' => $pid, ':price' => $price, ':dir' => $dir]);
    }
    echo "[price_alerts] Inserted " . count($alertData) . " alert records.<br>";

    // ============================================================
    // 15. MARKET STATS
    // ============================================================
    echo "<h3>Seeding Market Stats...</h3>";

    $marketStats = [
        ['Riyadh',  'all',       'sale', 6850.00,  7.20, 312, 38, 1240, '2026-03-01'],
        ['Riyadh',  'apartment', 'sale', 5200.00,  5.40, 128, 30, 410,  '2026-03-01'],
        ['Riyadh',  'villa',     'sale', 8400.00,  9.10, 84,  45, 320,  '2026-03-01'],
        ['Riyadh',  'all',       'rent', 3200.00,  4.80, 180, 22, 860,  '2026-03-01'],
        ['Jeddah',  'all',       'sale', 7200.00,  6.50, 245, 35, 980,  '2026-03-01'],
        ['Jeddah',  'apartment', 'sale', 6100.00,  8.20, 110, 28, 390,  '2026-03-01'],
        ['Jeddah',  'all',       'rent', 3800.00,  3.10, 130, 20, 510,  '2026-03-01'],
        ['Dammam',  'all',       'sale', 4900.00,  2.80, 190, 42, 620,  '2026-03-01'],
        ['Dammam',  'all',       'rent', 2700.00, -1.50, 98,  25, 380,  '2026-03-01'],
        ['Thuwal',  'apartment', 'rent', 1800.00,  1.20, 45,  18, 90,   '2026-03-01'],
        ['Riyadh',  'all',       'sale', 6540.00,  5.80, 298, 40, 1110, '2026-02-01'],
        ['Jeddah',  'all',       'sale', 6980.00,  4.90, 230, 37, 920,  '2026-02-01'],
        ['Dammam',  'all',       'sale', 4750.00,  1.60, 175, 44, 590,  '2026-02-01'],
    ];

    $mktStmt = $conn->prepare(
        "INSERT INTO market_stats
            (city, property_type, listing_type, avg_price_per_sqm,
             price_change_pct, active_listings, avg_days_on_market,
             total_transactions, recorded_month)
         VALUES
            (:city, :ptype, :ltype, :avg_sqm,
             :change_pct, :listings, :days,
             :txns, :month)"
    );
    foreach ($marketStats as [$city,$ptype,$ltype,$avg,$chg,$lst,$days,$txns,$month]) {
        $mktStmt->execute([
            ':city'       => $city,
            ':ptype'      => $ptype,
            ':ltype'      => $ltype,
            ':avg_sqm'    => $avg,
            ':change_pct' => $chg,
            ':listings'   => $lst,
            ':days'       => $days,
            ':txns'       => $txns,
            ':month'      => $month,
        ]);
    }
    echo "[market_stats] Inserted " . count($marketStats) . " market stat records.<br>";

    // ============================================================
    // 16. CONTRACTS
    // ============================================================
    echo "<h3>Seeding Contracts...</h3>";

    $contractsData = [
        [
            'number'   => 'AQR-2024-001',
            'prop_id'  => $propertyIds[0],
            'buyer_id' => $buyer1Id,
            'sell_id'  => $owner1Id,
            'type'     => 'sale',
            'status'   => 'signed',
            'amount'   => 2500000.00,
            'start'    => '2024-11-01',
            'end'      => null,
            'expiry'   => '2025-11-01',
            'b_signed' => 1,
            's_signed' => 1,
            'signed_at'=> '2024-11-05 10:30:00',
        ],
        [
            'number'   => 'AQR-2024-002',
            'prop_id'  => $propertyIds[6],
            'buyer_id' => $tenant1Id,
            'sell_id'  => $owner1Id,
            'type'     => 'rent',
            'status'   => 'signed',
            'amount'   => 35000.00,
            'start'    => '2024-12-01',
            'end'      => '2025-11-30',
            'expiry'   => '2025-11-30',
            'b_signed' => 1,
            's_signed' => 1,
            'signed_at'=> '2024-11-28 14:00:00',
        ],
        [
            'number'   => 'AQR-2025-001',
            'prop_id'  => $propertyIds[4],
            'buyer_id' => $buyer2Id,
            'sell_id'  => $owner2Id,
            'type'     => 'sale',
            'status'   => 'pending',
            'amount'   => 4200000.00,
            'start'    => null,
            'end'      => null,
            'expiry'   => '2025-06-30',
            'b_signed' => 0,
            's_signed' => 0,
            'signed_at'=> null,
        ],
        [
            'number'   => 'AQR-2025-002',
            'prop_id'  => $propertyIds[2],
            'buyer_id' => $buyer1Id,
            'sell_id'  => $seller1Id,
            'type'     => 'rent',
            'status'   => 'under_review',
            'amount'   => 120000.00,
            'start'    => '2025-03-01',
            'end'      => '2026-02-28',
            'expiry'   => '2026-02-28',
            'b_signed' => 1,
            's_signed' => 0,
            'signed_at'=> null,
        ],
    ];

    $conStmt = $conn->prepare(
        "INSERT INTO contracts
         (contract_number, property_id, buyer_id, seller_id, type, status,
          amount, start_date, end_date, expiry_date, buyer_signed, seller_signed, signed_at)
         VALUES
         (:num, :pid, :bid, :sid, :type, :status,
          :amount, :start, :end, :expiry, :bsign, :ssign, :signed_at)"
    );

    $contractIds = [];
    foreach ($contractsData as $c) {
        $conStmt->execute([
            ':num'      => $c['number'],
            ':pid'      => $c['prop_id'],
            ':bid'      => $c['buyer_id'],
            ':sid'      => $c['sell_id'],
            ':type'     => $c['type'],
            ':status'   => $c['status'],
            ':amount'   => $c['amount'],
            ':start'    => $c['start'],
            ':end'      => $c['end'],
            ':expiry'   => $c['expiry'],
            ':bsign'    => $c['b_signed'],
            ':ssign'    => $c['s_signed'],
            ':signed_at'=> $c['signed_at'],
        ]);
        $contractIds[] = (int)$conn->lastInsertId();
    }
    echo "[contracts] Inserted " . count($contractIds) . " contracts.<br>";

    // ============================================================
    // 17. CONTRACT SIGNATURES
    // ============================================================
    echo "<h3>Seeding Contract Signatures...</h3>";

    $sampleSig = base64_encode('SAMPLE_SIGNATURE_PNG_DATA');
    $sigStmt = $conn->prepare(
        "INSERT INTO contract_signatures (contract_id, user_id, role, signature_b64, ip_address)
         VALUES (:cid, :uid, :role, :sig, :ip)"
    );

    $sigData = [
        [$contractIds[0], $buyer1Id,  'buyer',  $sampleSig, '192.168.1.10'],
        [$contractIds[0], $owner1Id,  'seller', $sampleSig, '192.168.1.11'],
        [$contractIds[1], $tenant1Id, 'buyer',  $sampleSig, '192.168.1.12'],
        [$contractIds[1], $owner1Id,  'seller', $sampleSig, '192.168.1.11'],
        [$contractIds[3], $buyer1Id,  'buyer',  $sampleSig, '192.168.1.10'],
    ];

    foreach ($sigData as [$cid, $uid, $role, $sig, $ip]) {
        $sigStmt->execute([':cid' => $cid, ':uid' => $uid, ':role' => $role, ':sig' => $sig, ':ip' => $ip]);
    }
    echo "[contract_signatures] Inserted " . count($sigData) . " signatures.<br>";

    // ============================================================
    // 18. PAYMENTS
    // ============================================================
    echo "<h3>Seeding Payments...</h3>";

    $paymentData = [
        [
            'txn'     => 'TXN-20241105-A1B2C3',
            'con_id'  => $contractIds[0],
            'payer'   => $buyer1Id,
            'payee'   => $owner1Id,
            'prop'    => $propertyIds[0],
            'amount'  => 2500000.00,
            'method'  => 'bank_transfer',
            'status'  => 'completed',
            'paid_at' => '2024-11-05 10:35:00',
        ],
        [
            'txn'     => 'TXN-20241128-D4E5F6',
            'con_id'  => $contractIds[1],
            'payer'   => $tenant1Id,
            'payee'   => $owner1Id,
            'prop'    => $propertyIds[6],
            'amount'  => 35000.00,
            'method'  => 'credit_card',
            'status'  => 'completed',
            'paid_at' => '2024-11-28 14:15:00',
        ],
        [
            'txn'     => 'TXN-20250310-G7H8I9',
            'con_id'  => null,
            'payer'   => $buyer2Id,
            'payee'   => $owner2Id,
            'prop'    => $propertyIds[4],
            'amount'  => 42000.00,
            'method'  => 'stc_pay',
            'status'  => 'completed',
            'paid_at' => '2025-03-10 09:00:00',
        ],
    ];

    $payStmt = $conn->prepare(
        "INSERT INTO payments
         (transaction_id, contract_id, payer_id, payee_id, property_id,
          amount, method, status, qr_payload, paid_at)
         VALUES
         (:txn, :cid, :payer, :payee, :prop,
          :amount, :method, :status, :qr, :paid_at)"
    );

    $paymentIds = [];
    foreach ($paymentData as $p) {
        $qrPayload = json_encode([
            'platform'  => 'Aqari عقاري',
            'txId'      => $p['txn'],
            'amount'    => $p['amount'],
            'currency'  => 'SAR',
            'method'    => $p['method'],
            'status'    => $p['status'],
            'paid_at'   => $p['paid_at'],
            'verify_url'=> 'https://aqari.sa/verify?txn=' . $p['txn'],
        ]);
        $payStmt->execute([
            ':txn'    => $p['txn'],
            ':cid'    => $p['con_id'],
            ':payer'  => $p['payer'],
            ':payee'  => $p['payee'],
            ':prop'   => $p['prop'],
            ':amount' => $p['amount'],
            ':method' => $p['method'],
            ':status' => $p['status'],
            ':qr'     => $qrPayload,
            ':paid_at'=> $p['paid_at'],
        ]);
        $paymentIds[] = (int)$conn->lastInsertId();
    }
    echo "[payments] Inserted " . count($paymentIds) . " payments.<br>";

    // ============================================================
    // 19. PAYMENT VERIFICATIONS
    // ============================================================
    echo "<h3>Seeding Payment Verifications...</h3>";

    $pvStmt = $conn->prepare(
        "INSERT INTO payment_verifications (payment_id, verification_code, scan_count, is_valid)
         VALUES (:pid, :code, :scans, 1)"
    );

    foreach ($paymentIds as $i => $pid) {
        $code = hash('sha256', $paymentData[$i]['txn'] . 'aqari_secret_2024');
        $pvStmt->execute([':pid' => $pid, ':code' => $code, ':scans' => rand(0, 3)]);
    }
    echo "[payment_verifications] Inserted " . count($paymentIds) . " verification records.<br>";

    // ============================================================
    // SUMMARY
    // ============================================================
    echo "<hr>";
    echo "<h2>✅ Database Seeding Complete!</h2>";
    echo "<table border='1' cellpadding='6' cellspacing='0'>";
    echo "<tr><th>Table</th><th>Records</th></tr>";
    foreach ($tables as $t) {
        $c = $conn->query("SELECT COUNT(*) FROM `$t`")->fetchColumn();
        echo "<tr><td>$t</td><td>$c</td></tr>";
    }
    echo "</table>";
    echo "<br><b>Default credentials:</b> All users → password: <code>password123</code><br>";
    echo "<b>Admin login:</b> admin@aqari.com / password123<br>";

} catch (PDOException $e) {
    echo "<b style='color:red'>Error: " . $e->getMessage() . "</b>";
}
?>
