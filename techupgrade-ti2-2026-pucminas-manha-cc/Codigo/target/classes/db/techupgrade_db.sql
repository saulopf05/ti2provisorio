DROP DATABASE IF EXISTS techupgrade_db;
CREATE DATABASE techupgrade_db;
\connect techupgrade_db

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP TABLE IF EXISTS recommendation_offer_links CASCADE;
DROP TABLE IF EXISTS recommendation_items CASCADE;
DROP TABLE IF EXISTS compatibility_rules CASCADE;
DROP TABLE IF EXISTS analysis_components CASCADE;
DROP TABLE IF EXISTS analyses CASCADE;
DROP TABLE IF EXISTS component_offers CASCADE;
DROP TABLE IF EXISTS components_catalog CASCADE;
DROP TABLE IF EXISTS stores CASCADE;
DROP TABLE IF EXISTS purpose_component_weights CASCADE;
DROP TABLE IF EXISTS purposes CASCADE;
DROP TABLE IF EXISTS component_types CASCADE;
DROP TABLE IF EXISTS refresh_tokens CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (id BIGSERIAL PRIMARY KEY, full_name VARCHAR(120) NOT NULL, email VARCHAR(180) NOT NULL UNIQUE, password_hash TEXT NOT NULL, profile_image_url TEXT, role VARCHAR(30) NOT NULL DEFAULT 'USER', is_active BOOLEAN NOT NULL DEFAULT TRUE, last_login_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW());
CREATE TABLE component_types (id BIGSERIAL PRIMARY KEY, name VARCHAR(40) NOT NULL UNIQUE, display_name VARCHAR(80) NOT NULL, description TEXT, is_active BOOLEAN NOT NULL DEFAULT TRUE);
CREATE TABLE purposes (id BIGSERIAL PRIMARY KEY, name VARCHAR(40) NOT NULL UNIQUE, display_name VARCHAR(100) NOT NULL, description TEXT, is_active BOOLEAN NOT NULL DEFAULT TRUE);
CREATE TABLE purpose_component_weights (id BIGSERIAL PRIMARY KEY, purpose_id BIGINT NOT NULL REFERENCES purposes(id) ON DELETE CASCADE, component_type_id BIGINT NOT NULL REFERENCES component_types(id) ON DELETE CASCADE, weight NUMERIC(6,2) NOT NULL CHECK (weight > 0), minimum_good_score NUMERIC(12,2), UNIQUE (purpose_id, component_type_id));
CREATE TABLE stores (id BIGSERIAL PRIMARY KEY, store_name VARCHAR(100) NOT NULL UNIQUE, base_url TEXT, is_active BOOLEAN NOT NULL DEFAULT TRUE);
CREATE TABLE components_catalog (id BIGSERIAL PRIMARY KEY, component_type_id BIGINT NOT NULL REFERENCES component_types(id), brand VARCHAR(80) NOT NULL, model VARCHAR(160) NOT NULL, socket VARCHAR(40), ram_type VARCHAR(30), chipset VARCHAR(60), interface_type VARCHAR(50), capacity_gb NUMERIC(10,2), vram_gb NUMERIC(6,2), frequency_mhz INTEGER, max_ram_gb INTEGER, wattage INTEGER, certification VARCHAR(60), tdp_watts INTEGER, benchmark_score NUMERIC(12,2), msrp_price NUMERIC(12,2), specs_json JSONB DEFAULT '{}'::jsonb, is_active BOOLEAN NOT NULL DEFAULT TRUE, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), UNIQUE (component_type_id, brand, model), CHECK (benchmark_score IS NULL OR benchmark_score >= 0), CHECK (msrp_price IS NULL OR msrp_price >= 0));
CREATE TABLE component_offers (id BIGSERIAL PRIMARY KEY, component_id BIGINT NOT NULL REFERENCES components_catalog(id) ON DELETE CASCADE, store_id BIGINT NOT NULL REFERENCES stores(id), product_title VARCHAR(220) NOT NULL, product_url TEXT, price NUMERIC(12,2) NOT NULL CHECK (price >= 0), in_stock BOOLEAN NOT NULL DEFAULT TRUE, checked_at TIMESTAMPTZ NOT NULL DEFAULT NOW());
CREATE TABLE analyses (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id BIGINT REFERENCES users(id) ON DELETE SET NULL, purpose_id BIGINT REFERENCES purposes(id), input_method VARCHAR(30) NOT NULL DEFAULT 'image', processing_status VARCHAR(30) NOT NULL DEFAULT 'pending', summary TEXT, raw_ocr_text TEXT, extracted_specs_json JSONB DEFAULT '{}'::jsonb, error_details TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW());
CREATE TABLE analysis_components (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), analysis_id UUID NOT NULL REFERENCES analyses(id) ON DELETE CASCADE, component_type_id BIGINT REFERENCES component_types(id), matched_component_id BIGINT REFERENCES components_catalog(id) ON DELETE SET NULL, component_name VARCHAR(120) NOT NULL, current_spec TEXT NOT NULL, status VARCHAR(30) NOT NULL, message TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW());
CREATE TABLE compatibility_rules (id BIGSERIAL PRIMARY KEY, rule_name VARCHAR(120) NOT NULL, source_type_id BIGINT REFERENCES component_types(id), target_type_id BIGINT REFERENCES component_types(id), rule_description TEXT NOT NULL, is_active BOOLEAN NOT NULL DEFAULT TRUE);
CREATE TABLE recommendation_items (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), analysis_id UUID NOT NULL REFERENCES analyses(id) ON DELETE CASCADE, analysis_component_id UUID REFERENCES analysis_components(id) ON DELETE SET NULL, recommended_component_id BIGINT REFERENCES components_catalog(id) ON DELETE SET NULL, component_type_id BIGINT NOT NULL REFERENCES component_types(id), recommendation_text TEXT NOT NULL, compatibility_note TEXT, current_benchmark_score NUMERIC(12,2), recommended_benchmark_score NUMERIC(12,2), benchmark_gain NUMERIC(12,2), estimated_price NUMERIC(12,2), priority_score NUMERIC(14,4), display_order SMALLINT NOT NULL DEFAULT 1, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW());
CREATE TABLE recommendation_offer_links (id BIGSERIAL PRIMARY KEY, recommendation_item_id UUID NOT NULL REFERENCES recommendation_items(id) ON DELETE CASCADE, component_offer_id BIGINT REFERENCES component_offers(id) ON DELETE SET NULL, store_id BIGINT REFERENCES stores(id), product_title VARCHAR(220), product_url TEXT, offered_price NUMERIC(12,2), is_best_offer BOOLEAN NOT NULL DEFAULT FALSE);
CREATE TABLE refresh_tokens (id BIGSERIAL PRIMARY KEY, user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE, token_hash TEXT NOT NULL, expires_at TIMESTAMPTZ NOT NULL, is_revoked BOOLEAN NOT NULL DEFAULT FALSE, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW());
CREATE INDEX idx_components_type ON components_catalog(component_type_id);
CREATE INDEX idx_components_model_lower ON components_catalog(lower(model));
CREATE INDEX idx_components_benchmark ON components_catalog(benchmark_score);
CREATE INDEX idx_offers_component_price ON component_offers(component_id, price);
CREATE INDEX idx_analyses_user_created ON analyses(user_id, created_at DESC);


