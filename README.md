# devops-ci-cd

### Django + PostgreSQL + Nginx (Docker)

#### Запуск
docker-compose up --build

#### Сервіси
- Django
- PostgreSQL
- Nginx

##### Опис проєкту
Цей проєкт демонструє використання:
- **Django** — для вебзастосунку
- **PostgreSQL** — для збереження даних
- **Nginx** — як вебсервер та проксі

Всі сервіси контейнеризовані за допомогою Docker і керуються через Docker Compose.


##### Структура проєкту

django-docker-project/
│
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
├── .env
│
├── nginx/
│   └── nginx.conf
│
└── app/
    ├── manage.py
    ├── core/
    │   ├── __init__.py
    │   ├── asgi.py
    │   ├── settings.py
    │   ├── urls.py
    │   └── wsgi.py
    └── core_app/
        ├── migrations/
        ├── __init__.py
        ├── admin.py
        ├── apps.py
        ├── models.py
        ├── tests.py
        └── views.py


###### Процес створення

1. **Ініціалізація Django-проєкту**  
   - Створено новий проєкт:
     ```bash
     django-admin startproject core app
     ```
   - Додано базовий додаток:
     ```bash
     python manage.py startapp core_app
     ```

2. **Налаштування PostgreSQL**  
   - Створено файл `.env` із змінними:
     ```env
    DEBUG=
    SECRET_KEY=
    POSTGRES_DB=
    POSTGRES_USER=
    POSTGRES_PASSWORD=
    POSTGRES_HOST=
    POSTGRES_PORT=
     ```
   - Підключено PostgreSQL у `settings.py`:
     ```python
     DATABASES = {
         'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': os.environ.get('POSTGRES_DB'),
            'USER': os.environ.get('POSTGRES_USER'),
            'PASSWORD': os.environ.get('POSTGRES_PASSWORD'),
            'HOST': os.environ.get('POSTGRES_HOST', 'db'),
            'PORT': os.environ.get('POSTGRES_PORT', 5432),
        }
     }
     ```

3. **Створення Dockerfile для Django**  
   - Використовується `python:3.11-slim`  
   - Встановлення залежностей через `requirements.txt`  
   - Запуск сервера через `gunicorn`

4. **Створення docker-compose.yml**  
   - Описано три сервіси:
     - `db` — PostgreSQL
     - `web` — Django-застосунок
     - `nginx` — проксування запитів на Django
   - Додано volume для збереження даних PostgreSQL

5. **Налаштування Nginx**  
   - Файл `nginx/nginx.conf`:
     ```nginx
     server {
         listen 80;

         location / {
             proxy_pass http://web:8000;
             proxy_set_header Host $host;
             proxy_set_header X-Real-IP $remote_addr;
             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
         }
     }
     ```

6. **Запуск проєкту**  
   ```bash
   docker-compose up --build
   ```

```bash
CONTAINER ID   IMAGE                       COMMAND                  CREATED          STATUS          PORTS                                 NAMES
7cdcece068d5   nginx:latest                "/docker-entrypoint.…"   36 minutes ago   Up 36 minutes   0.0.0.0:80->80/tcp, [::]:80->80/tcp   nginx_server
a99e59b6e57d   django-docker-project-web   "gunicorn core.wsgi:…"   36 minutes ago   Up 36 minutes                                         django_app
dbd2a926e261   postgres:15                 "docker-entrypoint.s…"   36 minutes ago   Up 36 minutes   5432/tcp                              postgres_db
```

Django доступний на http://localhost через Nginx
PostgreSQL працює у контейнері db
Усі сервіси повністю ізольовані і готові до використання


###### Commands

###### Docker Compose
```bash
docker-compose up -d                # Запуск в фоні
docker-compose up                   # Запуск з логами
docker-compose down                 # Зупинка контейнерів
docker-compose down -v              # Зупинка + видалення контейнерів, томів, мереж
docker-compose up --build           # Перебудова образів і запуск
docker-compose logs                 # Логи усіх контейнерів
docker-compose logs -f              # Живі логи
docker-compose logs web             # Логи конкретного контейнера
docker-compose exec web bash        # Shell у контейнері web
docker-compose exec web python manage.py migrate
docker-compose exec db psql -U <user> -d <db>
```

###### Docker
```bash
docker ps                            # Активні контейнери
docker ps -a                         # Усі контейнери
docker stop <container>              # Зупинка контейнера
docker start <container>             # Старт контейнера
docker logs <container>              # Логи контейнера
docker logs -f <container>           # Живі логи
docker exec -it <container> bash     # Shell у контейнері
docker exec -it <container> python manage.py createsuperuser
docker rm <container>                # Видалення контейнера
docker rmi <image>                   # Видалення образу
```

###### Volumes
``` bash
docker volume ls                     # Перегляд томів
docker volume rm <volume>            # Видалення тома
docker system prune -a --volumes     # Повне очищення (контейнери, образи, томи, мережі)
```

###### Django Commands in Docker
```bash
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser
docker-compose exec web python manage.py collectstatic --noinput
docker-compose exec web python manage.py shell
```

###### Перезапуск контейнерів після зміни .env:
```bash
docker-compose down -v
docker-compose up --build -d
```