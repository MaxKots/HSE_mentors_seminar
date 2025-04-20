CREATE EXTERNAL TABLE transactions_v2 (
    transaction_id STRING,
    user_id STRING,
    transaction_date TIMESTAMP,
    amount DECIMAL(10,2),
    currency STRING,
    is_fraud INT,
    merchant_category STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3a://mkots-default-bucket/transactions/';

CREATE EXTERNAL TABLE logs_v2 (
    log_id STRING,
    transaction_id STRING,
    log_date TIMESTAMP,
    action STRING,
    details STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION 's3a://mkots-default-bucket/logs/'
TBLPROPERTIES (
    "skip.header.line.count"="0",
    "serialization.null.format"=""
);;