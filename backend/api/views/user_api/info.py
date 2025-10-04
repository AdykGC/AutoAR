# api/views/user_api_views/user_detail.py
from rest_framework import generics
from api.models import User
from api.serializers import *

class UserDetailAPIView(generics.RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = User_Serializer
    lookup_field = 'pk'  # по умолчанию
    # оптимизация запросов:
    def get_queryset(self):
        return User.objects.select_related('info', 'info__stats').prefetch_related('info__projects', 'info__projects__liked_by')

# select_related и prefetch_related уменьшают количество запросов при вложенных связях.