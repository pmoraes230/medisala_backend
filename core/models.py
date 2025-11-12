from django.db import models


class Insumos(models.Model):
    id_insumos = models.AutoField(primary_key=True)
    nome_insumo = models.CharField(max_length=80)
    especificacao_tec_insumo = models.CharField(max_length=1000)
    unidade_medida_insumo = models.CharField(max_length=3)
    quantidade_estoq_insumo = models.DecimalField(max_digits=10, decimal_places=3)
    validade_insumo = models.DateField()

    class Meta:
        managed = False
        db_table = 'insumos'


class Perfil(models.Model):
    id_perfil = models.AutoField(primary_key=True)
    nome_perfil = models.CharField(max_length=13)

    class Meta:
        managed = False
        db_table = 'perfil'


class Relatorio(models.Model):
    id_sala = models.IntegerField(db_column='id_sala')
    id_usuario = models.IntegerField(db_column='id_usuario')
    periodo_usado_relatorio = models.DateTimeField(db_column='periodo_usado_relatorio')
    nome_usuario = models.CharField(max_length=80, db_column='nome_usuario')
    reserva_insumo_id_insumos = models.IntegerField(db_column='Reserva_Insumo_id_insumos')
    reserva_insumo_id_reserva = models.IntegerField(db_column='Reserva_Insumo_id_reserva')

    class Meta:
        managed = False
        db_table = 'relatorio'
        # Chave primária composta (só para referência, Django ignora)
        unique_together = ('id_sala', 'id_usuario')


class Reserva(models.Model):
    id_reserva = models.AutoField(primary_key=True)
    data_reserva = models.DateField()
    hora_inicio_reserva = models.TimeField(unique=True)
    hora_termino_reserva = models.TimeField(unique=True)
    observacao_reserva = models.TextField(blank=True, null=True)
    id_usuario = models.ForeignKey('Usuario', models.DO_NOTHING, db_column='id_usuario')
    id_sala = models.ForeignKey('Sala', models.DO_NOTHING, db_column='id_sala')

    class Meta:
        managed = False
        db_table = 'reserva'


class ReservaInsumo(models.Model):
    pk = models.CompositePrimaryKey('id_insumos', 'id_reserva')
    id_insumos = models.ForeignKey(Insumos, models.DO_NOTHING, db_column='id_insumos')
    id_reserva = models.ForeignKey(Reserva, models.DO_NOTHING, db_column='id_reserva')
    quantidade_utilizada = models.DecimalField(max_digits=10, decimal_places=3)

    class Meta:
        managed = False
        db_table = 'reserva_insumo'


class Sala(models.Model):
    id_sala = models.AutoField(primary_key=True)
    nome_sala = models.CharField(max_length=80)
    status_sala = models.CharField(max_length=10)
    capacidade_sala = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'sala'


class Usuario(models.Model):
    id_usuario = models.AutoField(primary_key=True)
    nome_usuario = models.CharField(max_length=80)
    email_usuario = models.CharField(unique=True, max_length=80)
    CPF_usuario = models.CharField(db_column='CPF_usuario', unique=True, max_length=11)  # Field name made lowercase.
    senha_usuario = models.CharField(unique=True, max_length=130)
    foto_usuario = models.CharField(max_length=80)
    data_cadastro = models.DateTimeField()
    id_perfil = models.ForeignKey(Perfil, models.DO_NOTHING, db_column='id_perfil')

    class Meta:
        managed = False
        db_table = 'usuario'
