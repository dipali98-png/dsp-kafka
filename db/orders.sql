-- Create orders table
CREATE TABLE IF NOT EXISTS 2025em1100471_orders (
    order_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    restaurant_name VARCHAR(255) NOT NULL,
    item VARCHAR(255) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    order_status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample incremental records (to be inserted later for testing)
-- INSERT INTO 2025em1100471_orders (customer_name, restaurant_name, item, amount, order_status) VALUES
-- ('Tom Anderson', 'Burger Junction', 'Cheese Burger', 240.00, 'PLACED'),
-- ('Anna Taylor', 'Pizza Palace', 'Veggie Supreme', 380.00, 'PLACED'),
-- ('Chris Martin', 'Sushi World', 'Spicy Tuna Roll', 480.00, 'PLACED'),
-- ('Laura White', 'Taco Bell', 'Beef Quesadilla', 220.00, 'PLACED'),
-- ('Kevin Lee', 'Pasta House', 'Carbonara', 340.00, 'PLACED');
