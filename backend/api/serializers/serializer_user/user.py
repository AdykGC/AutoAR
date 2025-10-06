from rest_framework import serializers

# ---------- MODEL ---------- 
from api.models import *

# ---------- SERIALIZER ---------- 
from api.serializers.serializer_user.user_project import User_Project_Serializer



# ---------- METHOD ---------- 
class User_Serializer(serializers.ModelSerializer):
    projects = User_Project_Serializer(many=True, read_only=True)
    class Meta:
        model = User
        fields = ('id', 'email', 'nickname', 'user_name', 'user_surname', 'projects', 'cv')