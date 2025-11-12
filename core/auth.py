# core/auth.py
from django.db.models import Q
from django.contrib.auth.models import User
from django.contrib.auth.backends import ModelBackend
from django.contrib.auth.hashers import check_password
from . import models

class CPFEmailBackend(ModelBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        if not username or not password:
            return None

        try:
            usuario = models.Usuario.objects.get(
                Q(CPF_usuario=username) | Q(email_usuario=username)
            )
            if check_password(password, usuario.senha_usuario):
                user, _ = User.objects.get_or_create(
                    username=usuario.CPF_usuario,
                    defaults={'email': usuario.email_usuario}
                )
                return user
        except models.Usuario.DoesNotExist:
            pass
        return None