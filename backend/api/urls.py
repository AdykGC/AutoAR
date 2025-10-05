from django.urls import path, include
from rest_framework.routers import DefaultRouter

# ---------- MODEL ---------- 
from api.models import *

# ---------- SERIALIZER ---------- 
from api.serializers import *

# ---------- VIEWS ---------- 
from api.views import *


# from .views import ItemViewSet, ollama_message, openai_message

router = DefaultRouter()
# r'URL'            | api/url/
# views             | класс ViewSet
# basename='user'   | базовое имя для URL-имён
router.register(r'users', UserViewSet, basename='user')

urlpatterns = [
    path('auth/', include('djoser.urls')),           # регистрация, изменение пароля и т.п.
    path('auth/', include('djoser.urls.jwt')),       # JWT токены (если используешь simplejwt)
    path('chat/ollama/', ollama_generate_cv, name='ollama_generate_cv'),
    # path('projects/<int:project_id>/like/', toggle_like),
    # path('users/<int:pk>/', UserDetailAPIView.as_view(), name='user-detail'),
    # path('chat/openai/', openai_message, name='openai_message'),
]

urlpatterns += router.urls

#  Регистрация пользователя         |   api/auth/users/
#  Получение JWT (логин)            |   api/auth/jwt/create/
#  Обновление JWT токена            |   api/auth/jwt/refresh/
#  Получить данные текущего юзера   |   api/auth/users/me/

