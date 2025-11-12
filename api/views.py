from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth.models import User
from django.contrib.auth import login
from django.contrib.auth.hashers import make_password, check_password
from django.db.models import Q
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view, permission_classes

from core.utils import call_procedure
from core import models
from api.serializers import UsuariosSerializer


# ==================== LOGIN ====================
@api_view(['POST'])
@csrf_exempt
def login_view(request):
    identifier = request.data.get('identifier')
    password = request.data.get('password')

    if not identifier or not password:
        return Response({"success": False, "message": "Dados obrigatórios"}, status=400)

    try:
        usuario = models.Usuario.objects.get(
            Q(CPF_usuario=identifier) | Q(email_usuario=identifier)
        )
        if check_password(password, usuario.senha_usuario):
            user, _ = User.objects.get_or_create(username=usuario.CPF_usuario)
            login(request, user)
            return Response({
                "success": True,
                "message": "Logado!",
                "usuario": UsuariosSerializer(usuario).data
            })
    except models.Usuario.DoesNotExist:
        pass

    return Response({"success": False, "message": "Credenciais inválidas"}, status=401)


# ==================== LOGOUT ====================
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@csrf_exempt
def logout_view(request):
    from django.contrib.auth import logout
    logout(request)
    return Response({"success": True, "message": "Logout realizado com sucesso!"})


# ==================== USUÁRIO VIEWSET (público) ====================
class UsuarioViewSet(viewsets.ViewSet):
    permission_classes = [AllowAny]  # ← PÚBLICO

    def list(self, request):
        usuarios = models.Usuario.objects.select_related('id_perfil').all()
        serializer = UsuariosSerializer(usuarios, many=True)
        return Response(serializer.data)

    def retrieve(self, request, pk=None):
        try:
            usuario = models.Usuario.objects.select_related('id_perfil').get(id_usuario=pk)
            return Response(UsuariosSerializer(usuario).data)
        except models.Usuario.DoesNotExist:
            return Response({"error": "Não encontrado"}, status=404)