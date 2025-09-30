from django.shortcuts import render
from django.conf import settings
from rest_framework import viewsets
from .serializers import ItemSerializer

# MODELS.FROM MODELS.PY
from .models import Item
