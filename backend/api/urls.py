from django.urls import path
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
    #path('projects/<int:project_id>/like/', toggle_like),
    # path('users/<int:pk>/', UserDetailAPIView.as_view(), name='user-detail'),
    # path('chat/ollama/', ollama_message, name='ollama_message'),
    # path('chat/openai/', openai_message, name='openai_message'),
]

urlpatterns += router.urls