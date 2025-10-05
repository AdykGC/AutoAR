from django.contrib import admin

# ---------- MODEL ---------- 
from api.models import *

# ---------- SERIALIZER ---------- 




# ---------- METHOD ---------- 
class User_Admin(admin.ModelAdmin):
    list_display = [field.name for field in User._meta.fields]
admin.site.register(User, User_Admin)

class User_Project_Admin(admin.ModelAdmin):
    list_display = [field.name for field in User_Project._meta.fields]
admin.site.register(User_Project, User_Project_Admin)
