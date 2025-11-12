# api/serializers.py
from rest_framework import serializers
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
            'id_usuario',
            'nome_usuario',
            'email_usuario',
            'CPF_usuario',
            'foto_usuario',
            'data_cadastro',
            'id_perfil',
            'nome_perfil',
            'senha_usuario',
        ]
        read_only_fields = ['id_usuario', 'data_cadastro', 'nome_perfil']

    # === Validações mínimas (só formato) ===
    def validate_CPF_usuario(self, value):
        if not re.match(r'^\d{11}$', value):
            raise serializers.ValidationError("CPF deve conter 11 dígitos numéricos.")
        return value

    def validate_email_usuario(self, value):
        if '@' not in value or '.' not in value:
            raise serializers.ValidationError("E-mail inválido.")
        return value

    # === CREATE: usa insert_usuario ===
    def create(self, validated_data):
        senha = validated_data.pop('senha_usuario')
        senha_hash = make_password(senha)  # bcrypt

        try:
            call_procedure('insert_usuario', [
                validated_data['nome_usuario'],
                validated_data['email_usuario'],
                validated_data['CPF_usuario'],
                senha_hash,  # já hasheada
                validated_data.get('foto_usuario', 'default.jpg'),
                validated_data.get('data_cadastro'),  # ou now()
                validated_data['id_perfil'].id_perfil,
            ])
            # Retorna o objeto criado
            return models.Usuario.objects.get(
                CPF_usuario=validated_data['CPF_usuario']
            )
        except Exception as e:
            raise serializers.ValidationError(f"Erro ao criar usuário: {str(e)}")

    # === UPDATE: usa update_usuario ===
    def update(self, instance, validated_data):
        senha = validated_data.pop('senha_usuario', None)
        senha_hash = make_password(senha) if senha else None

        try:
            params = [
                instance.id_usuario,
                validated_data.get('nome_usuario', instance.nome_usuario),
                validated_data.get('email_usuario', instance.email_usuario),
                validated_data.get('CPF_usuario', instance.CPF_usuario),
                senha_hash or instance.senha_usuario,  # mantém antiga se não vier
                validated_data.get('id_perfil', instance.id_perfil).id_perfil,
            ]
            call_procedure('update_usuario', params)

            # Recarrega o objeto atualizado
            return models.Usuario.objects.get(id_usuario=instance.id_usuario)
        except Exception as e:
            raise serializers.ValidationError(f"Erro ao atualizar: {str(e)}")