INSERT INTO component_types (name, display_name, description) VALUES ('CPU','Processador','Processadores'),('GPU','Placa de vídeo','GPUs'),('RAM','Memória RAM','Memórias'),('STORAGE','Armazenamento','HDs e SSDs'),('MOTHERBOARD','Placa-mãe','Placas mãe'),('PSU','Fonte','Fontes'),('COOLER','Cooler','Resfriamento');

INSERT INTO purposes (name, display_name, description) VALUES ('gaming','Gaming','Jogos'),('design','Design gráfico','Design e edição'),('trabalho','Trabalho/Escritório','Navegação e escritório'),('streaming','Streaming/Criação','Lives e criação'),('programacao','Programação','Desenvolvimento'),('estudos','Estudos','Aulas e trabalhos');

INSERT INTO purpose_component_weights (purpose_id, component_type_id, weight) VALUES
((SELECT id FROM purposes WHERE name='gaming'),(SELECT id FROM component_types WHERE name='GPU'),5),
((SELECT id FROM purposes WHERE name='gaming'),(SELECT id FROM component_types WHERE name='CPU'),4),
((SELECT id FROM purposes WHERE name='gaming'),(SELECT id FROM component_types WHERE name='RAM'),3),
((SELECT id FROM purposes WHERE name='gaming'),(SELECT id FROM component_types WHERE name='STORAGE'),2),
((SELECT id FROM purposes WHERE name='gaming'),(SELECT id FROM component_types WHERE name='PSU'),1),
((SELECT id FROM purposes WHERE name='gaming'),(SELECT id FROM component_types WHERE name='MOTHERBOARD'),1),
((SELECT id FROM purposes WHERE name='design'),(SELECT id FROM component_types WHERE name='GPU'),4),
((SELECT id FROM purposes WHERE name='design'),(SELECT id FROM component_types WHERE name='CPU'),4),
((SELECT id FROM purposes WHERE name='design'),(SELECT id FROM component_types WHERE name='RAM'),5),
((SELECT id FROM purposes WHERE name='design'),(SELECT id FROM component_types WHERE name='STORAGE'),3),
((SELECT id FROM purposes WHERE name='design'),(SELECT id FROM component_types WHERE name='PSU'),1),
((SELECT id FROM purposes WHERE name='design'),(SELECT id FROM component_types WHERE name='MOTHERBOARD'),1),
((SELECT id FROM purposes WHERE name='programacao'),(SELECT id FROM component_types WHERE name='CPU'),5),
((SELECT id FROM purposes WHERE name='programacao'),(SELECT id FROM component_types WHERE name='RAM'),5),
((SELECT id FROM purposes WHERE name='programacao'),(SELECT id FROM component_types WHERE name='STORAGE'),4),
((SELECT id FROM purposes WHERE name='programacao'),(SELECT id FROM component_types WHERE name='GPU'),1),
((SELECT id FROM purposes WHERE name='programacao'),(SELECT id FROM component_types WHERE name='PSU'),1),
((SELECT id FROM purposes WHERE name='programacao'),(SELECT id FROM component_types WHERE name='MOTHERBOARD'),1),
((SELECT id FROM purposes WHERE name='streaming'),(SELECT id FROM component_types WHERE name='CPU'),5),
((SELECT id FROM purposes WHERE name='streaming'),(SELECT id FROM component_types WHERE name='GPU'),4),
((SELECT id FROM purposes WHERE name='streaming'),(SELECT id FROM component_types WHERE name='RAM'),4),
((SELECT id FROM purposes WHERE name='streaming'),(SELECT id FROM component_types WHERE name='STORAGE'),3),
((SELECT id FROM purposes WHERE name='streaming'),(SELECT id FROM component_types WHERE name='PSU'),1),
((SELECT id FROM purposes WHERE name='streaming'),(SELECT id FROM component_types WHERE name='MOTHERBOARD'),1),
((SELECT id FROM purposes WHERE name='estudos'),(SELECT id FROM component_types WHERE name='STORAGE'),4),
((SELECT id FROM purposes WHERE name='estudos'),(SELECT id FROM component_types WHERE name='RAM'),3),
((SELECT id FROM purposes WHERE name='estudos'),(SELECT id FROM component_types WHERE name='CPU'),3),
((SELECT id FROM purposes WHERE name='estudos'),(SELECT id FROM component_types WHERE name='GPU'),1),
((SELECT id FROM purposes WHERE name='estudos'),(SELECT id FROM component_types WHERE name='PSU'),1),
((SELECT id FROM purposes WHERE name='estudos'),(SELECT id FROM component_types WHERE name='MOTHERBOARD'),1),
((SELECT id FROM purposes WHERE name='trabalho'),(SELECT id FROM component_types WHERE name='STORAGE'),4),
((SELECT id FROM purposes WHERE name='trabalho'),(SELECT id FROM component_types WHERE name='RAM'),4),
((SELECT id FROM purposes WHERE name='trabalho'),(SELECT id FROM component_types WHERE name='CPU'),3),
((SELECT id FROM purposes WHERE name='trabalho'),(SELECT id FROM component_types WHERE name='GPU'),1),
((SELECT id FROM purposes WHERE name='trabalho'),(SELECT id FROM component_types WHERE name='PSU'),1),
((SELECT id FROM purposes WHERE name='trabalho'),(SELECT id FROM component_types WHERE name='MOTHERBOARD'),1);

