# Rubicon

### Frontend:
`JavaScript`
`Vue.js`
`Vite`
`Axios` 
`CSS`

### Backend:
`Php`
`Laravel`
`Laravel Sanctum`
`Spatie Permission`
`Backpack`

### Mobile:
`Flutter`

### Database:
`PostgreSql`

# Установка и запуск

1. Клонирование репозитория

```git clone https://github.com/AdykGC/AutoAR.git```

2. Переход в директорию IDK

```cd AutoAR```

| Запуск серверов                              | Backend                                      | Frontend                                     | Mobile                                       |
|----------------------------------------------|----------------------------------------------|----------------------------------------------|----------------------------------------------|
| Перейти в папку                              | cd backend                                   | cd frontend_website                          | cd frontend_mobile                           |
| Установка зависимостей                       | composer require                             | npm install                                  | flutter pub get                              |
|                                              |                                              | npm install axios                            | flutter doctor                               |
|                                              |                                              |                                              | cd ios                                       |
|                                              |                                              |                                              | pod install                                  |
|                                              |                                              |                                              | cd ..                                        |
|                                              |                                              |                                              |                                              |
| Заполнение .env                              | cp .env.example .env                         | cp .env.example .env                         | cp .env.example .env                         |
|                                              |                                              |                                              |                                              |
|                                              | php artisan key:generate                     |                                              |                                              |
| Применить миграции                           | php artisan migrate                          |                                              |                                              |
|                                              |                                              |                                              |                                              |
| Запуск серверов                              | php artisan serve --host=0.0.0.0 --port=8000 | npm run dev                                  | open ios/Runner.xcworkspace                  |
| Получить IP-адрес                            | ipconfig getifaddr en0                       |                                              |                                              |
