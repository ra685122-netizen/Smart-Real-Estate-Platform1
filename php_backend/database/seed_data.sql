SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE property_images;
TRUNCATE TABLE properties;

ALTER TABLE properties AUTO_INCREMENT = 1;

SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO properties (owner_id,title,description,price,listing_type,property_type,location,city,district,status,bedrooms,bathrooms,area,floor,total_floors,year_built,is_furnished,latitude,longitude,virtual_tour_url,is_featured,admin_approved) VALUES
(2,'Luxury Villa with Private Pool','A stunning 5-bedroom villa with a private swimming pool, landscaped garden, and state-of-the-art smart home features.',2500000,'sale','villa','Riyadh, Al-Malqa District','Riyadh','Al-Malqa','available',5,4,600,NULL,2,2021,1,24.8130,46.6110,'https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=600&auto=format&fit=crop',1,1),
(2,'Modern Downtown Apartment','A sleek 2-bedroom apartment in the heart of Jeddah. Walking distance to malls and public transit. City views from every room.',850000,'sale','apartment','Jeddah, Al-Balad','Jeddah','Al-Balad','available',2,2,145,8,20,2020,0,21.4858,39.1925,'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=600&auto=format&fit=crop',1,1),
(5,'Prime Commercial Office Space','Large open-plan office space ideal for startups or established businesses. High-speed internet, dedicated parking, 24/7 security.',120000,'rent','commercial','Dammam, King Fahd Road','Dammam','Al-Faisaliyah','available',0,2,280,4,10,2019,1,26.4207,50.0888,'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop',0,1),
(2,'Cozy Family Townhouse','Quiet residential neighborhood, 3 bedrooms, fully renovated kitchen, private backyard with garden. Excellent schools nearby.',1150000,'sale','villa','Riyadh, Al-Yasmin','Riyadh','Al-Yasmin','available',3,3,320,NULL,2,2018,0,24.8190,46.6430,'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=600&auto=format&fit=crop',0,1),
(2,'Sea View Penthouse - Jeddah Corniche','Exclusive penthouse with panoramic Red Sea views. Private elevator, rooftop terrace, infinity pool access, and concierge service.',4200000,'sale','apartment','Jeddah, Corniche','Jeddah','Al-Corniche','available',4,4,380,25,25,2022,1,21.5645,39.1350,'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=600&auto=format&fit=crop',1,1),
(5,'Investment Land - North Riyadh','Flat, fully documented land in a fast-growing area of North Riyadh. Zoned for residential development. Utilities connected.',3800000,'sale','land','Riyadh, North Ring Road','Riyadh','Al-Narjis','available',0,0,1200,NULL,NULL,NULL,0,24.8750,46.7100,'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=600&auto=format&fit=crop',0,1),
(2,'Furnished Studio - Near KAUST','Fully furnished studio apartment near King Abdullah University. Ideal for students or young professionals. All utilities included.',35000,'rent','apartment','Thuwal, KAUST Area','Thuwal','University District','available',1,1,55,3,6,2017,1,22.3003,39.1027,'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=600&auto=format&fit=crop',0,1),
(2,'Heritage Home - Al-Ahsa','Traditional-style home in the heart of Al-Ahsa oasis. High ceilings, courtyard, and authentic architecture. Recently fully restored.',980000,'sale','villa','Al-Ahsa, Old Town','Al-Ahsa','Old Town','available',4,3,420,NULL,2,1985,0,25.3680,49.5870,'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=600&auto=format&fit=crop',0,1),
(2,'Smart Apartment - Riyadh KAFD','Brand new smart apartment in King Abdullah Financial District. Floor-to-ceiling windows, automated lighting and systems.',1350000,'sale','apartment','Riyadh, KAFD','Riyadh','KAFD','available',2,2,160,15,35,2023,1,24.7640,46.6570,'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?q=80&w=600&auto=format&fit=crop',1,1),
(5,'Beachfront Chalet - Yanbu','Relaxing beachfront chalet with direct Red Sea access. Private beach, BBQ area, and stunning sunset views.',650000,'sale','chalet','Yanbu, Corniche','Yanbu','Al-Corniche','available',3,2,200,NULL,1,2020,1,24.0894,38.0618,'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?q=80&w=600&auto=format&fit=crop',0,1);

INSERT INTO property_images (property_id, image_url, is_primary, sort_order) VALUES
(1,'https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=600&auto=format&fit=crop',1,1),
(1,'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=600&auto=format&fit=crop',0,2),
(1,'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=600&auto=format&fit=crop',0,3),
(2,'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=600&auto=format&fit=crop',1,1),
(2,'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=600&auto=format&fit=crop',0,2),
(3,'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop',1,1),
(3,'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?q=80&w=600&auto=format&fit=crop',0,2),
(4,'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=600&auto=format&fit=crop',1,1),
(4,'https://images.unsplash.com/photo-1570129477492-45c003edd2be?q=80&w=600&auto=format&fit=crop',0,2),
(5,'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=600&auto=format&fit=crop',1,1),
(5,'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?q=80&w=600&auto=format&fit=crop',0,2),
(6,'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=600&auto=format&fit=crop',1,1),
(7,'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=600&auto=format&fit=crop',1,1),
(8,'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=600&auto=format&fit=crop',1,1),
(8,'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=600&auto=format&fit=crop',0,2),
(9,'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?q=80&w=600&auto=format&fit=crop',1,1),
(9,'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=600&auto=format&fit=crop',0,2),
(10,'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?q=80&w=600&auto=format&fit=crop',1,1),
(10,'https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=600&auto=format&fit=crop',0,2);

SELECT COUNT(*) as properties_count FROM properties;
SELECT COUNT(*) as images_count FROM property_images;
