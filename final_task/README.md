# Проект по работе связки Trino + PostgreSQL + MySQL + Iceberg

## Полный гайд по установке софта для работы с JupyterLab ([здесь](https://github.com/MaxKots/installation_guides/tree/main) другие гайды)

### Оглавление:
1. [Подготовка компонентов](#подготовка_компонентов)
3. [Проверка работоспособности](#проверка-работоспособности)
4. [Полная очистка](#полная-очистка)

Само собой, тебе нужен установленный docker и убедиться, что ранее установленный JH не запущен:
```
docker ps -a | grep -i jupyter
```

<details>
<summary><b>Башник для проверки портов, которые буду использовать</b></summary>

```bash
for port in 8080 5433 3307 9000 9001 9083; do
    if lsof -i :\$port > /dev/null 2>&1; then
        echo "Порт \$port занят"
        lsof -i :\$port
    else
        echo "Порт \$port свободен"
    fi
done
```
</details>

---

## Подготовка компонентов

### 1: Создание рабочей директории

```bash
# основная
mkdir -p ~/trino-lakehouse
cd ~/trino-lakehouse

# структура директорий
mkdir -p {trino/catalog,postgres/init,mysql/init,minio/data,hive-metastore,hive-data}
```

### 2: Создание конфигов

<details>
<summary><b>Конфиг Trino</b></summary>
    
```bash
# конфиг-файл
cat > ~/trino-lakehouse/trino/config.properties << 'EOF'
coordinator=true
node-scheduler.include-coordinator=true
http-server.http.port=8080
query.max-memory=2GB
query.max-memory-per-node=1GB
discovery.uri=http://localhost:8080
EOF

cat > ~/trino-lakehouse/trino/jvm.config << 'EOF'
-server
-Xmx2G
-XX:InitialRAMPercentage=80
-XX:MaxRAMPercentage=80
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+ExplicitGCInvokesConcurrent
-XX:+HeapDumpOnOutOfMemoryError
-XX:+ExitOnOutOfMemoryError
-Djdk.attach.allowAttachSelf=true
EOF

cat > ~/trino-lakehouse/trino/node.properties << 'EOF'
node.environment=docker
node.id=trino-coordinator
node.data-dir=/data/trino
EOF

cat > ~/trino-lakehouse/trino/log.properties << 'EOF'
io.trino=INFO
EOF
```
</details>

<details>
<summary><b>Конфиг Postgres</b></summary>

```bash
cat > ~/trino-lakehouse/trino/catalog/postgres.properties << 'EOF'
connector.name=postgresql
connection-url=jdbc:postgresql://postgres:5432/demo_db
connection-user=***USER***
connection-password=***PASSWORD***
EOF
```
</details>

<details>
<summary><b>Конфиг Mysql</b></summary>

```bash
cat > ~/trino-lakehouse/trino/catalog/mysql.properties << 'EOF'
connector.name=mysql
connection-url=jdbc:mysql://mysql:3306
connection-user=***USER***
connection-password=***PASSWORD***
EOF
```
</details>

<details>
<summary><b>Конфиг Iceberg</b></summary>

```bash
cat > ~/trino-lakehouse/trino/catalog/iceberg.properties << 'EOF'
connector.name=iceberg
iceberg.catalog.type=hive_metastore
hive.metastore.uri=thrift://hive-metastore:9083
hive.s3.endpoint=http://minio:9000
hive.s3.path-style-access=true
hive.s3.aws-access-key=***USER***
hive.s3.aws-secret-key=***PASSWORD***
iceberg.file-format=PARQUET
EOF
```
</details>

### 3: Скрипты инициализации баз данных

<details>
<summary><b>инициализация PostgreSQL</b></summary>

```bash
cat > ~/trino-lakehouse/postgres/init/01-init.sql << 'EOF'
-- Создание юзера для Trino (IF NOT EXISTS для избежания ошибок)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '***USER***') THEN
        CREATE USER ***USER*** WITH PASSWORD '***PASSWORD***';
    END IF;
END
$$;

-- Выдача прав
GRANT ALL PRIVILEGES ON DATABASE demo_db TO ***USER***;

-- Подключение к бд demo_db
\c demo_db

-- права на схему
GRANT ALL PRIVILEGES ON SCHEMA public TO ***USER***;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ***USER***;

-- табличка клиентов
CREATE TABLE IF NOT EXISTS trn_customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- табличка заказов
CREATE TABLE IF NOT EXISTS trn_orders (
    order_id BIGSERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES trn_customers(customer_id),
    order_ts TIMESTAMP NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL
);

-- Заполнение таблички
INSERT INTO trn_customers (customer_name, email) VALUES
    ('Иван Иванов', 'ivan@example.com'),
    ('Мария Петрова', 'maria@example.com'),
    ('Алексей Сидоров', 'alex@example.com'),
    ('Елена Козлова', 'elena@example.com'),
    ('Дмитрий Новиков', 'dmitry@example.com'),
    ('Ольга Морозова', 'olga@example.com'),
    ('Сергей Волков', 'sergey@example.com'),
    ('Анна Лебедева', 'anna@example.com'),
    ('Николай Соколов', 'nikolay@example.com'),
    ('Татьяна Попова', 'tatiana@example.com')
ON CONFLICT DO NOTHING;

-- Выдача прав
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ***USER***;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO ***USER***;
EOF
```
</details>

<details>
<summary><b>инициализация Mysql</b></summary>
    
```bash
cat > ~/trino-lakehouse/mysql/init/01-init.sql << 'EOF'
-- создание бд
CREATE DATABASE IF NOT EXISTS demo_db;

-- создание юзера для trino
CREATE USER IF NOT EXISTS '***USER***'@'%' IDENTIFIED BY '***PASSWORD***';
GRANT ALL PRIVILEGES ON *.* TO '***USER***'@'%';
FLUSH PRIVILEGES;

USE demo_db;

-- Создание таблички платежей
CREATE TABLE IF NOT EXISTS trn_payments (
    payment_id BIGINT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    paid_at TIMESTAMP NOT NULL
);

-- создание индекса
CREATE INDEX idx_payments_order_id ON trn_payments(order_id);
CREATE INDEX idx_payments_paid_at ON trn_payments(paid_at);
EOF
```
</details>

### 4: Здоровенный docker compose

<details>
<summary><b>Содержимое</b></summary>
    
```bash
cat > ~/trino-lakehouse/docker-compose.yml << 'EOF'
version: '3.8'

services:
  # PostgreSQL
  postgres:
    image: postgres:15
    container_name: postgres
    hostname: postgres
    environment:
      POSTGRES_USER: ***USER***
      POSTGRES_PASSWORD: ***PASSWORD***
      POSTGRES_DB: demo_db
    ports:
      - "5433:5432"
    volumes:
      - ./postgres/init:/docker-entrypoint-initdb.d
      - postgres_data:/var/lib/postgresql/data
    networks:
      - trino-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Mysql - источник данных для платежей
  mysql:
    image: mysql:8.0
    container_name: mysql
    hostname: mysql
    environment:
      MYSQL_ROOT_PASSWORD: ***PASSWORD***
      MYSQL_DATABASE: demo_db
      MYSQL_USER: ***USER***
      MYSQL_PASSWORD: ***PASSWORD***
    ports:
      - "3307:3306"
    volumes:
      - ./mysql/init:/docker-entrypoint-initdb.d
      - mysql_data:/var/lib/mysql
    networks:
      - trino-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
    command: --default-authentication-plugin=mysql_native_password

  # Minio для айсберга
  minio:
    image: minio/minio:latest
    container_name: minio
    hostname: minio
    environment:
      MINIO_ROOT_USER: ***USER***
      MINIO_ROOT_PASSWORD: ***PASSWORD***
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
    networks:
      - trino-network
    command: server /data --console-address ":9001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 10s
      timeout: 5s
      retries: 5

  # создание бакета в MinIO
  minio-setup:
    image: minio/mc:latest
    container_name: minio-setup
    depends_on:
      minio:
        condition: service_healthy
    networks:
      - trino-network
    entrypoint: >
      /bin/sh -c "
      mc alias set myminio http://minio:9000 ***USER*** ***PASSWORD***;
      mc mb myminio/warehouse --ignore-existing;
      mc mb myminio/iceberg --ignore-existing;
      mc anonymous set public myminio/warehouse;
      mc anonymous set public myminio/iceberg;
      echo 'MinIO buckets created successfully';
      exit 0;
      "

  # Hive Metastore для айсберга
  hive-metastore:
    image: apache/hive:4.0.0
    container_name: hive-metastore
    hostname: hive-metastore
    environment:
      SERVICE_NAME: metastore
      DB_DRIVER: derby
    ports:
      - "9083:9083"
    volumes:
      - ./hive-data:/opt/hive/data    # Локальная директория вместо volume
    networks:
      - trino-network
    depends_on:
      minio-setup:
        condition: service_completed_successfully
    healthcheck:
      test: ["CMD", "bash", "-c", "cat < /dev/null > /dev/tcp/localhost/9083"]
      interval: 30s
      timeout: 10s
      retries: 10
      start_period: 120s

  # Trino
  trino:
    image: trinodb/trino:435
    container_name: trino
    hostname: trino
    ports:
      - "8080:8080"
    volumes:
      - ./trino/config.properties:/etc/trino/config.properties
      - ./trino/jvm.config:/etc/trino/jvm.config
      - ./trino/node.properties:/etc/trino/node.properties
      - ./trino/log.properties:/etc/trino/log.properties
      - ./trino/catalog:/etc/trino/catalog
      - trino_data:/data/trino
    networks:
      - trino-network
    depends_on:
      postgres:
        condition: service_healthy
      mysql:
        condition: service_healthy
      hive-metastore:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/v1/info"]
      interval: 10s
      timeout: 5s
      retries: 10

networks:
  trino-network:
    name: trino-network
    driver: bridge

volumes:
  postgres_data:
  mysql_data:
  minio_data:
  trino_data:
EOF
```
</details>

### 5: Запуск

```bash
cd ~/trino-lakehouse

# Пуск всех сервисов
docker-compose up -d

# Промониторь запуск
docker-compose ps

# Логи
docker-compose logs -f trino

# Здоровье контейнеров
docker ps --format "table {{.Names}}\t{{.Status}}"
```
![Должно быть так](https://github.com/MaxKots/HSE_mentors_seminar/edit/main/final_task/.assets/screen_1.jpg)


### 6: Подключение сети JupyterLab к Trino

```bash
# Подключение существующего jupyter к сети trino
docker network connect trino-network JupyterLab

# Проверка подключения
docker network inspect trino-network | grep -A 5 JupyterLab
```

### 7: Установка Python-клиента Trino в JupyterLab

```bash
# Установка trino→python→client
docker exec -it JupyterLab pip install trino pandas matplotlib seaborn

# Проверка установки
docker exec -it JupyterLab python -c "import trino; print('trino version:', trino.__version__)"
```

---

## Проверка работоспособности

### Проверка trino

<details>
<summary><b>Проверка сети</b></summary>
    
```
docker network inspect trino-network
```
</details>

<details>
<summary><b>Проверка Trino через CLI</b></summary>

```bash
# Залетай в контейнер Trino
docker exec -it trino trino

# В консоли Trino выполнить:
SHOW CATALOGS;
SHOW SCHEMAS FROM postgres;
SHOW TABLES FROM postgres.public;
SHOW SCHEMAS FROM mysql;
SHOW TABLES FROM mysql.demo_db;
exit
```
![Результат запросов](https://github.com/MaxKots/HSE_mentors_seminar/edit/main/final_task/.assets/screen_2.jpg)
</details>

<details>
<summary><b>Проверка Trino через curl</b></summary>

```bash
# проверка статуса Trino
curl -s http://localhost:8080/v1/info | python3 -m json.tool

# проверка доступных каталогов
curl -s http://localhost:8080/v1/statement -H "X-Trino-User: test" -d "SHOW CATALOGS"
```
</details>

### Проверка MinIO

Открой в браузере: http://localhost:9001
- Login: ***USER***
- Password: ***PASSWORD***

### Тест подключения из JupyterLab
```
docker exec -it JupyterLab ping trino
docker exec -it JupyterLab curl -s http://trino:8080/v1/info
```

### Проверка Jupyter
Сгенерируй токен командой:
```
docker exec JupyterLab jupyter server list
```
Зайди по адресу http://127.0.0.1:8888/

---

<details>
<summary><b>Полная очистка</b></summary>

```bash
cd ~/trino-lakehouse

# Остановка и удаление контейнеров
docker compose down -v

# Удаление volumes
docker volume rm trino-lakehouse_postgres_data trino-lakehouse_mysql_data \\
  trino-lakehouse_minio_data trino-lakehouse_hive_data trino-lakehouse_trino_data

# Удаление сети (отключив сначала JupyterLab)
docker network disconnect trino-network JupyterLab
docker network rm trino-network

# Удаление конфига
rm -rf ~/trino-lakehouse
```
</details>
