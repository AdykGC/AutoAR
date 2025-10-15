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
    
class Company(models.Model):
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='owned_companies')
    name = models.CharField(max_length=100)
    description = models.CharField(max_length=255, blank=True, null=True)
    employees = models.ManyToManyField(User, related_name='companies', blank=True)

    def __str__(self):
        return f"Company '{self.name}' (owner: {self.owner.username})"

    @property
    def employees_count(self):
        return self.employees.count()