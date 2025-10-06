from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import gettext_lazy as _
# ---------- MODEL ---------- 
from api.models import *

# ---------- SERIALIZER ---------- 




# ---------- METHOD ---------- 
@admin.register(User)
class User_Admin(BaseUserAdmin):
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        (_('Personal info'), {'fields': ('nickname', 'user_name', 'user_surname')}),
        (_('Permissions'), {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        (_('Important dates'), {'fields': ('last_login', 'date_joined')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'nickname', 'password1', 'password2'),
        }),
    )
    list_display = ('email', 'nickname', 'is_staff', 'is_superuser')
    search_fields = ('email', 'nickname')
    ordering = ('email',)
    filter_horizontal = ('groups', 'user_permissions')

class User_Project_Admin(admin.ModelAdmin):
    list_display = [field.name for field in User_Project._meta.fields]
admin.site.register(User_Project, User_Project_Admin)

class User_CV_Admin(admin.ModelAdmin):
    list_display = ('user', 'cv_title', 'generated_by_ai')
    search_fields = ('cv_title',)
    list_filter = ('generated_by_ai',)
admin.site.register(User_CV, User_CV_Admin)
