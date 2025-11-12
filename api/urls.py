# api/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views  # Tudo em views.py

router = DefaultRouter()
router.register(r'usuarios', views.UsuarioViewSet, basename='usuario')

urlpatterns = [
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('', include(router.urls)),
]