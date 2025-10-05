from django.db import models

# ---------- MODEL ---------- 
from api.models.model_user.user import User

# ---------- SERIALIZER ---------- 




# ---------- METHOD ---------- 
class User_CV(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='cv')
    cv_title = models.CharField(max_length=60)
    data = models.JSONField(default=dict) # Само резюме в гибком виде
    generated_by_ai = models.BooleanField(default=False)

