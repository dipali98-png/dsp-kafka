-- Insert 5 incremental test records
-- Run this after the producer and consumer are running to test incremental ingestion

INSERT INTO em2025em1100471_orders (customer_name, restaurant_name, item, amount, order_status) VALUES
('Tom Anderson', 'Burger Junction', 'Cheese Burger', 240.00, 'PLACED'),
('Anna Taylor', 'Pizza Palace', 'Veggie Supreme', 380.00, 'PLACED'),
('Chris Martin', 'Sushi World', 'Spicy Tuna Roll', 480.00, 'PLACED'),
('Laura White', 'Taco Bell', 'Beef Quesadilla', 220.00, 'PLACED'),
('Kevin Lee', 'Pasta House', 'Carbonara', 340.00, 'PLACED');

-- Verify insertion
SELECT COUNT(*) as total_orders FROM em2025em1100471_orders;
SELECT * FROM em2025em1100471_orders ORDER BY created_at DESC LIMIT 5;
