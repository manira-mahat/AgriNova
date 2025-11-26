# AgriNova Deployment Guide

## Development vs Production

### Current Setup (Development)
- ✅ SQLite database
- ✅ DEBUG = True
- ✅ Local development server
- ✅ CORS allows all origins

### Production Requirements
- MySQL/PostgreSQL database
- DEBUG = False
- Production-grade server (Gunicorn/uWSGI)
- Restricted CORS origins
- HTTPS enabled
- Environment variables for secrets
- Static files served via CDN/Nginx

---

## Local Development (Current)

### Running the Server
```powershell
python manage.py runserver
```

Server: http://127.0.0.1:8000/

### Admin Panel
http://127.0.0.1:8000/admin/

---

## Production Deployment Options

### Option 1: Heroku (Easiest)

#### Step 1: Install Heroku CLI
Download from: https://devcenter.heroku.com/articles/heroku-cli

#### Step 2: Create Procfile
```
web: gunicorn agrinova_backend.wsgi --log-file -
```

#### Step 3: Update requirements.txt
Add:
```
gunicorn==21.2.0
dj-database-url==2.1.0
whitenoise==6.6.0
psycopg2-binary==2.9.9
```

#### Step 4: Update settings.py
```python
import dj_database_url
import os

# Security
SECRET_KEY = os.environ.get('SECRET_KEY', 'your-secret-key')
DEBUG = os.environ.get('DEBUG', 'False') == 'True'
ALLOWED_HOSTS = ['your-app.herokuapp.com', 'localhost']

# Database
DATABASES = {
    'default': dj_database_url.config(
        default='sqlite:///db.sqlite3',
        conn_max_age=600
    )
}

# Static files
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
MIDDLEWARE.insert(1, 'whitenoise.middleware.WhiteNoiseMiddleware')
```

#### Step 5: Deploy
```powershell
heroku login
heroku create agrinova-backend
git init
git add .
git commit -m "Initial commit"
git push heroku main
heroku run python manage.py migrate
heroku run python manage.py seed_crops
heroku run python manage.py seed_markets
heroku run python manage.py createsuperuser
```

---

### Option 2: AWS EC2

#### Step 1: Launch EC2 Instance
- Ubuntu 22.04 LTS
- t2.micro (free tier)
- Configure security groups (80, 443, 22)

#### Step 2: Connect and Setup
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip

# Update system
sudo apt update && sudo apt upgrade -y

# Install Python and dependencies
sudo apt install python3-pip python3-venv nginx -y

# Install MySQL
sudo apt install mysql-server libmysqlclient-dev -y
```

#### Step 3: Setup Project
```bash
# Create project directory
mkdir /var/www/agrinova
cd /var/www/agrinova

# Clone your code or upload
# Setup virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install gunicorn
```

#### Step 4: Configure MySQL
```bash
sudo mysql

CREATE DATABASE agrinova_db CHARACTER SET utf8mb4;
CREATE USER 'agrinova_user'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON agrinova_db.* TO 'agrinova_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Update settings.py:
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'agrinova_db',
        'USER': 'agrinova_user',
        'PASSWORD': 'strong_password',
        'HOST': 'localhost',
        'PORT': '3306',
    }
}
```

#### Step 5: Setup Gunicorn
Create `/etc/systemd/system/agrinova.service`:
```ini
[Unit]
Description=AgriNova Django Application
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/var/www/agrinova
Environment="PATH=/var/www/agrinova/venv/bin"
ExecStart=/var/www/agrinova/venv/bin/gunicorn \
    --workers 3 \
    --bind unix:/var/www/agrinova/agrinova.sock \
    agrinova_backend.wsgi:application

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl start agrinova
sudo systemctl enable agrinova
```

#### Step 6: Configure Nginx
Create `/etc/nginx/sites-available/agrinova`:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location = /favicon.ico { access_log off; log_not_found off; }
    
    location /static/ {
        root /var/www/agrinova;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/var/www/agrinova/agrinova.sock;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/agrinova /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx
```

#### Step 7: SSL with Let's Encrypt
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d your-domain.com
```

---

### Option 3: DigitalOcean App Platform

#### Step 1: Create Account
https://www.digitalocean.com/

#### Step 2: Create App
- Connect GitHub repository
- Choose Python
- Add environment variables

#### Step 3: Add Database
- Create managed MySQL database
- Link to app

#### Step 4: Configure
Add `app.yaml`:
```yaml
name: agrinova-backend
services:
- name: web
  github:
    repo: your-repo/agrinova
    branch: main
  run_command: gunicorn agrinova_backend.wsgi --bind 0.0.0.0:8080
  environment_slug: python
  envs:
  - key: DEBUG
    value: "False"
  - key: SECRET_KEY
    value: "${SECRET_KEY}"
databases:
- name: agrinova-db
  engine: MYSQL
```

---

## Environment Variables

### Required for Production
```env
SECRET_KEY=your-very-secret-key-here
DEBUG=False
ALLOWED_HOSTS=your-domain.com,www.your-domain.com

# Database
DB_ENGINE=django.db.backends.mysql
DB_NAME=agrinova_db
DB_USER=agrinova_user
DB_PASSWORD=your-db-password
DB_HOST=localhost
DB_PORT=3306

# CORS
CORS_ALLOWED_ORIGINS=https://your-flutter-app.com
```

### Update settings.py
```python
import os
from pathlib import Path

SECRET_KEY = os.environ.get('SECRET_KEY')
DEBUG = os.environ.get('DEBUG', 'False') == 'True'
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',')