INSERT INTO stores (store_name, base_url) VALUES ('KaBuM!','https://www.kabum.com.br'),('Pichau','https://www.pichau.com.br'),('Terabyte','https://www.terabyteshop.com.br');

INSERT INTO components_catalog (component_type_id, brand, model, socket, ram_type, chipset, interface_type, capacity_gb, vram_gb, frequency_mhz, max_ram_gb, wattage, certification, tdp_watts, benchmark_score, msrp_price) VALUES
((SELECT id FROM component_types WHERE name='CPU'),'Intel','Core i3-10100F','LGA1200',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,8900,350),
((SELECT id FROM component_types WHERE name='CPU'),'Intel','Core i5-10400F','LGA1200',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,12300,500),
((SELECT id FROM component_types WHERE name='CPU'),'Intel','Core i5-11400F','LGA1200',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,14000,590),
((SELECT id FROM component_types WHERE name='CPU'),'Intel','Core i7-11700F','LGA1200',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,21000,1100),
((SELECT id FROM component_types WHERE name='CPU'),'Intel','Core i3-12100F','LGA1700',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,58,14500,520),
((SELECT id FROM component_types WHERE name='CPU'),'Intel','Core i5-12400F','LGA1700',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,19500,650),
((SELECT id FROM component_types WHERE name='CPU'),'Intel','Core i5-13400F','LGA1700',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,25500,950),
((SELECT id FROM component_types WHERE name='CPU'),'Intel','Core i5-13600K','LGA1700',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,125,38000,1600),
((SELECT id FROM component_types WHERE name='CPU'),'Intel','Core i7-13700K','LGA1700',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,125,47000,2400),
((SELECT id FROM component_types WHERE name='CPU'),'Intel','Core i5-14400F','LGA1700',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,26500,1050),
((SELECT id FROM component_types WHERE name='CPU'),'Intel','Core i7-14700K','LGA1700',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,125,53500,3000),
((SELECT id FROM component_types WHERE name='CPU'),'AMD','Ryzen 3 3100','AM4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,11500,400),
((SELECT id FROM component_types WHERE name='CPU'),'AMD','Ryzen 5 3600','AM4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,17800,580),
((SELECT id FROM component_types WHERE name='CPU'),'AMD','Ryzen 5 5500','AM4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,19000,620),
((SELECT id FROM component_types WHERE name='CPU'),'AMD','Ryzen 5 5600','AM4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,22000,700),
((SELECT id FROM component_types WHERE name='CPU'),'AMD','Ryzen 7 5700X','AM4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,27000,1000),
((SELECT id FROM component_types WHERE name='CPU'),'AMD','Ryzen 7 5800X3D','AM4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,105,28500,1900),
((SELECT id FROM component_types WHERE name='CPU'),'AMD','Ryzen 5 7600','AM5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,28500,1300),
((SELECT id FROM component_types WHERE name='CPU'),'AMD','Ryzen 7 7700','AM5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,35000,1900),
((SELECT id FROM component_types WHERE name='CPU'),'AMD','Ryzen 7 7800X3D','AM5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,120,34500,2600),
((SELECT id FROM component_types WHERE name='CPU'),'AMD','Ryzen 9 7900','AM5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,49000,2800),
((SELECT id FROM component_types WHERE name='CPU'),'AMD','Ryzen 9 7950X','AM5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,170,63500,3900),
((SELECT id FROM component_types WHERE name='GPU'),'NVIDIA','GTX 1050 Ti',NULL,NULL,NULL,NULL,NULL,4,NULL,NULL,NULL,NULL,75,6300,500),
((SELECT id FROM component_types WHERE name='GPU'),'NVIDIA','GTX 1650',NULL,NULL,NULL,NULL,NULL,4,NULL,NULL,NULL,NULL,75,7800,750),
((SELECT id FROM component_types WHERE name='GPU'),'NVIDIA','GTX 1660 Super',NULL,NULL,NULL,NULL,NULL,6,NULL,NULL,NULL,NULL,125,12700,950),
((SELECT id FROM component_types WHERE name='GPU'),'NVIDIA','RTX 2060',NULL,NULL,NULL,NULL,NULL,6,NULL,NULL,NULL,NULL,160,14000,1200),
((SELECT id FROM component_types WHERE name='GPU'),'NVIDIA','RTX 3060',NULL,NULL,NULL,NULL,NULL,12,NULL,NULL,NULL,NULL,170,17000,1600),
((SELECT id FROM component_types WHERE name='GPU'),'NVIDIA','RTX 3060 Ti',NULL,NULL,NULL,NULL,NULL,8,NULL,NULL,NULL,NULL,200,20500,2000),
((SELECT id FROM component_types WHERE name='GPU'),'NVIDIA','RTX 4060',NULL,NULL,NULL,NULL,NULL,8,NULL,NULL,NULL,NULL,115,20000,1800),
((SELECT id FROM component_types WHERE name='GPU'),'NVIDIA','RTX 4060 Ti',NULL,NULL,NULL,NULL,NULL,8,NULL,NULL,NULL,NULL,160,23500,2400),
((SELECT id FROM component_types WHERE name='GPU'),'NVIDIA','RTX 4070',NULL,NULL,NULL,NULL,NULL,12,NULL,NULL,NULL,NULL,200,30000,3600),
((SELECT id FROM component_types WHERE name='GPU'),'NVIDIA','RTX 4070 Super',NULL,NULL,NULL,NULL,NULL,12,NULL,NULL,NULL,NULL,220,35000,4200),
((SELECT id FROM component_types WHERE name='GPU'),'NVIDIA','RTX 4080 Super',NULL,NULL,NULL,NULL,NULL,16,NULL,NULL,NULL,NULL,320,45500,7000),
((SELECT id FROM component_types WHERE name='GPU'),'AMD','RX 570',NULL,NULL,NULL,NULL,NULL,4,NULL,NULL,NULL,NULL,150,7000,550),
((SELECT id FROM component_types WHERE name='GPU'),'AMD','RX 580',NULL,NULL,NULL,NULL,NULL,8,NULL,NULL,NULL,NULL,185,8500,650),
((SELECT id FROM component_types WHERE name='GPU'),'AMD','RX 5500 XT',NULL,NULL,NULL,NULL,NULL,8,NULL,NULL,NULL,NULL,130,10000,800),
((SELECT id FROM component_types WHERE name='GPU'),'AMD','RX 5600 XT',NULL,NULL,NULL,NULL,NULL,6,NULL,NULL,NULL,NULL,150,13500,1000),
((SELECT id FROM component_types WHERE name='GPU'),'AMD','RX 6600',NULL,NULL,NULL,NULL,NULL,8,NULL,NULL,NULL,NULL,132,16500,1200),
((SELECT id FROM component_types WHERE name='GPU'),'AMD','RX 6650 XT',NULL,NULL,NULL,NULL,NULL,8,NULL,NULL,NULL,NULL,176,19000,1500),
((SELECT id FROM component_types WHERE name='GPU'),'AMD','RX 7600',NULL,NULL,NULL,NULL,NULL,8,NULL,NULL,NULL,NULL,165,20500,1700),
((SELECT id FROM component_types WHERE name='GPU'),'AMD','RX 6700 XT',NULL,NULL,NULL,NULL,NULL,12,NULL,NULL,NULL,NULL,230,25000,2300),
((SELECT id FROM component_types WHERE name='GPU'),'AMD','RX 7700 XT',NULL,NULL,NULL,NULL,NULL,12,NULL,NULL,NULL,NULL,245,31500,3300),
((SELECT id FROM component_types WHERE name='GPU'),'AMD','RX 7800 XT',NULL,NULL,NULL,NULL,NULL,16,NULL,NULL,NULL,NULL,263,37000,4100),
((SELECT id FROM component_types WHERE name='RAM'),'Kingston','8GB DDR4 2666MHz',NULL,'DDR4',NULL,NULL,8,NULL,2666,NULL,NULL,NULL,NULL,1067.0,466.6),
((SELECT id FROM component_types WHERE name='RAM'),'Kingston','8GB DDR4 3000MHz',NULL,'DDR4',NULL,NULL,8,NULL,3000,NULL,NULL,NULL,NULL,1100.0,500.0),
((SELECT id FROM component_types WHERE name='RAM'),'Kingston','16GB DDR4 2666MHz',NULL,'DDR4',NULL,NULL,16,NULL,2666,NULL,NULL,NULL,NULL,1867.0,666.6),
((SELECT id FROM component_types WHERE name='RAM'),'Kingston','16GB DDR4 3000MHz',NULL,'DDR4',NULL,NULL,16,NULL,3000,NULL,NULL,NULL,NULL,1900.0,700.0),
((SELECT id FROM component_types WHERE name='RAM'),'Corsair','32GB DDR4 2666MHz',NULL,'DDR4',NULL,NULL,32,NULL,2666,NULL,NULL,NULL,NULL,3467.0,1066.6),
((SELECT id FROM component_types WHERE name='RAM'),'Corsair','32GB DDR4 3000MHz',NULL,'DDR4',NULL,NULL,32,NULL,3000,NULL,NULL,NULL,NULL,3500.0,1100.0),
((SELECT id FROM component_types WHERE name='RAM'),'Corsair','64GB DDR4 2666MHz',NULL,'DDR4',NULL,NULL,64,NULL,2666,NULL,NULL,NULL,NULL,6667.0,1866.6),
((SELECT id FROM component_types WHERE name='RAM'),'Corsair','64GB DDR4 3000MHz',NULL,'DDR4',NULL,NULL,64,NULL,3000,NULL,NULL,NULL,NULL,6700.0,1900.0),
((SELECT id FROM component_types WHERE name='RAM'),'Kingston','8GB DDR5 4800MHz',NULL,'DDR5',NULL,NULL,8,NULL,4800,NULL,NULL,NULL,NULL,1780.0,880.0),
((SELECT id FROM component_types WHERE name='RAM'),'Kingston','8GB DDR5 5200MHz',NULL,'DDR5',NULL,NULL,8,NULL,5200,NULL,NULL,NULL,NULL,1820.0,920.0),
((SELECT id FROM component_types WHERE name='RAM'),'Kingston','16GB DDR5 4800MHz',NULL,'DDR5',NULL,NULL,16,NULL,4800,NULL,NULL,NULL,NULL,2580.0,1080.0),
((SELECT id FROM component_types WHERE name='RAM'),'Kingston','16GB DDR5 5200MHz',NULL,'DDR5',NULL,NULL,16,NULL,5200,NULL,NULL,NULL,NULL,2620.0,1120.0),
((SELECT id FROM component_types WHERE name='RAM'),'Corsair','32GB DDR5 4800MHz',NULL,'DDR5',NULL,NULL,32,NULL,4800,NULL,NULL,NULL,NULL,4180.0,1480.0),
((SELECT id FROM component_types WHERE name='RAM'),'Corsair','32GB DDR5 5200MHz',NULL,'DDR5',NULL,NULL,32,NULL,5200,NULL,NULL,NULL,NULL,4220.0,1520.0),
((SELECT id FROM component_types WHERE name='RAM'),'Corsair','64GB DDR5 4800MHz',NULL,'DDR5',NULL,NULL,64,NULL,4800,NULL,NULL,NULL,NULL,7380.0,2280.0),
((SELECT id FROM component_types WHERE name='RAM'),'Corsair','64GB DDR5 5200MHz',NULL,'DDR5',NULL,NULL,64,NULL,5200,NULL,NULL,NULL,NULL,7420.0,2320.0),
((SELECT id FROM component_types WHERE name='STORAGE'),'Seagate','HD Barracuda 1TB',NULL,NULL,NULL,'SATA',1000,NULL,NULL,NULL,NULL,NULL,NULL,180,250),
((SELECT id FROM component_types WHERE name='STORAGE'),'Seagate','HD Barracuda 2TB',NULL,NULL,NULL,'SATA',2000,NULL,NULL,NULL,NULL,NULL,NULL,220,380),
((SELECT id FROM component_types WHERE name='STORAGE'),'Western Digital','Blue HD 1TB',NULL,NULL,NULL,'SATA',1000,NULL,NULL,NULL,NULL,NULL,NULL,190,260),
((SELECT id FROM component_types WHERE name='STORAGE'),'Kingston','A400 SSD 240GB',NULL,NULL,NULL,'SATA',240,NULL,NULL,NULL,NULL,NULL,NULL,500,140),
((SELECT id FROM component_types WHERE name='STORAGE'),'Kingston','A400 SSD 480GB',NULL,NULL,NULL,'SATA',480,NULL,NULL,NULL,NULL,NULL,NULL,550,220),
((SELECT id FROM component_types WHERE name='STORAGE'),'Crucial','BX500 SSD 1TB',NULL,NULL,NULL,'SATA',1000,NULL,NULL,NULL,NULL,NULL,NULL,600,360),
((SELECT id FROM component_types WHERE name='STORAGE'),'Kingston','NV2 500GB NVMe',NULL,NULL,NULL,'NVMe',500,NULL,NULL,NULL,NULL,NULL,NULL,3500,220),
((SELECT id FROM component_types WHERE name='STORAGE'),'Kingston','NV2 1TB NVMe',NULL,NULL,NULL,'NVMe',1000,NULL,NULL,NULL,NULL,NULL,NULL,3500,350),
((SELECT id FROM component_types WHERE name='STORAGE'),'Kingston','NV2 2TB NVMe',NULL,NULL,NULL,'NVMe',2000,NULL,NULL,NULL,NULL,NULL,NULL,3500,750),
((SELECT id FROM component_types WHERE name='STORAGE'),'Crucial','P3 500GB NVMe',NULL,NULL,NULL,'NVMe',500,NULL,NULL,NULL,NULL,NULL,NULL,3700,260),
((SELECT id FROM component_types WHERE name='STORAGE'),'Crucial','P3 1TB NVMe',NULL,NULL,NULL,'NVMe',1000,NULL,NULL,NULL,NULL,NULL,NULL,3700,390),
((SELECT id FROM component_types WHERE name='STORAGE'),'WD','SN570 1TB NVMe',NULL,NULL,NULL,'NVMe',1000,NULL,NULL,NULL,NULL,NULL,NULL,3500,420),
((SELECT id FROM component_types WHERE name='STORAGE'),'Samsung','970 Evo Plus 1TB NVMe',NULL,NULL,NULL,'NVMe',1000,NULL,NULL,NULL,NULL,NULL,NULL,5000,580),
((SELECT id FROM component_types WHERE name='STORAGE'),'Samsung','980 Pro 1TB NVMe',NULL,NULL,NULL,'NVMe',1000,NULL,NULL,NULL,NULL,NULL,NULL,7000,750),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'ASUS','Prime H510M-E','LGA1200','DDR4','H510',NULL,NULL,NULL,NULL,64,NULL,NULL,NULL,1064,500),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'Gigabyte','H510M H','LGA1200','DDR4','H510',NULL,NULL,NULL,NULL,64,NULL,NULL,NULL,1064,480),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'MSI','B560M PRO','LGA1200','DDR4','B560',NULL,NULL,NULL,NULL,128,NULL,NULL,NULL,1128,720),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'ASUS','Prime H610M-A DDR4','LGA1700','DDR4','H610',NULL,NULL,NULL,NULL,64,NULL,NULL,NULL,1064,620),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'Gigabyte','H610M H DDR4','LGA1700','DDR4','H610',NULL,NULL,NULL,NULL,64,NULL,NULL,NULL,1064,590),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'MSI','PRO B660M-A DDR4','LGA1700','DDR4','B660',NULL,NULL,NULL,NULL,128,NULL,NULL,NULL,1128,900),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'ASUS','TUF B660M-PLUS DDR4','LGA1700','DDR4','B660',NULL,NULL,NULL,NULL,128,NULL,NULL,NULL,1128,1150),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'Gigabyte','B760M DS3H DDR4','LGA1700','DDR4','B760',NULL,NULL,NULL,NULL,128,NULL,NULL,NULL,1128,950),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'ASUS','Prime B760M-A DDR5','LGA1700','DDR5','B760',NULL,NULL,NULL,NULL,128,NULL,NULL,NULL,1128,1250),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'ASUS','Prime A520M-E','AM4','DDR4','A520',NULL,NULL,NULL,NULL,64,NULL,NULL,NULL,1064,420),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'Gigabyte','A520M S2H','AM4','DDR4','A520',NULL,NULL,NULL,NULL,64,NULL,NULL,NULL,1064,450),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'MSI','B450M PRO-VDH MAX','AM4','DDR4','B450',NULL,NULL,NULL,NULL,128,NULL,NULL,NULL,1128,560),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'ASUS','Prime B550M-A','AM4','DDR4','B550',NULL,NULL,NULL,NULL,128,NULL,NULL,NULL,1128,720),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'Gigabyte','B550M Aorus Elite','AM4','DDR4','B550',NULL,NULL,NULL,NULL,128,NULL,NULL,NULL,1128,850),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'ASUS','Prime A620M-A','AM5','DDR5','A620',NULL,NULL,NULL,NULL,128,NULL,NULL,NULL,1128,850),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'Gigabyte','B650M DS3H','AM5','DDR5','B650',NULL,NULL,NULL,NULL,192,NULL,NULL,NULL,1192,1150),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'MSI','PRO B650M-A WIFI','AM5','DDR5','B650',NULL,NULL,NULL,NULL,192,NULL,NULL,NULL,1192,1450),
((SELECT id FROM component_types WHERE name='MOTHERBOARD'),'ASUS','TUF Gaming B650M-PLUS','AM5','DDR5','B650',NULL,NULL,NULL,NULL,192,NULL,NULL,NULL,1192,1650),
((SELECT id FROM component_types WHERE name='PSU'),'PCYes','Electro V2 400W',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,400,'80 Plus',NULL,400,180),
((SELECT id FROM component_types WHERE name='PSU'),'Corsair','CV450',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,450,'80 Plus Bronze',NULL,450,280),
((SELECT id FROM component_types WHERE name='PSU'),'Corsair','CV550',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,550,'80 Plus Bronze',NULL,550,350),
((SELECT id FROM component_types WHERE name='PSU'),'MSI','MAG A550BN',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,550,'80 Plus Bronze',NULL,550,330),
((SELECT id FROM component_types WHERE name='PSU'),'Cooler Master','MWE 650 Bronze',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,650,'80 Plus Bronze',NULL,650,430),
((SELECT id FROM component_types WHERE name='PSU'),'Corsair','CX650',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,650,'80 Plus Bronze',NULL,650,480),
((SELECT id FROM component_types WHERE name='PSU'),'XPG','Pylon 750W',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,750,'80 Plus Bronze',NULL,750,520),
((SELECT id FROM component_types WHERE name='PSU'),'Corsair','RM750e',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,750,'80 Plus Gold',NULL,750,750),
((SELECT id FROM component_types WHERE name='PSU'),'XPG','Core Reactor 850W',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,850,'80 Plus Gold',NULL,850,850),
((SELECT id FROM component_types WHERE name='PSU'),'Corsair','RM850e',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,850,'80 Plus Gold',NULL,850,900);


