from django.db import models

# Create your models here.\
class User(models.Model):
    account = models.CharField(max_length=70, unique=True)
    email = models.CharField(max_length=128)
    password = models.CharField(max_length=128)  # Здесь хэш пароля можно хранить

    def __str__(self):
        return self.account


class User_Info(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='info')  # связь с User
    user_name = models.CharField(max_length=40)
    user_surname = models.CharField(max_length=40)
    description = models.CharField(max_length=200)

    def __str__(self):
        return f"{self.user_name} {self.user_surname}"


class User_Stats(models.Model):
    user_info = models.OneToOneField(User_Info, on_delete=models.CASCADE, related_name='stats')  # связь с User_Info
    likes = models.IntegerField(default=0)
    views = models.IntegerField(default=0)
    following = models.IntegerField(default=0)
    followers = models.IntegerField(default=0)

    def __str__(self):
        return f"Stats for {self.user_info}"


class User_Project(models.Model):
    user_info = models.ForeignKey(User_Info, on_delete=models.CASCADE, related_name='projects')  # связь с User_Info
    title = models.CharField(max_length=40)
    description = models.CharField(max_length=200)
    likes = models.IntegerField(default=0)
    views = models.IntegerField(default=0)

    # Пользователи, поставившие лайк
    liked_by = models.ManyToManyField('User', related_name='liked_projects', blank=True)

    def __str__(self):
        return f"Project '{self.title}' by {self.user_info}"

    @property
    def likes_count(self):
        return self.liked_by.count()