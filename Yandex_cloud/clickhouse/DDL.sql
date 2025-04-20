CREATE TABLE orders (
    order_id UInt64,
    user_id UInt32,
    total_amount Decimal(10, 2),
    payment_status String,
    order_date Date
) ENGINE = MergeTree()
ORDER BY (order_date, order_id);

CREATE TABLE order_items (
    item_id UInt64,
    order_id UInt64,
    product_id UInt32,
    price Decimal(10, 2),
    quantity UInt32
) ENGINE = MergeTree()
ORDER BY (order_id, item_id);