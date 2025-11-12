from rest_framework import serializers
from rest_framework.decorators import action, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from core import models
from core.utils import call_procedure
from django.contrib.auth.hashers import make_password
import re

class UsuariosSerializer(serializers.ModelSerializer):
    nome_perfil = serializers.CharField(source='id_perfil.nome_perfil', read_only=True)
    senha_usuario = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = models.Usuario
        fields = [
            'id_usuario', 'nome_usuario', 'email_usuario', 'CPF_usuario',
            'foto_usuario', 'data_cadastro', 'id_perfil', 'nome_perfil', 'senha_usuario'
        ]
        read_only_fields = ['id_usuario', 'data_cadastro', 'nome_perfil']

    def validate_CPF_usuario(self, value):
        if not re.match(r'^\d{11}$', value):
            raise serializers.ValidationError("CPF deve conter 11 dígitos.")
        return value

    def validate_email_usuario(self, value):
        if '@' not in value or '.' not in value:
            raise serializers.ValidationError("E-mail inválido.")
        return value

    def create(self, validated_data):
        senha = validated_data.pop('senha_usuario')
        senha_hash = make_password(senha)

        call_procedure('insert_usuario', [
            validated_data['nome_usuario'],
            validated_data['email_usuario'],
            validated_data['CPF_usuario'],
            senha_hash,
            validated_data.get('foto_usuario', 'default.jpg'),
            validated_data.get('data_cadastro'),
            validated_data['id_perfil'].id_perfil,
        ])
        return models.Usuario.objects.get(CPF_usuario=validated_data['CPF_usuario'])

    def update(self, instance, validated_data):
        senha = validated_data.pop('senha_usuario', None)
        senha_hash = make_password(senha) if senha else None

        params = [
            instance.id_usuario,
            validated_data.get('nome_usuario', instance.nome_usuario),
            validated_data.get('email_usuario', instance.email_usuario),
            validated_data.get('CPF_usuario', instance.CPF_usuario),
            senha_hash or instance.senha_usuario,
            validated_data.get('id_perfil', instance.id_perfil).id_perfil,
        ]
        call_procedure('update_usuario', params)
        return models.Usuario.objects.get(id_usuario=instance.id_usuario)
        
class SalaSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Sala
        fields = ['id_sala', 'nome_sala', 'status_sala', 'capacidade_sala']
        read_only_fields = ['id_sala']
        try:    
            def create(self, validated_data):
                params = [
                    validated_data['nome_sala'],
                    validated_data['status_sala'],
                    validated_data['capacidade_sala']
                ]
                call_procedure('insert_sala', params)
                return models.Sala.objects.get(nome_sala=validated_data['nome_sala'])
        except Exception as e:
            raise serializers.ValidationError(f"Erro ao criar sala: {str(e)}")
        
        try:
            def update(self, instance, validated_data):
                params = [
                    instance.id_sala,
                    validated_data.get('nome_sala', instance.nome_sala),
                    validated_data.get('status_sala', instance.status_sala),
                    validated_data.get('capacidade_sala', instance.capacidade_sala)
                ]
                call_procedure('update_sala', params)
                return models.Sala.objects.get(id_sala=instance.id_sala)
        except Exception as e:
            raise serializers.SerializerValidationError(f"Erro ao atualizar sala: {str(e)}")
        
        try:
            @action(detail=False, methods=['post'], permission_classes=[IsAuthenticated])
            def status_sala(self, request):
                params = [request.id_sala]
                call_procedure('desativar_sala', params)
                return models.Sala.objects.get(id_sala=request.id_sala)
        except Exception as e:
            raise serializers.ValidationError(f"Erro ao alterar status da sala: {str(e)}")