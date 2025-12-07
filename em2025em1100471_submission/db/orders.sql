-- Create orders table
CREATE TABLE IF NOT EXISTS em2025em1100471_orders (
    order_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    restaurant_name VARCHAR(255) NOT NULL,
    item VARCHAR(255) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    order_status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert 10 initial sample records
INSERT INTO em2025em1100471_orders (customer_name, restaurant_name, item, amount, order_status) VALUES
('John Doe', 'Burger Junction', 'Veg Burger', 220.00, 'PLACED'),
('Jane Smith', 'Pizza Palace', 'Margherita Pizza', 350.00, 'PREPARING'),
('Mike Johnson', 'Sushi World', 'California Roll', 450.00, 'DELIVERED'),
('Sarah Williams', 'Taco Bell', 'Chicken Tacos', 180.00, 'PLACED'),
('David Brown', 'Pasta House', 'Alfredo Pasta', 320.00, 'PREPARING'),
('Emily Davis', 'Burger Junction', 'Chicken Burger', 250.00, 'DELIVERED'),
('Robert Miller', 'Pizza Palace', 'Pepperoni Pizza', 400.00, 'PLACED'),
('Lisa Wilson', 'Sushi World', 'Dragon Roll', 500.00, 'PREPARING'),
('James Moore', 'Taco Bell', 'Veg Burrito', 200.00, 'DELIVERED'),
('Maria Garcia', 'Pasta House', 'Penne Arrabiata', 280.00, 'PLACED');

-- Verify insertion
SELECT COUNT(*) as total_orders FROM em2025em1100471_orders;
