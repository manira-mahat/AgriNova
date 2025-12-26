# MySQL Setup Guide for AgriNova

## Prerequisites
- MySQL server installed on your Mac
- `uv` package manager

## Step 1: Install/Start MySQL

If you don't have MySQL installed:
```bash
brew install mysql
brew services start mysql
```

Check MySQL is running:
```bash
mysql --version
```

## Step 2: Create Database

Login to MySQL:
```bash
mysql -u root -p
```

Create the database:
```sql
CREATE DATABASE agrinova_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SHOW DATABASES;
EXIT;
```

## Step 3: Update Database Password (if needed)

Edit `agrinova_backend/settings.py` and update the MySQL password:
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'agrinova_db',
        'USER': 'root',
        'PASSWORD': 'your_password_here',  # Update this!
        'HOST': 'localhost',
        'PORT': '3306',
    }
}
```

## Step 4: Install Dependencies with uv

```bash
cd agri_python
uv pip install -r requirements.txt
```

## Step 5: Run Migrations

```bash
uv run python manage.py makemigrations
uv run python manage.py migrate
```

## Step 6: Seed Database

```bash
uv run python manage.py seed_crops
uv run python manage.py seed_markets
```

## Step 7: Create Superuser

```bash
uv run python manage.py createsuperuser
```

## Step 8: Run Server

```bash
uv run python manage.py runserver
```

## Verify Setup

Visit: http://127.0.0.1:8000/swagger/

## Troubleshooting

### Error: Access denied for user 'root'
Update your MySQL password in settings.py

### Error: mysqlclient not found
```bash
uv pip install mysqlclient
```

### Error: Can't connect to MySQL server
Start MySQL:
```bash
brew services start mysql
```

### Error: Database doesn't exist
Create database again:
```bash
mysql -u root -p
CREATE DATABASE agrinova_db;
```
