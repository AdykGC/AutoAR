# backend/api/urls.py

from django.urls import path
from rest_framework.routers import DefaultRouter

# IMPORT VIEWS
from .views.user_api.like import toggle_like
# from api.views import toggle_like
# from .views import ItemViewSet, ollama_message, openai_message

router = DefaultRouter()
# router.register(r'items', ItemViewSet)

urlpatterns = [
    path('projects/<int:project_id>/like/', toggle_like),
    # path('chat/ollama/', ollama_message, name='ollama_message'),
    # path('chat/openai/', openai_message, name='openai_message'),
]

# Добавляем маршруты из роутера (ItemViewSet)
urlpatterns += router.urls




#    curl -X POST http://127.0.0.1:8000/api/projects/2/like/ \
#         -H "Content-Type: application/json" \
#         -d '{"user_id": 1}'