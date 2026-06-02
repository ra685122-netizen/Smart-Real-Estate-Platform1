USE smart_real_estate;

INSERT INTO properties (owner_id, title, description, price, listing_type, property_type, location, city, bedrooms, bathrooms, area, virtual_tour_url, is_featured, admin_approved, status) VALUES
(2, 'فيلا فاخرة مع مسبح خاص', 'فيلا مذهلة من 5 غرف نوم مع مسبح خاص وحديقة ونظام منزل ذكي. مثالية للعائلات الباحثة عن الفخامة والراحة. تتميز بتصميم معماري حديث وتشطيبات عالية الجودة.', 2500000, 'sale', 'villa', 'الملقا، الرياض', 'الرياض', 5, 4, 450.00, 'https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=600&auto=format&fit=crop', 1, 1, 'available'),
(2, 'شقة عصرية وسط المدينة', 'شقة أنيقة من غرفتين نوم في قلب المدينة. قريبة من المراكز التجارية ووسائل النقل. مؤثثة بالكامل بأحدث التصاميم.', 850000, 'sale', 'apartment', 'البلد، جدة', 'جدة', 2, 2, 120.00, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=600&auto=format&fit=crop', 1, 1, 'available'),
(2, 'مكتب تجاري واسع', 'مساحة مكتبية واسعة ومفتوحة مناسبة للشركات الناشئة. إنترنت عالي السرعة ومواقف سيارات مخصصة وقاعة اجتماعات.', 120000, 'rent', 'commercial', 'طريق الملك فهد، الدمام', 'الدمام', 0, 2, 200.00, 'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop', 0, 1, 'available'),
(2, 'شقة للإيجار في الرياض', 'شقة مريحة من 3 غرف نوم في حي هادئ. تشمل غرفة معيشة واسعة ومطبخاً حديثاً وموقف سيارة خاصاً.', 45000, 'rent', 'apartment', 'النرجس، الرياض', 'الرياض', 3, 2, 180.00, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=600&auto=format&fit=crop', 0, 1, 'available'),
(2, 'أرض سكنية للبيع', 'أرض سكنية مميزة في منطقة متطورة. مساحة كبيرة مناسبة لبناء فيلا أحلامك. قريبة من الخدمات والمدارس.', 1800000, 'sale', 'land', 'العارض، الرياض', 'الرياض', 0, 0, 800.00, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=600&auto=format&fit=crop', 0, 1, 'available'),
(2, 'فيلا للإيجار في جدة', 'فيلا راقية مع حديقة خاصة ومسبح. موقع ممتاز قريب من البحر. مناسبة للعائلات الكبيرة.', 180000, 'rent', 'villa', 'الزهراء، جدة', 'جدة', 6, 5, 600.00, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=600&auto=format&fit=crop', 1, 1, 'available'),
(2, 'مكتب للإيجار في الدمام', 'مكتب حديث في برج تجاري مرموق. إطلالة رائعة وموقع استراتيجي. مناسب للشركات الكبيرة.', 85000, 'rent', 'office', 'العزيزية، الدمام', 'الدمام', 0, 2, 150.00, 'https://images.unsplash.com/photo-1497366754035-f200581384c9?q=80&w=600&auto=format&fit=crop', 0, 1, 'available'),
(2, 'شقة فندقية فاخرة', 'شقة فندقية مفروشة بالكامل في برج سكني فاخر. خدمات كاملة تشمل الأمن والمسبح والصالة الرياضية.', 1200000, 'sale', 'apartment', 'العليا، الرياض', 'الرياض', 2, 2, 140.00, 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?q=80&w=600&auto=format&fit=crop', 1, 1, 'available');

INSERT INTO property_images (property_id, image_url, is_primary, sort_order) VALUES
(1, 'https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=600&auto=format&fit=crop', 1, 0),
(1, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=600&auto=format&fit=crop', 0, 1),
(1, 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=600&auto=format&fit=crop', 0, 2),
(2, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=600&auto=format&fit=crop', 1, 0),
(2, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=600&auto=format&fit=crop', 0, 1),
(3, 'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop', 1, 0),
(4, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=600&auto=format&fit=crop', 1, 0),
(5, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=600&auto=format&fit=crop', 1, 0),
(6, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=600&auto=format&fit=crop', 1, 0),
(7, 'https://images.unsplash.com/photo-1497366754035-f200581384c9?q=80&w=600&auto=format&fit=crop', 1, 0),
(8, 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?q=80&w=600&auto=format&fit=crop', 1, 0);

SELECT CONCAT('Properties inserted: ', COUNT(*)) FROM properties;
