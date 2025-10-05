from django.db import models

# ---------- MODEL ---------- 
from api.models.model_user.user import User

# ---------- SERIALIZER ---------- 




# ---------- METHOD ---------- 
class User_Project(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='projects')
    project_title = models.CharField(max_length=40)
    project_description = models.CharField(max_length=200)
    views = models.IntegerField(default=0)

    # Пользователи, поставившие лайк
    liked_by = models.ManyToManyField(User, related_name='liked_projects', blank=True)

    def __str__(self):
        return f"Project '{self.project_title}' by {self.user.nickname}"

    @property
    def likes_count(self):
        return self.liked_by.count()