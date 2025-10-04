from rest_framework import serializers
from django.db.models import Count, Sum

# ---------- MODEL ---------- 
from api.models import User, User_Info, User_Stats, User_Project

# ---------- SERIALIZER ---------- 
from api.serializers.serializer_user import *



# ---------- METHOD ---------- 
class User_Stats_Serializer(serializers.ModelSerializer):
    total_likes = serializers.SerializerMethodField()

    class Meta:
        model = User_Stats
        fields = ('id', 'likes', 'views', 'following', 'followers', 'total_likes')

    def get_total_likes(self, obj):
        projects = obj.user_info.projects.annotate(num_likes=Count('liked_by'))
        return sum(project.num_likes for project in projects)