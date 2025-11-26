from rest_framework import viewsets, status, permissions
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth import login, logout
from django.contrib.auth.models import User
from django.contrib.auth.hashers import check_password
from django.db.models import Q
from django.views.decorators.csrf import csrf_exempt

from core.utils import call_procedure
from core import models
from api.serializers import UsuariosSerializer
from django.contrib.auth import get_user_model

User = get_user_model() 


# ==================== 1. LOGIN (PÚBLICO) ====================
@api_view(['POST'])
@permission_classes([AllowAny])
@csrf_exempt
def login_view(request):
    identifier = request.data.get('identifier')
    password = request.data.get('password')

    if not identifier or not password:
        return Response({"error": "Preencha CPF/e-mail e senha"}, status=400)

    try:
        usuario = models.Usuario.objects.select_related('id_perfil').get(
            Q(CPF_usuario=identifier) | Q(email_usuario=identifier)
        )
        if check_password(password, usuario.senha_usuario):
            user, _ = User.objects.get_or_create(username=usuario.CPF_usuario)
            login(request, user)
            return Response({
                "success": True,
                "message": "Login OK",
                "usuario": UsuariosSerializer(usuario).data
            })
    except models.Usuario.DoesNotExist:
        pass

    return Response({"error": "Credenciais inválidas"}, status=401)


# ==================== 2. LOGOUT ====================
@api_view(['POST'])
@permission_classes([AllowAny])
@csrf_exempt
def logout_view(request):
    logout(request)
    return Response({"success": True, "message": "Logout OK"})

@api_view(['GET'])
@permission_classes([AllowAny])
def check_auth(request):
    if not request.user.is_authenticated:
        return Response({"isLoggedIn": False})

    # O request.user é um auth.User, mas você salvou o CPF como username
    cpf = request.user.username  # ← você usou CPF como username!

    try:
        usuario = models.Usuario.objects.get(CPF_usuario=cpf)
        return Response({
            "isLoggedIn": True,
            "usuario": UsuariosSerializer(usuario).data
        })
    except models.Usuario.DoesNotExist:
        return Response({"isLoggedIn": False})

# ==================== 3. USUÁRIO VIEWSET (PROTEGIDO) ====================
class IsAdminUser(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_staff

class UsuarioViewSet(viewsets.ModelViewSet):
    queryset = models.Usuario.objects.select_related('id_perfil').all()
    serializer_class = UsuariosSerializer
    permission_classes = [permissions.IsAuthenticated]

    # Apenas admin pode criar, atualizar, deletar
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAdminUser()]
        return super().get_permissions()

    # Opcional: deletar com procedure
    def perform_destroy(self, instance):
        call_procedure('delete_usuario', [instance.id_usuario])