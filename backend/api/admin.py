from django.contrib import admin

# Register your models here.
from .models import User, User_Info, User_Stats, User_Project


class User_Admin(admin.ModelAdmin):
    list_display = ('account', 'email', 'password')

class User_Info_Admin(admin.ModelAdmin):
    list_display = ('user', 'user_name', 'user_surname', 'description')

class User_Stats_Admin(admin.ModelAdmin):
    list_display = ('user_info', 'likes', 'views', 'following', 'followers')

class User_Project_Admin(admin.ModelAdmin):
    list_display = ('user_info', 'title', 'description', 'views', 'likes')


admin.site.register(User, User_Admin)
admin.site.register(User_Info, User_Info_Admin)
admin.site.register(User_Stats, User_Stats_Admin)
admin.site.register(User_Project, User_Project_Admin)
