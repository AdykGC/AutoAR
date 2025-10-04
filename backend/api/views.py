from django.shortcuts import render
from django.conf import settings
from rest_framework import viewsets

# API FROM SERIALIZER
#from .serializers import ItemSerializer

# MODELS FROM MODELS.PY
# from .models import Item


from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import User_Project, User

#    @api_view(['POST'])
#    def toggle_like(request, project_id):
#        user_id = request.data.get('user_id')  # передаётся из фронта
#        try:
#            user = User.objects.get(id=user_id)
#            project = User_Project.objects.get(id=project_id)
#        except (User.DoesNotExist, User_Project.DoesNotExist):
#            return Response({'error': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
#    
#        if user in project.liked_by.all():
#            project.liked_by.remove(user)
#            return Response({'message': 'Unliked', 'likes': project.likes_count})
#        else:
#            project.liked_by.add(user)
#            return Response({'message': 'Liked', 'likes': project.likes_count})

