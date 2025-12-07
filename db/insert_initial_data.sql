-- Insert 10 initial sample records
INSERT INTO em2025em1100471_orders (customer_name, restaurant_name, item, amount, order_status, created_at) VALUES
('John Doe', 'Burger Junction', 'Veg Burger', 220.00, 'PLACED', '2025-01-18 12:24:00'),
('Jane Smith', 'Pizza Palace', 'Margherita Pizza', 350.00, 'PREPARING', '2025-01-18 12:25:00'),
('Mike Johnson', 'Sushi World', 'California Roll', 450.00, 'DELIVERED', '2025-01-18 12:26:00'),
('Sarah Williams', 'Taco Bell', 'Chicken Tacos', 180.00, 'PLACED', '2025-01-18 12:27:00'),
('David Brown', 'Pasta House', 'Alfredo Pasta', 320.00, 'PREPARING', '2025-01-18 12:28:00'),
('Emily Davis', 'Burger Junction', 'Chicken Burger', 250.00, 'DELIVERED', '2025-01-18 12:29:00'),
('Robert Miller', 'Pizza Palace', 'Pepperoni Pizza', 400.00, 'PLACED', '2025-01-18 12:30:00'),
('Lisa Wilson', 'Sushi World', 'Dragon Roll', 500.00, 'PREPARING', '2025-01-18 12:31:00'),
('James Moore', 'Taco Bell', 'Veg Burrito', 200.00, 'DELIVERED', '2025-01-18 12:32:00'),
('Maria Garcia', 'Pasta House', 'Penne Arrabiata', 280.00, 'PLACED', '2025-01-18 12:33:00');

-- Verify insertion
SELECT COUNT(*) as total_orders FROM em2025em1100471_orders;
SELECT * FROM em2025em1100471_orders ORDER BY created_at;
