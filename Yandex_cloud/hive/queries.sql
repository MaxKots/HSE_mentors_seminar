SELECT 
    currency,
    COUNT(*) as transaction_count,
    SUM(amount) as total_sum,
    AVG(amount) as avg_transaction
FROM transactions_v2
GROUP BY currency;

SELECT 
    t.transaction_id,
    t.user_id,
    COUNT(l.log_id) as log_entries_count,
    SUM(t.amount) as transaction_amount,
    AVG(t.amount) as avg_amount
FROM transactions_v2 t
LEFT JOIN logs_v2 l ON t.transaction_id = l.transaction_id
GROUP BY t.transaction_id, t.user_id;

SELECT 
    DATE(transaction_date) as day,
    COUNT(*) as transaction_count,
    SUM(amount) as daily_total,
    AVG(amount) as avg_amount
FROM transactions_v2
GROUP BY DATE(transaction_date)
ORDER BY day;

SELECT 
    user_id,
    COUNT(*) as transaction_count,
    SUM(amount) as total_spent
FROM transactions_v2
GROUP BY user_id
ORDER BY total_spent DESC
LIMIT 10;