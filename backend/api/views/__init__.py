from api.views.view_user.user_ViewSet import UserViewSet
from api.views.view_user.OLLAMA import ollama_generate_cv

__all__ = [
    "UserViewSet",
    "ollama_generate_cv",
]