DATABASES = {
    'default': {
        'ENGINE': os.environ.get('DB_ENGINE', 'django.db.backends.sqlite3'),
        'NAME': os.environ.get('DB_NAME', BASE_DIR / 'db.sqlite3'),
        'USER': os.environ.get('DB_USER', ''),
        'PASSWORD': os.environ.get('DB_PASSWORD', ''),
        'HOST': os.environ.get('DB_HOST', ''),
        'PORT': os.environ.get('DB_PORT', ''),
    }
}

CORS_ALLOWED_ORIGINS = os.environ.get(
    'CORS_ALLOWED_ORIGINS', 
    'http://localhost:3000'
).split(',')
```

---

## Static Files in Production

### Install WhiteNoise
```bash
pip install whitenoise
```

### Update settings.py
```python
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',  # Add this
    ...
]

STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
```

### Collect Static Files
```bash
python manage.py collectstatic --noinput
```

---

## Database Migration in Production

### Backup First
```bash
# For MySQL
mysqldump -u username -p agrinova_db > backup.sql

# For SQLite
cp db.sqlite3 db.sqlite3.backup
```

### Run Migrations
```bash
python manage.py migrate
```

### Seed Data
```bash
python manage.py seed_crops
python manage.py seed_markets
```

---

## Security Checklist

### Before Deploying
- [ ] Set `DEBUG = False`
- [ ] Change `SECRET_KEY` to secure random value
- [ ] Set proper `ALLOWED_HOSTS`
- [ ] Restrict `CORS_ALLOWED_ORIGINS`
- [ ] Use environment variables for secrets
- [ ] Enable HTTPS
- [ ] Configure firewall
- [ ] Set up database backups
- [ ] Enable logging
- [ ] Review admin access
- [ ] Update all dependencies
- [ ] Remove test accounts

### Additional Security
```python
# settings.py for production

# Security settings
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'

# HSTS
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
```

---

## Monitoring & Logging

### Setup Logging
```python
# settings.py
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'ERROR',
            'class': 'logging.FileHandler',
            'filename': '/var/log/agrinova/django.log',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'ERROR',
            'propagate': True,
        },
    },
}
```

### Monitoring Tools
- **Sentry** - Error tracking
- **New Relic** - Performance monitoring
- **DataDog** - Infrastructure monitoring

---

## Backup Strategy

### Automated Database Backups
```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/agrinova"

# MySQL backup
mysqldump -u username -p password agrinova_db > $BACKUP_DIR/db_$DATE.sql

# Compress
gzip $BACKUP_DIR/db_$DATE.sql

# Delete old backups (keep 30 days)
find $BACKUP_DIR -name "db_*.sql.gz" -mtime +30 -delete
```

### Setup Cron Job
```bash
crontab -e

# Run backup daily at 2 AM
0 2 * * * /path/to/backup.sh
```

---

## Performance Optimization

### Database Indexing
```python
# models.py
class Crop(models.Model):
    name = models.CharField(max_length=100, unique=True, db_index=True)
    ...
```

### Query Optimization
```python
# Use select_related for foreign keys
recommendations = CropRecommendation.objects.select_related('user', 'soil_data')

# Use prefetch_related for many-to-many
recommendations = CropRecommendation.objects.prefetch_related('recommended_crops')
```

### Caching (Future Enhancement)
```bash
pip install django-redis
```

```python
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
    }
}
```

---

## CI/CD Pipeline (GitHub Actions)

Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.13
    
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
    
    - name: Run tests
      run: |
        python manage.py test
    
    - name: Deploy to Heroku
      uses: akhileshns/heroku-deploy@v3.12.12
      with:
        heroku_api_key: ${{secrets.HEROKU_API_KEY}}
        heroku_app_name: "agrinova-backend"
        heroku_email: "your-email@example.com"
```

---

## Post-Deployment

### 1. Verify Deployment
```bash
curl https://your-domain.com/api/crops/crops/
```

### 2. Create Admin User
```bash
python manage.py createsuperuser
```

### 3. Test All Endpoints
Use `test_api.py` with production URL

### 4. Monitor Logs
```bash
# Heroku
heroku logs --tail

# AWS/DigitalOcean
tail -f /var/log/agrinova/django.log
```

---

## Scaling Considerations

### When to Scale?
- Response time > 2 seconds
- CPU usage > 70%
- Database connections maxed out
- Error rate increasing

### Horizontal Scaling
- Add more application servers
- Use load balancer (AWS ELB, Nginx)
- Separate database server

### Vertical Scaling
- Increase server RAM/CPU
- Upgrade database instance

---

## Cost Estimates

### Heroku (Hobby Tier)
- Dyno: $7/month
- Postgres Addon: $9/month
- **Total: ~$16/month**

### AWS EC2
- t2.micro: Free tier (1 year)
- After free tier: ~$10/month
- RDS MySQL: ~$15/month
- **Total: ~$25/month**

### DigitalOcean
- Basic Droplet: $6/month
- Managed Database: $15/month
- **Total: ~$21/month**

---

## Support & Maintenance

### Regular Tasks
- [ ] Weekly: Check logs
- [ ] Weekly: Monitor performance
- [ ] Monthly: Update dependencies
- [ ] Monthly: Database backup verification
- [ ] Quarterly: Security audit
- [ ] Yearly: SSL certificate renewal (auto with Let's Encrypt)

---

**Ready to Deploy!** Choose your platform and follow the guide above. 🚀
