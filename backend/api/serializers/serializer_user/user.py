from rest_framework import serializers

# ---------- MODEL ---------- 
from api.models import User, User_Info, User_Stats, User_Project

# ---------- SERIALIZER ---------- 
from api.serializers.serializer_user.user_info import User_Info_Serializer



# ---------- METHOD ---------- 
class User_Serializer(serializers.ModelSerializer):
    info = User_Info_Serializer(read_only=True)  # related_name='info' в OneToOneField

    class Meta:
        model = User
        fields = ('id', 'account', 'email', 'info')