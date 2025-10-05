from django.db import models

# ---------- MODEL ---------- 


# ---------- SERIALIZER ---------- 




# ---------- METHOD ---------- 
class User(models.Model):
    email = models.EmailField(max_length=128, unique=True)
    nickname = models.CharField(max_length=30, unique=True)
    password = models.CharField(max_length=128)
    # Инфо поля
    user_name = models.CharField(max_length=40)
    user_surname = models.CharField(max_length=40)

    def __str__(self):
        return self.nickname