from rest_framework import serializers

# ---------- MODEL ---------- 
from api.models import User, User_Info, User_Stats, User_Project

# ---------- SERIALIZER ---------- 
from api.serializers.serializer_user.user_project import User_Project_Serializer
from api.serializers.serializer_user.user_stats import User_Stats_Serializer



# ---------- METHOD ---------- 
class User_Info_Serializer(serializers.ModelSerializer):
    stats = User_Stats_Serializer(read_only=True)
    projects = User_Project_Serializer(many=True, read_only=True)  # related_name='projects' в FK
    
    class Meta:
        model = User_Info
        fields = ('id', 'user_name', 'user_surname', 'description', 'stats', 'projects')