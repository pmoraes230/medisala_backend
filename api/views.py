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
from .permissions import IsAuthenticatedSession, IsAdminSession

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
            request.session['usuario_id'] = usuario.id_usuario
            print(f"DEBUG login: Session after set: {request.session.items()}") 
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
    usuario_id = request.session.get('usuario_id')
    print(f"DEBUG check_auth: usuario_id = {usuario_id}, session keys = {list(request.session.keys())}")  # Adicione isso
    if not usuario_id:
        return Response({"isLoggedIn": False})
    try:
        usuario = models.Usuario.objects.select_related('id_perfil').get(id_usuario=usuario_id)
        return Response({
            "isLoggedIn": True,
            "usuario": UsuariosSerializer(usuario).data
        })
    except models.Usuario.DoesNotExist:
        return Response({"isLoggedIn": False})

# ==================== 3. USUÁRIO VIEWSET (PROTEGIDO) ====================
class UsuarioViewSet(viewsets.ModelViewSet):
    queryset = models.Usuario.objects.select_related('id_perfil').all()
    serializer_class = UsuariosSerializer
    
    permission_classes = [IsAuthenticatedSession]

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAdminSession()]
        return [IsAuthenticatedSession()]