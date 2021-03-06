-- Get last 50 buy/sell greater then x amount in the last 24 hours
SELECT TO_CHAR(TO_TIMESTAMP(timestamp), 'DD/MM/YYYY HH24:MI:SS'), total, order_type, fill_type
FROM market_history
WHERE total > 2 AND to_timestamp(timestamp) > now() - interval '24 hour' 
ORDER BY timestamp DESC, total ASC
LIMIT 50;

-- Get the biggest 50 orders in the last 24 hours
SELECT TO_CHAR(TO_TIMESTAMP(timestamp), 'DD/MM/YYYY HH24:MI:SS'), total, order_type, fill_type
FROM market_history
WHERE to_timestamp(timestamp) > now() - interval '24 hour' 
ORDER BY total DESC;
LIMIT 50;

-- Get buy/sell sum total in the last x (hours, minutes ...)
SELECT order_type, SUM(total)
FROM market_history 
WHERE to_timestamp(timestamp) > now() - interval '10 hour' 
GROUP BY order_type
ORDER BY SUM(total) DESC;

-- Get buy/sell max total in the last x hours
SELECT order_type, MAX(total)
FROM market_history
WHERE to_timestamp(timestamp) > now() - interval '10 hour'
GROUP BY order_type
ORDER BY MAX(total) DESC;

-- Number of records in db
SELECT COUNT(*) FROM market_history;

-- DB size
\l+ bittrex