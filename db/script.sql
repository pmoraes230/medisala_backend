-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mediSala
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mediSala
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mediSala` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_mysql500_ci ;
USE `mediSala` ;

-- -----------------------------------------------------
-- Table `mediSala`.`Perfil`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mediSala`.`Perfil` (
  `id_perfil` INT NOT NULL AUTO_INCREMENT,
  `nome_perfil` ENUM("Administrador", "Instrutor") NOT NULL,
  PRIMARY KEY (`id_perfil`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mediSala`.`Usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mediSala`.`Usuario` (
  `id_usuario` INT NOT NULL AUTO_INCREMENT,
  `nome_usuario` VARCHAR(80) NOT NULL,
  `email_usuario` VARCHAR(80) NOT NULL,
  `CPF_usuario` CHAR(11) NOT NULL,
  `senha_usuario` VARCHAR(130) NOT NULL,
  `foto_usuario` VARCHAR(80) NOT NULL,
  `data_cadastro` DATETIME NOT NULL,
  `id_perfil` INT NOT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE INDEX `senha_usuario_UNIQUE` (`senha_usuario` ASC) VISIBLE,
  UNIQUE INDEX `email_usuario_UNIQUE` (`email_usuario` ASC) VISIBLE,
  INDEX `fk_Usuario_Perfil_idx` (`id_perfil` ASC) VISIBLE,
  UNIQUE INDEX `CPF_usuario_UNIQUE` (`CPF_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_Usuario_Perfil`
    FOREIGN KEY (`id_perfil`)
    REFERENCES `mediSala`.`Perfil` (`id_perfil`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mediSala`.`Sala`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mediSala`.`Sala` (
  `id_sala` INT NOT NULL AUTO_INCREMENT,
  `nome_sala` VARCHAR(80) NOT NULL,
  `status_sala` ENUM("Livre", "Reservado", "Manutenção") NOT NULL DEFAULT 'Livre',
  `capacidade_sala` TINYINT NOT NULL,
  PRIMARY KEY (`id_sala`))
ENGINE = InnoDB;

ALTER TABLE `mediSala`.`Sala`
    MODIFY COLUMN `status_sala` ENUM('Livre','Reservado','Manutenção','Desativado')
    NOT NULL DEFAULT 'Livre';

-- -----------------------------------------------------
-- Table `mediSala`.`Reserva`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mediSala`.`Reserva` (
  `id_reserva` INT NOT NULL AUTO_INCREMENT,
  `data_reserva` DATE NOT NULL,
  `hora_inicio_reserva` TIME NOT NULL,
  `hora_termino_reserva` TIME NOT NULL,
  `observacao_reserva` TEXT(580) NULL,
  `id_usuario` INT NOT NULL,
  `id_sala` INT NOT NULL,
  PRIMARY KEY (`id_reserva`),
  UNIQUE INDEX `hora_inicio_reserva_UNIQUE` (`hora_inicio_reserva` ASC) VISIBLE,
  UNIQUE INDEX `hora_termino_reserva_UNIQUE` (`hora_termino_reserva` ASC) VISIBLE,
  INDEX `fk_Reserva_Usuario1_idx` (`id_usuario` ASC) VISIBLE,
  INDEX `fk_Reserva_Sala1_idx` (`id_sala` ASC) VISIBLE,
  CONSTRAINT `fk_Reserva_Usuario1`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `mediSala`.`Usuario` (`id_usuario`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Reserva_Sala1`
    FOREIGN KEY (`id_sala`)
    REFERENCES `mediSala`.`Sala` (`id_sala`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mediSala`.`insumos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mediSala`.`insumos` (
  `id_insumos` INT NOT NULL AUTO_INCREMENT,
  `nome_insumo` VARCHAR(80) NOT NULL,
  `especificacao_tec_insumo` VARCHAR(1000) NOT NULL,
  `unidade_medida_insumo` CHAR(3) NOT NULL,
  `quantidade_estoq_insumo` DECIMAL(10,3) NOT NULL,
  `validade_insumo` DATE NOT NULL,
  PRIMARY KEY (`id_insumos`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mediSala`.`Reserva_Insumo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mediSala`.`Reserva_Insumo` (
  `id_insumos` INT NOT NULL,
  `id_reserva` INT NOT NULL,
  `quantidade_utilizada` DECIMAL(10,3) NOT NULL,
  PRIMARY KEY (`id_insumos`, `id_reserva`),
  INDEX `fk_insumos_has_Reserva_Reserva1_idx` (`id_reserva` ASC) VISIBLE,
  INDEX `fk_insumos_has_Reserva_insumos1_idx` (`id_insumos` ASC) VISIBLE,
  CONSTRAINT `fk_insumos_has_Reserva_insumos1`
    FOREIGN KEY (`id_insumos`)
    REFERENCES `mediSala`.`insumos` (`id_insumos`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_insumos_has_Reserva_Reserva1`
    FOREIGN KEY (`id_reserva`)
    REFERENCES `mediSala`.`Reserva` (`id_reserva`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mediSala`.`relatorio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mediSala`.`relatorio` (
  `id_sala` INT NOT NULL,
  `id_usuario` INT NOT NULL,
  `periodo_usado_relatorio` DATETIME NOT NULL,
  `nome_usuario` VARCHAR(80) NOT NULL,
  `Reserva_Insumo_id_insumos` INT NOT NULL,
  `Reserva_Insumo_id_reserva` INT NOT NULL,
  PRIMARY KEY (`id_sala`, `id_usuario`),
  INDEX `fk_Sala_has_Usuario_Usuario1_idx` (`id_usuario` ASC) VISIBLE,
  INDEX `fk_Sala_has_Usuario_Sala1_idx` (`id_sala` ASC) VISIBLE,
  INDEX `fk_relatorio_Reserva_Insumo1_idx` (`Reserva_Insumo_id_insumos` ASC, `Reserva_Insumo_id_reserva` ASC) VISIBLE,
  CONSTRAINT `fk_Sala_has_Usuario_Sala1`
    FOREIGN KEY (`id_sala`)
    REFERENCES `mediSala`.`Sala` (`id_sala`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Sala_has_Usuario_Usuario1`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `mediSala`.`Usuario` (`id_usuario`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_relatorio_Reserva_Insumo1`
    FOREIGN KEY (`Reserva_Insumo_id_insumos` , `Reserva_Insumo_id_reserva`)
    REFERENCES `mediSala`.`Reserva_Insumo` (`id_insumos` , `id_reserva`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

USE `mediSala` ;

-- -----------------------------------------------------
-- Placeholder table for view `mediSala`.`vw_usuarios`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mediSala`.`vw_usuarios` (`id_usuario` INT, `nome_usuario` INT, `email_usuario` INT, `CPF_usuario` INT, `id_perfil` INT, `nome_perfil` INT);

-- -----------------------------------------------------
-- Placeholder table for view `mediSala`.`vw_salas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mediSala`.`vw_salas` (`id_sala` INT, `nome_sala` INT, `capacidade_sala` INT);

-- -----------------------------------------------------
-- Placeholder table for view `mediSala`.`vw_insumos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mediSala`.`vw_insumos` (`id_insumos` INT, `nome_insumo` INT, `especificacao_tec_insumo` INT, `unidade_medida_insumo` INT, `quantidade_estoq_insumo` INT, `validade_insumo` INT, `status_validade` INT);

-- -----------------------------------------------------
-- Placeholder table for view `mediSala`.`vw_reservas_completas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mediSala`.`vw_reservas_completas` (`id_reserva` INT, `data_reserva` INT, `hora_inicio_reserva` INT, `hora_termino_reserva` INT, `observacao_reserva` INT, `id_usuario` INT, `nome_usuario` INT, `id_sala` INT, `nome_sala` INT, `capacidade_sala` INT, `id_insumos` INT, `nome_insumo` INT, `unidade_medida_insumo` INT, `quantidade_utilizada` INT);

-- -----------------------------------------------------
-- Placeholder table for view `mediSala`.`vw_relatorio_detalhado`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mediSala`.`vw_relatorio_detalhado` (`id_sala` INT, `nome_sala` INT, `id_usuario` INT, `nome_usuario` INT, `periodo_usado_relatorio` INT, `id_reserva` INT, `id_insumos` INT, `nome_insumo` INT, `unidade_medida_insumo` INT, `quantidade_utilizada` INT, `data_reserva` INT, `hora_inicio_reserva` INT, `hora_termino_reserva` INT, `observacao_reserva` INT);

-- -----------------------------------------------------
-- procedure insert_usuario
-- -----------------------------------------------------

DELIMITER $$

CREATE PROCEDURE insert_usuario(
	IN p_nome_usuario VARCHAR(80),
    IN p_email_usuario VARCHAR(80),
    IN p_cpf_usuario CHAR(11),
    IN p_senha_usuario VARCHAR(130),
    IN p_foto_usuario VARCHAR(80),
    IN p_data_cadastro DATETIME,
    IN p_id_perfil INT
)
BEGIN
	IF p_nome_usuario IS NULL OR TRIM(p_nome_usuario) = '' THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'O nome do usuário é obrigatório';
    END IF;
    
    IF p_email_usuario IS NULL OR TRIM(p_email_usuario) = '' THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'O Email do usuário é obrigatório';
    END IF;
    
    IF p_cpf_usuario IS NULL OR TRIM(p_cpf_usuario) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O CPF do usuário é obrigatório';
    END IF;
    
    IF p_cpf_usuario NOT REGEXP '^[0-9]{11}$' THEN
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'CPF deve conter exatamente 11 dígitos numéricos';
	END IF;

    IF p_senha_usuario IS NULL OR TRIM(p_senha_usuario) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A senha do usuário é obrigatória';
    END IF;
    
    IF p_data_cadastro IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A data de cadastro do usuário é obrigatória';
    END IF;

    IF p_id_perfil IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O ID do perfil é obrigatório';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM Perfil WHERE id_perfil = p_id_perfil) THEN
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Perfil informado não existe';
	END IF;
    
	IF EXISTS (SELECT 1 FROM Usuario WHERE email_usuario = p_email_usuario) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email já cadastrado no sistema';
	END IF;
	IF EXISTS (SELECT 1 FROM Usuario WHERE CPF_usuario = p_cpf_usuario) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'CPF já cadastrado no sistema';
	END IF;
	INSERT INTO Usuario(nome_usuario, email_usuario, CPF_usuario, senha_usuario, foto_usuario, data_cadastro, id_perfil) VALUES
	(p_nome_usuario, p_email_usuario, p_cpf_usuario, p_senha_usuario, p_foto_usuario, p_data_cadastro, p_id_perfil);
END $$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_reserva
-- -----------------------------------------------------

DELIMITER $$
USE `mediSala`$$
CREATE PROCEDURE insert_reserva(
    IN p_data_reserva DATE,
    IN p_hora_inicio_reserva TIME,
    IN p_hora_termino_reserva TIME,
    IN p_observacao_reserva VARCHAR(50),
    IN p_id_usuario INT,
    IN p_id_sala INT
)
BEGIN
    -- 1. Validações de campos obrigatórios
    IF p_data_reserva IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A data da reserva é obrigatória';
    END IF;
    IF p_hora_inicio_reserva IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A hora de início é obrigatória';
    END IF;
    IF p_hora_termino_reserva IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A hora de término é obrigatória';
    END IF;
    IF p_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O ID do usuário é obrigatório';
    END IF;
    IF p_id_sala IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O ID da sala é obrigatório';
    END IF;

    -- 2. Valida horário: início antes do término
    IF p_hora_inicio_reserva >= p_hora_termino_reserva THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A hora de início deve ser anterior à hora de término';
    END IF;

    -- 3. Valida se as chaves estrangeiras existem
    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuário não encontrado';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Sala WHERE id_sala = p_id_sala) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sala não encontrada';
    END IF;

    -- 4. Verifica conflito de horário na mesma sala
    IF EXISTS (
        SELECT 1 FROM Reserva
        WHERE id_sala = p_id_sala
          AND data_reserva = p_data_reserva
          AND (
              (p_hora_inicio_reserva < hora_termino_reserva AND p_hora_inicio_reserva >= hora_inicio_reserva)
              OR
              (p_hora_termino_reserva > hora_inicio_reserva AND p_hora_termino_reserva <= hora_termino_reserva)
              OR
              (p_hora_inicio_reserva <= hora_inicio_reserva AND p_hora_termino_reserva >= hora_termino_reserva)
          )
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Conflito de horário: esta sala já está reservada neste período';
    END IF;

    -- 5. Insere a reserva (sem id_insumos)
    INSERT INTO Reserva (
        data_reserva,
        hora_inicio_reserva,
        hora_termino_reserva,
        observacao_reserva,
        id_usuario,
        id_sala
    ) VALUES (
        p_data_reserva,
        p_hora_inicio_reserva,
        p_hora_termino_reserva,
        p_observacao_reserva,
        p_id_usuario,
        p_id_sala
    );

    -- Opcional: retornar o ID da reserva criada
    SELECT LAST_INSERT_ID() AS id_reserva_gerada;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_insumo
-- -----------------------------------------------------

DELIMITER $$
USE `mediSala`$$
CREATE PROCEDURE insert_insumo(
    IN p_nome_insumo VARCHAR(80),
    IN p_especificacao_tec_insumo VARCHAR(100),
    IN p_unidade_medida_insumo CHAR(3),
    IN p_quantidade_estoq_insumo DECIMAL(10,3),
    IN p_validade_insumo DATE
)
BEGIN
    -- 1. Validação: campos obrigatórios
    IF p_nome_insumo IS NULL OR TRIM(p_nome_insumo) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O nome do insumo é obrigatório';
    END IF;

    IF p_unidade_medida_insumo IS NULL OR TRIM(p_unidade_medida_insumo) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A unidade de medida é obrigatória';
    END IF;

    IF p_quantidade_estoq_insumo IS NULL OR p_quantidade_estoq_insumo < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A quantidade em estoque deve ser maior ou igual a zero';
    END IF;

    IF p_validade_insumo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A data de validade é obrigatória';
    END IF;

    IF p_validade_insumo < CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A data de validade não pode ser no passado';
    END IF;

    -- 2. Validação: unidade de medida comum (ex: KG, L, UN, ML, etc.) - opcional
    IF p_unidade_medida_insumo NOT REGEXP '^(UN|KG|L|ML|G|M|CM|PC)$' THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Unidade de medida inválida. Use: UN, KG, L, ML, G, M, CM, PC';
    END IF;

    -- 3. Opcional: Evitar duplicidade (nome + especificação + validade)
    IF EXISTS (
        SELECT 1 FROM insumos 
        WHERE nome_insumo = p_nome_insumo
          AND COALESCE(especificacao_tec_insumo, '') = COALESCE(p_especificacao_tec_insumo, '')
          AND validade_insumo = p_validade_insumo
    ) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Insumo já cadastrado com este nome, especificação e validade';
    END IF;

    -- 4. Inserir o insumo
    INSERT INTO insumos (
        nome_insumo,
        especificacao_tec_insumo,
        unidade_medida_insumo,
        quantidade_estoq_insumo,
        validade_insumo
    ) VALUES (
        TRIM(p_nome_insumo),
        NULLIF(TRIM(p_especificacao_tec_insumo), ''),  -- Converte string vazia em NULL
        UPPER(TRIM(p_unidade_medida_insumo)),
        p_quantidade_estoq_insumo,
        p_validade_insumo
    );

    -- Opcional: retornar o ID inserido
    SELECT LAST_INSERT_ID() AS novo_id_insumo;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_sala
-- -----------------------------------------------------

DELIMITER $$
USE `mediSala`$$
CREATE PROCEDURE insert_sala(
	IN p_nome_sala VARCHAR(80),
    IN p_capacidade_sala TINYINT
)
BEGIN 
	IF p_nome_sala IS NULL OR TRIM(p_nome_sala) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O nome da sala é obrigatório';
    END IF;
    IF p_capacidade_sala IS NULL OR TRIM(p_capacidade_sala) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'É obrigatório informar a capacidade da sala';
    END IF;
    INSERT INTO Sala(nome_sala, capacidade_sala) VALUES
    (p_nome_sala, p_capacidade_sala);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure update_usuario
-- -----------------------------------------------------

DELIMITER $$
USE `mediSala`$$
CREATE PROCEDURE update_usuario(
    IN p_id_usuario INT,
    IN p_nome_usuario VARCHAR(80),
    IN p_email_usuario VARCHAR(80),
    IN p_cpf_usuario CHAR(11),
    IN p_senha_usuario VARCHAR(130),
    IN p_id_perfil INT
)
BEGIN
    -- Validações
    IF p_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID do usuário é obrigatório';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuário não encontrado';
    END IF;

    IF p_nome_usuario IS NULL OR TRIM(p_nome_usuario) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O nome do usuário é obrigatório';
    END IF;

    IF p_email_usuario IS NULL OR TRIM(p_email_usuario) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O email do usuário é obrigatório';
    END IF;

    IF p_cpf_usuario IS NULL OR TRIM(p_cpf_usuario) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O CPF do usuário é obrigatório';
    END IF;

    IF p_senha_usuario IS NULL OR TRIM(p_senha_usuario) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A senha do usuário é obrigatória';
    END IF;

    IF p_id_perfil IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O ID do perfil é obrigatório';
    END IF;

    -- Valida duplicidade (exceto o próprio usuário)
    IF EXISTS (
        SELECT 1 FROM Usuario 
        WHERE email_usuario = p_email_usuario 
          AND id_usuario != p_id_usuario
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email já cadastrado por outro usuário';
    END IF;

    IF EXISTS (
        SELECT 1 FROM Usuario 
        WHERE CPF_usuario = p_cpf_usuario 
          AND id_usuario != p_id_usuario
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CPF já cadastrado por outro usuário';
    END IF;

    -- Atualiza
    UPDATE Usuario SET
        nome_usuario = TRIM(p_nome_usuario),
        email_usuario = TRIM(p_email_usuario),
        CPF_usuario = p_cpf_usuario,
        senha_usuario = p_senha_usuario,
        id_perfil = p_id_perfil
    WHERE id_usuario = p_id_usuario;

    SELECT p_id_usuario AS id_usuario_atualizado;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure update_reserva
-- -----------------------------------------------------

DELIMITER $$
USE `mediSala`$$
CREATE PROCEDURE update_reserva(
    IN p_id_reserva INT,
    IN p_data_reserva DATE,
    IN p_hora_inicio_reserva TIME,
    IN p_hora_termino_reserva TIME,
    IN p_observacao_reserva VARCHAR(50),
    IN p_id_usuario INT,
    IN p_id_sala INT
)
BEGIN
    IF p_id_reserva IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID da reserva é obrigatório';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Reserva WHERE id_reserva = p_id_reserva) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reserva não encontrada';
    END IF;

    IF p_data_reserva IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A data da reserva é obrigatória';
    END IF;

    IF p_hora_inicio_reserva IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A hora de início é obrigatória';
    END IF;

    IF p_hora_termino_reserva IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A hora de término é obrigatória';
    END IF;

    IF p_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O ID do usuário é obrigatório';
    END IF;

    IF p_id_sala IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O ID da sala é obrigatório';
    END IF;

    IF p_hora_inicio_reserva >= p_hora_termino_reserva THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A hora de início deve ser anterior à hora de término';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuário não encontrado';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Sala WHERE id_sala = p_id_sala) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sala não encontrada';
    END IF;

    -- Verifica conflito (exceto a própria reserva)
    IF EXISTS (
        SELECT 1 FROM Reserva
        WHERE id_sala = p_id_sala
          AND data_reserva = p_data_reserva
          AND id_reserva != p_id_reserva
          AND (
              (p_hora_inicio_reserva < hora_termino_reserva AND p_hora_inicio_reserva >= hora_inicio_reserva)
              OR (p_hora_termino_reserva > hora_inicio_reserva AND p_hora_termino_reserva <= hora_termino_reserva)
              OR (p_hora_inicio_reserva <= hora_inicio_reserva AND p_hora_termino_reserva >= hora_termino_reserva)
          )
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Conflito de horário com outra reserva';
    END IF;

    UPDATE Reserva SET
        data_reserva = p_data_reserva,
        hora_inicio_reserva = p_hora_inicio_reserva,
        hora_termino_reserva = p_hora_termino_reserva,
        observacao_reserva = p_observacao_reserva,
        id_usuario = p_id_usuario,
        id_sala = p_id_sala
    WHERE id_reserva = p_id_reserva;

    SELECT p_id_reserva AS id_reserva_atualizada;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure update_insumo
-- -----------------------------------------------------

DELIMITER $$
USE `mediSala`$$
CREATE PROCEDURE update_insumo(
    IN p_id_insumos INT,
    IN p_nome_insumo VARCHAR(80),
    IN p_especificacao_tec_insumo VARCHAR(100),
    IN p_unidade_medida_insumo CHAR(3),
    IN p_quantidade_estoq_insumo DECIMAL(10,3),
    IN p_validade_insumo DATE
)
BEGIN
    IF p_id_insumos IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID do insumo é obrigatório';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM insumos WHERE id_insumos = p_id_insumos) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insumo não encontrado';
    END IF;

    IF p_nome_insumo IS NULL OR TRIM(p_nome_insumo) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O nome do insumo é obrigatório';
    END IF;

    IF p_unidade_medida_insumo IS NULL OR TRIM(p_unidade_medida_insumo) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A unidade de medida é obrigatória';
    END IF;

    IF p_quantidade_estoq_insumo IS NULL OR p_quantidade_estoq_insumo < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A quantidade deve ser >= 0';
    END IF;

    IF p_validade_insumo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A data de validade é obrigatória';
    END IF;

    IF p_validade_insumo < CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A validade não pode ser no passado';
    END IF;

    IF p_unidade_medida_insumo NOT REGEXP '^(UN|KG|L|ML|G|M|CM|PC)$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unidade inválida. Use: UN, KG, L, ML, G, M, CM, PC';
    END IF;

    IF EXISTS (
        SELECT 1 FROM insumos
        WHERE nome_insumo = p_nome_insumo
          AND COALESCE(especificacao_tec_insumo, '') = COALESCE(p_especificacao_tec_insumo, '')
          AND validade_insumo = p_validade_insumo
          AND id_insumos != p_id_insumos
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insumo já existe com esses dados';
    END IF;

    UPDATE insumos SET
        nome_insumo = TRIM(p_nome_insumo),
        especificacao_tec_insumo = NULLIF(TRIM(p_especificacao_tec_insumo), ''),
        unidade_medida_insumo = UPPER(TRIM(p_unidade_medida_insumo)),
        quantidade_estoq_insumo = p_quantidade_estoq_insumo,
        validade_insumo = p_validade_insumo
    WHERE id_insumos = p_id_insumos;

    SELECT p_id_insumos AS id_insumo_atualizado;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure update_sala
-- -----------------------------------------------------

DELIMITER $$
USE `mediSala`$$
CREATE PROCEDURE update_sala(
    IN p_id_sala INT,
    IN p_nome_sala VARCHAR(80),
    IN p_capacidade_sala TINYINT
)
BEGIN
    IF p_id_sala IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID da sala é obrigatório';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Sala WHERE id_sala = p_id_sala) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sala não encontrada';
    END IF;

    IF p_nome_sala IS NULL OR TRIM(p_nome_sala) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O nome da sala é obrigatório';
    END IF;

    IF p_capacidade_sala IS NULL OR p_capacidade_sala <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Capacidade deve ser maior que zero';
    END IF;

    UPDATE Sala SET
        nome_sala = TRIM(p_nome_sala),
        capacidade_sala = p_capacidade_sala
    WHERE id_sala = p_id_sala;

    SELECT p_id_sala AS id_sala_atualizada;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure delete_usuario
-- -----------------------------------------------------

DELIMITER $$
USE `mediSala`$$
CREATE PROCEDURE delete_usuario(
    IN p_id_usuario INT
)
BEGIN
    IF p_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID do usuário é obrigatório';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuário não encontrado';
    END IF;

    -- Bloqueia se o usuário tiver reservas
    IF EXISTS (SELECT 1 FROM Reserva WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é possível excluir: usuário possui reservas ativas';
    END IF;

    DELETE FROM Usuario WHERE id_usuario = p_id_usuario;

    SELECT p_id_usuario AS id_usuario_excluido;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure delete_reserva
-- -----------------------------------------------------

DELIMITER $$
USE `mediSala`$$
CREATE PROCEDURE delete_reserva(
    IN p_id_reserva INT
)
BEGIN
    IF p_id_reserva IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID da reserva é obrigatório';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Reserva WHERE id_reserva = p_id_reserva) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reserva não encontrada';
    END IF;

    -- Apaga insumos associados (cascade ou manual)
    DELETE FROM Reserva_Insumo WHERE id_reserva = p_id_reserva;

    -- Apaga a reserva
    DELETE FROM Reserva WHERE id_reserva = p_id_reserva;

    SELECT p_id_reserva AS id_reserva_excluida;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure delete_insumo
-- -----------------------------------------------------

DELIMITER $$
USE `mediSala`$$
CREATE PROCEDURE delete_insumo(
    IN p_id_insumos INT
)
BEGIN
    IF p_id_insumos IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID do insumo é obrigatório';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM insumos WHERE id_insumos = p_id_insumos) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insumo não encontrado';
    END IF;

    -- Bloqueia se o insumo estiver em uso
    IF EXISTS (SELECT 1 FROM Reserva_Insumo WHERE id_insumos = p_id_insumos) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é possível excluir: insumo está sendo usado em reservas';
    END IF;

    DELETE FROM insumos WHERE id_insumos = p_id_insumos;

    SELECT p_id_insumos AS id_insumo_excluido;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure delete_sala
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS delete_sala;

DELIMITER $$

DROP PROCEDURE IF EXISTS `mediSala`.`desativar_sala`$$
CREATE PROCEDURE desativar_sala(
    IN p_id_sala INT
)
BEGIN
    /* -------------------------------------------------
       1. Validações
       ------------------------------------------------- */
    IF p_id_sala IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ID da sala é obrigatório';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Sala WHERE id_sala = p_id_sala) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sala não encontrada';
    END IF;

    IF EXISTS (SELECT 1 FROM Reserva WHERE id_sala = p_id_sala) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Não é possível desativar: sala possui reservas ativas';
    END IF;

    /* -------------------------------------------------
       2. Atualiza o status
       ------------------------------------------------- */
    UPDATE Sala
       SET status_sala = 'Desativado'
     WHERE id_sala = p_id_sala;

    /* -------------------------------------------------
       3. Retorno amigável
       ------------------------------------------------- */
    SELECT p_id_sala AS id_sala_desativada,
           'Desativado' AS novo_status;
END$$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `mediSala`.`reativar_sala`$$
CREATE PROCEDURE `mediSala`.`reativar_sala`(
    IN p_id_sala INT
)
BEGIN
    IF p_id_sala IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID da sala é obrigatório';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Sala WHERE id_sala = p_id_sala) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sala não encontrada';
    END IF;

    UPDATE Sala
       SET status_sala = 'Livre'
     WHERE id_sala = p_id_sala
       AND status_sala = 'Desativado';

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A sala já está ativa ou não estava desativada';
    END IF;

    SELECT p_id_sala AS id_sala_reativada, 'Livre' AS novo_status;
END$$

DELIMITER ;

CALL desativar_sala(1);
CALL reativar_sala(1);

-- -----------------------------------------------------
-- View `mediSala`.`vw_usuarios`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mediSala`.`vw_usuarios`;
USE `mediSala`;
CREATE  OR REPLACE VIEW vw_usuarios AS
SELECT 
    u.id_usuario,
    u.nome_usuario,
    u.email_usuario,
    u.CPF_usuario,
    u.id_perfil,
    p.nome_perfil
FROM Usuario u
JOIN Perfil p ON p.id_perfil = u.id_perfil
ORDER BY u.nome_usuario;

-- -----------------------------------------------------
-- View `mediSala`.`vw_salas`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mediSala`.`vw_salas`;
USE `mediSala`;
CREATE  OR REPLACE VIEW vw_salas AS
SELECT 
    s.id_sala,
    s.nome_sala,
    s.capacidade_sala
FROM Sala s
ORDER BY s.nome_sala;

-- -----------------------------------------------------
-- View `mediSala`.`vw_insumos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mediSala`.`vw_insumos`;
USE `mediSala`;
CREATE  OR REPLACE VIEW vw_insumos AS
SELECT 
	i.id_insumos,
    i.nome_insumo,
    i.especificacao_tec_insumo,
    i.unidade_medida_insumo,
    i.quantidade_estoq_insumo,
    i.validade_insumo,
    CASE
		WHEN i.validade_insumo < CURDATE() THEN 'Fora da validade'
        WHEN i.validade_insumo <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'Próximo do vencimento'
	END AS status_validade
FROM insumos i 
ORDER BY i.validade_insumo;

-- -----------------------------------------------------
-- View `mediSala`.`vw_reservas_completas`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mediSala`.`vw_reservas_completas`;
USE `mediSala`;
CREATE OR REPLACE VIEW vw_reservas_completas AS
SELECT 
    r.id_reserva,
    r.data_reserva,
    r.hora_inicio_reserva,
    r.hora_termino_reserva,
    r.observacao_reserva,
    r.id_usuario,
    u.nome_usuario,
    r.id_sala,
    s.nome_sala,
    s.capacidade_sala,
    ri.id_insumos,
    i.nome_insumo,
    i.unidade_medida_insumo,
    ri.quantidade_utilizada
FROM Reserva r
JOIN Usuario u ON u.id_usuario = r.id_usuario
JOIN Sala s ON s.id_sala = r.id_sala
LEFT JOIN Reserva_Insumo ri ON ri.id_reserva = r.id_reserva
LEFT JOIN insumos i ON i.id_insumos = ri.id_insumos
ORDER BY r.data_reserva DESC, r.hora_inicio_reserva;

-- -----------------------------------------------------
-- View `mediSala`.`vw_relatorio_detalhado`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mediSala`.`vw_relatorio_detalhado`;
USE `mediSala`;
CREATE OR REPLACE VIEW vw_relatorio_detalhado AS
SELECT 
    rel.id_sala,
    s.nome_sala,
    rel.id_usuario,
    rel.nome_usuario,
    rel.periodo_usado_relatorio,
    rel.Reserva_Insumo_id_reserva AS id_reserva,
    rel.Reserva_Insumo_id_insumos AS id_insumos,
    i.nome_insumo,
    i.unidade_medida_insumo,
    ri.quantidade_utilizada,
    r.data_reserva,
    r.hora_inicio_reserva,
    r.hora_termino_reserva,
    r.observacao_reserva
FROM relatorio rel
JOIN Reserva r ON r.id_reserva = rel.Reserva_Insumo_id_reserva
JOIN Sala s ON s.id_sala = rel.id_sala
JOIN insumos i ON i.id_insumos = rel.Reserva_Insumo_id_insumos
JOIN Reserva_Insumo ri ON ri.id_reserva = rel.Reserva_Insumo_id_reserva 
                       AND ri.id_insumos = rel.Reserva_Insumo_id_insumos
ORDER BY rel.periodo_usado_relatorio DESC;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
