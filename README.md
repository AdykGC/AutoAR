# AutoAR

### Frontend:
`JavaScript`
`Vue.js`
`Vite`
`Axios` 
`CSS`

### Backend:
`Python`
`Django`
`Django REST Framework (DRF)`
`Cross-Origin Resource Sharing (CORS) : django-cors-headers`

### Database:
`Sqlite3`

# Установка и запуск

1. Клонирование репозитория

```git clone https://github.com/AdykGC/AutoAR.git```

2. Переход в директорию IDK

```cd AutoAR```

| Запуск серверов                              | Frontend                                     | Backend                                      |
|----------------------------------------------|----------------------------------------------|----------------------------------------------|
| Перейти в папку                              | cd frontend                                  | cd backend                                   |
| Создание виртуального окружения              |                                              | python3 -m venv venv                         |
| Активация виртуального окружения             |                                              | source venv/bin/activate                     |
| Установка зависимостей                       | npm install                                  | pip3 install -r requirements.txt             |
|                                              | npm install axios                            |                                              |
| Создание .env                                | touch .env                                   | touch .env                                   |
| Заполнение .env                              |                                              |                                              |
| Создать миграции                             |                                              | python manage.py makemigrations              |
| Применить миграции                           |                                              | python manage.py migrate                     |
| Запуск серверов                              | npm run dev                                  | python3 manage.py runserver                  |


# Пример .Env

### Frontend

| Key                                          | Value                                        | Info                                         |
|----------------------------------------------|----------------------------------------------|----------------------------------------------|
| VITE_API_URL                                 | 'URL_of_Django_Server/api'                   | Value                                        |

### Backend

| Key                                          | Value                                        | Info                                         |
|----------------------------------------------|----------------------------------------------|----------------------------------------------|
| DJANGO_SECRET_KEY                            | 'SecretKeyGeneratedByTheInstruction'         | Value                                        |
| DJANGO_DEBUG                                 | False                                        | Value                                        |

```python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'```
DJANGO_SECRET_KEY=полученное_значение