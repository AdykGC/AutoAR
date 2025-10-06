from djoser.serializers import UserCreateSerializer as BaseUserCreateSerializer
from djoser.serializers import UserSerializer as BaseUserSerializer
from rest_framework import serializers
# ---------- MODEL ---------- 
from api.models import *

# ---------- SERIALIZER ---------- 



# ---------- METHOD ---------- 
class User_Create_Serializer(BaseUserCreateSerializer):
    class Meta(BaseUserCreateSerializer.Meta):
        model = User
        fields = ('id', 'email', 'password', 'nickname')
        extra_kwargs = {'password': {'write_only': True}}

class Current_User_Serializer(BaseUserSerializer):
    class Meta(BaseUserSerializer.Meta):
        model = User
        fields = ('id', 'email', 'nickname')
