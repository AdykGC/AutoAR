from rest_framework import viewsets
from rest_framework import generics
# ---------- MODEL ---------- 
from api.models import *

# ---------- SERIALIZER ---------- 
from api.serializers import *



# ---------- METHOD ---------- 
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = User_Serializer