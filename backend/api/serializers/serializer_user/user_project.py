from rest_framework import serializers

# ---------- MODEL ---------- 
from api.models import User, User_Info, User_Stats, User_Project

# ---------- SERIALIZER ---------- 
from api.serializers.serializer_user import *



# ---------- METHOD ---------- 
class User_Project_Serializer(serializers.ModelSerializer):
    likes_count = serializers.SerializerMethodField() # количество пользователей, которые лайкнули
    liked_by_ids = serializers.SerializerMethodField() # список id пользователей, которые лайкнули
    class Meta:
        model = User_Project
        fields = ('id', 'title', 'description', 'views', 'likes_count', 'liked_by_ids')
    
    def get_likes_count(self, obj):
        return obj.likes_count  # у тебя уже есть property
    
    def get_liked_by_ids(self, obj):
        return list(obj.liked_by.values_list('id', flat=True))