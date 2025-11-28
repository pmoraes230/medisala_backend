from rest_framework.permissions import BasePermission
from core import models

class IsAuthenticatedSession(BasePermission):
    """
    Permite acesso apenas a usuários autenticados via sessão.
    """
    def has_permission(self, request, view):
        usuario_id = request.session.get('usuario_id')
        print(f"DEBUG IsAuthenticatedSession: usuario_id = {usuario_id}, session keys = {list(request.session.keys())}")  # Adicione isso
        if not usuario_id:
            print("Usuário não autenticado na sessão.")
            return False
        
        try:
            usuario = models.Usuario.objects.get(id_usuario=usuario_id)
            print(f"Auth {usuario.nome_usuario}")
            return True
        except models.Usuario.DoesNotExist:
            print("❌ Usuário não existe")
            return False
        
class IsAdminSession(BasePermission):
    """Só admin pode CRUD"""
    
    def has_permission(self, request, view):
        usuario_id = request.session.get('usuario_id')
        if not usuario_id:
            return False
            
        try:
            usuario = models.Usuario.objects.select_related('id_perfil').get(id_usuario=usuario_id)
            return usuario.id_perfil.nome_perfil == 'Administrador'
        except models.Usuario.DoesNotExist:
            return False