from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from api.models import User, User_Project

@api_view(['POST'])
def toggle_like(request, project_id):
    try:
        project = User_Project.objects.get(pk=project_id)
        user_id = request.data.get('user_id')

        if not user_id:
            return Response({"error": "user_id is required"}, status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.get(pk=user_id)

        if user in project.liked_by.all():
            project.liked_by.remove(user)
            message = "Unliked"
        else:
            project.liked_by.add(user)
            message = "Liked"

        return Response({
            "message": message,
            "likes": project.likes_count
        }, status=status.HTTP_200_OK)

    except User_Project.DoesNotExist:
        return Response({"error": "Project not found"}, status=status.HTTP_404_NOT_FOUND)
    except User.DoesNotExist:
        return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)