INSERT INTO component_offers (component_id, store_id, product_title, product_url, price)
SELECT c.id, s.id, c.brand || ' ' || c.model, s.base_url || '/busca/' || replace(lower(c.model),' ','-'), ROUND((c.msrp_price * (0.92 + random() * 0.16))::numeric, 2)
FROM components_catalog c CROSS JOIN stores s WHERE c.msrp_price IS NOT NULL;
INSERT INTO compatibility_rules (rule_name, source_type_id, target_type_id, rule_description) VALUES
('CPU e placa-mãe por socket', (SELECT id FROM component_types WHERE name='CPU'), (SELECT id FROM component_types WHERE name='MOTHERBOARD'), 'O socket do processador precisa ser igual ao socket da placa-mãe.'),
('RAM e placa-mãe por DDR', (SELECT id FROM component_types WHERE name='RAM'), (SELECT id FROM component_types WHERE name='MOTHERBOARD'), 'O tipo da RAM precisa ser suportado pela placa-mãe, por exemplo DDR4 ou DDR5.'),
('GPU e fonte por consumo', (SELECT id FROM component_types WHERE name='GPU'), (SELECT id FROM component_types WHERE name='PSU'), 'A fonte precisa suportar o consumo estimado da GPU, CPU e margem de segurança.'),
('Storage e interface', (SELECT id FROM component_types WHERE name='STORAGE'), (SELECT id FROM component_types WHERE name='MOTHERBOARD'), 'O armazenamento precisa usar interface suportada, como SATA ou NVMe.');
CREATE OR REPLACE VIEW component_cost_benefit AS SELECT c.id, ct.name AS component_type, c.brand, c.model, c.benchmark_score, COALESCE(MIN(o.price), c.msrp_price) AS best_price, CASE WHEN COALESCE(MIN(o.price), c.msrp_price) > 0 THEN c.benchmark_score / COALESCE(MIN(o.price), c.msrp_price) ELSE NULL END AS cost_benefit FROM components_catalog c JOIN component_types ct ON ct.id = c.component_type_id LEFT JOIN component_offers o ON o.component_id = c.id AND o.in_stock = true GROUP BY c.id, ct.name, c.brand, c.model, c.benchmark_score, c.msrp_price;
CREATE OR REPLACE VIEW user_analysis_history AS SELECT a.id, a.user_id, u.full_name, p.name AS purpose, p.display_name AS purpose_label, a.processing_status, a.summary, a.created_at, COUNT(DISTINCT ac.id) AS detected_components, COUNT(DISTINCT ri.id) AS recommendations FROM analyses a LEFT JOIN users u ON u.id = a.user_id LEFT JOIN purposes p ON p.id = a.purpose_id LEFT JOIN analysis_components ac ON ac.analysis_id = a.id LEFT JOIN recommendation_items ri ON ri.analysis_id = a.id GROUP BY a.id, a.user_id, u.full_name, p.name, p.display_name, a.processing_status, a.summary, a.created_at;
CREATE OR REPLACE VIEW frontend_analysis_response AS SELECT a.id AS analysis_id, p.name AS objetivo, a.summary AS resumo, a.raw_ocr_text AS texto_extraido, COALESCE(jsonb_agg(DISTINCT jsonb_build_object('tipo', ct.name, 'nome', ac.component_name, 'specAtual', ac.current_spec, 'status', ac.status, 'mensagem', ac.message)) FILTER (WHERE ac.id IS NOT NULL), '[]'::jsonb) AS componentes FROM analyses a LEFT JOIN purposes p ON p.id = a.purpose_id LEFT JOIN analysis_components ac ON ac.analysis_id = a.id LEFT JOIN component_types ct ON ct.id = ac.component_type_id GROUP BY a.id, p.name, a.summary, a.raw_ocr_text;
