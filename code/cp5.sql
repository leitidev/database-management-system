-- INTEGRANTES
-- Leonardo Bruno de Sousa - RM552408
-- João Vito Santiago - RM
-- Marco Ant?nio de Araújo - RM550128
-- Vinicius Andrade Lopes - RM99343 
-- INTEGRANTES

set serveroutput on


-- DROPS
drop table T_cp_PARTICIPACAO cascade constraints;
drop table t_cp_evento cascade constraints;
drop table t_cp_admin cascade constraints;
drop table t_cp_participante cascade constraints;
drop table t_cp_usuario cascade constraints;
drop table t_cp_area cascade constraints;
drop table t_cp_log_errors cascade constraints;
drop table t_cp_auditoria cascade constraints;
-- DROPS

-- SEQUENCES
DROP SEQUENCE seq_participacao;
DROP SEQUENCE seq_evento;
DROP SEQUENCE seq_admin;
DROP SEQUENCE seq_participante;
DROP SEQUENCE seq_usuario;
DROP SEQUENCE seq_area;
DROP SEQUENCE seq_log_errors;
drop sequence seq_auditoria;


CREATE SEQUENCE seq_participacao
    start with 1
    increment by 1
    minvalue 1
    maxvalue 1000
    nocycle;
    
CREATE SEQUENCE seq_evento
    start with 1
    increment by 1
    minvalue 1
    maxvalue 1000
    nocycle;

CREATE SEQUENCE seq_admin
    start with 1
    increment by 1
    minvalue 1
    maxvalue 1000
    nocycle;
    
CREATE SEQUENCE seq_participante
    start with 1
    increment by 1
    minvalue 1
    maxvalue 1000
    nocycle;
    
CREATE SEQUENCE seq_usuario
    start with 1
    increment by 1
    minvalue 1
    maxvalue 1000
    nocycle;
    
CREATE SEQUENCE seq_area
    start with 1
    increment by 1
    minvalue 1
    maxvalue 1000
    nocycle;
    
CREATE SEQUENCE seq_log_errors
    start with 1
    increment by 1
    minvalue 1
    maxvalue 1000
    nocycle;
    
CREATE SEQUENCE seq_auditoria
    start with 1
    increment by 1
    minvalue 1
    maxvalue 1000
    nocycle;
-- SEQUENCES



-- TABLES
CREATE TABLE t_cp_area (
    id_area               CHAR(9) NOT NULL,
    nr_cep                VARCHAR2(255) NOT NULL unique,
    nm_cidade             VARCHAR2(20) NOT NULL,
    nm_estado             VARCHAR2(255) NOT NULL,
    ds_localizacao_banca  VARCHAR2(255) NOT NULL,
    nm_rua                VARCHAR2(255) NOT NULL,
    nr_latitude_x         VARCHAR2(255) NOT NULL,
    nr_latitude_y         VARCHAR2(255) NOT NULL,
    primary key (id_area)
);

CREATE TABLE t_cp_usuario (
    id_usuario  CHAR(9) NOT NULL,
    cd_usuario  VARCHAR2(30) NOT NULL unique,
    cd_senha    VARCHAR2(30) NOT NULL,
    st_funcao   CHAR(1) NOT NULL,
    primary key (id_usuario)
);

CREATE TABLE t_cp_participante (
    id_participante          CHAR(9) NOT NULL,
    nm_participante          VARCHAR2(255) NOT NULL,
    dt_nascimento            DATE NOT NULL,
    tp_sexo                  CHAR(1) NOT NULL,
    ds_email                 VARCHAR2(255) NOT NULL unique,
    id_usuario               CHAR(9) NOT NULL,
    primary key(id_participante),
    FOREIGN KEY(id_usuario) REFERENCES T_cp_USUARIO(id_usuario)
);

CREATE TABLE t_cp_admin (
    id_admin      CHAR(9) NOT NULL,
    nm_admin      VARCHAR2(255) NOT NULL,
    id_usuario    CHAR(9) NOT NULL,
    ds_email      VARCHAR2(255) NOT NULL unique,
    primary key(id_admin),
    FOREIGN KEY(id_usuario) REFERENCES T_cp_USUARIO(id_usuario)
);

CREATE TABLE t_cp_evento (
    id_evento                                  CHAR(9) NOT NULL unique,
    dt_evento_inicio                           DATE NOT NULL,
    id_area                                    CHAR(9) NOT NULL unique,
    st_evento                                  CHAR(1) NOT NULL,
    dt_evento_encerramento                     DATE NOT NULL, 
    id_admin                                   CHAR(9) NOT NULL,
    FOREIGN KEY(id_area) REFERENCES T_cp_AREA(id_area),
    FOREIGN KEY(id_admin) REFERENCES T_cp_ADMIN(id_admin),
    primary key(id_evento, id_admin, id_area)
);

CREATE TABLE t_cp_participacao (
    id_participacao   CHAR(9) NOT NULL,
    id_evento         CHAR(9) NOT NULL,
    id_participante   CHAR(9) NOT NULL,
    dt_participacao   DATE NOT NULL,
    FOREIGN KEY(id_participante) REFERENCES t_cp_participante(id_participante),
    FOREIGN KEY(id_evento) REFERENCES t_cp_evento(id_evento),
    PRIMARY KEY(id_participacao, id_participante, id_evento)
);

CREATE TABLE t_cp_log_errors (
    id_log         CHAR(9) NOT NULL,
    nm_procedure   VARCHAR2(255) NOT NULL,
    nm_usuario     VARCHAR2(255) NOT NULL,
    dt_ocorrencia  DATE NOT NULL,
    cd_erro        INTEGER NOT NULL,
    ds_erro        VARCHAR2(255) NOT NULL,
    primary key(id_log)
);

CREATE TABLE T_CP_AUDITORIA (
    ID_AUDITORIA NUMBER PRIMARY KEY,
    TABELA_AUDITADA VARCHAR2(50),
    OPERACAO VARCHAR2(10),
    USUARIO VARCHAR2(50),
    DATA_OPERACAO DATE,
    OLD_DATA VARCHAR2(250),
    NEW_DATA VARCHAR2(250)
);
-- TABLES


-- INSERTS
-- AREA
CREATE OR REPLACE PROCEDURE insert_t_cp_area (
    p_nr_cep                IN VARCHAR2,
    p_nm_cidade             IN VARCHAR2,
    p_nm_estado             IN VARCHAR2,
    p_ds_localizacao_banca  IN VARCHAR2,
    p_nm_rua                IN VARCHAR2,
    p_nr_latitude_x         IN VARCHAR2,
    p_nr_latitude_y         IN VARCHAR2,
    p_nm_usuario            IN VARCHAR2
) AS
    v_id_area CHAR(9);
    v_id_log CHAR(9);
    v_dt_ocorrencia DATE;
    v_cd_erro INTEGER;
    v_ds_erro VARCHAR2(255);
BEGIN
    v_id_area := seq_area.NEXTVAL;

    INSERT INTO t_cp_area (id_area, nr_cep, nm_cidade, nm_estado, ds_localizacao_banca, nm_rua, nr_latitude_x, nr_latitude_y)
    VALUES (v_id_area, p_nr_cep, p_nm_cidade, p_nm_estado, p_ds_localizacao_banca, p_nm_rua, p_nr_latitude_x, p_nr_latitude_y);

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;

        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_area', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro DUP_VAL_ON_INDEX capturado, cheque T_cp_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
    WHEN VALUE_ERROR THEN
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;

        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_area', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro VALUE_ERROR capturado, cheque T_cp_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
    WHEN OTHERS THEN
        -- Gera um novo ID para o log usando a 
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;

        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_area', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro OTHERS capturado, cheque T_cp_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
END;

CREATE OR REPLACE PROCEDURE todos_inserts_area AS
BEGIN
    insert_t_cp_area(
        p_nr_cep => '01310-200',
        p_nm_cidade => 'Sao Paulo',
        p_nm_estado => 'SP',
        p_ds_localizacao_banca => 'Proximo ao metro',
        p_nm_rua => 'Rua da Consolacao',
        p_nr_latitude_x => '-23.5505',
        p_nr_latitude_y => '-46.6333',
        p_nm_usuario => 'Usuario1'
    );
    
    insert_t_cp_area(
        p_nr_cep => '22010-000',
        p_nm_cidade => 'Rio de Janeiro',
        p_nm_estado => 'RJ',
        p_ds_localizacao_banca => 'Proximo a praia',
        p_nm_rua => 'Avenida Atlantica',
        p_nr_latitude_x => '-22.9711',
        p_nr_latitude_y => '-43.1822',
        p_nm_usuario => 'Usuario2'
    );

    insert_t_cp_area(
        p_nr_cep => '30130-010',
        p_nm_cidade => 'Belo Horizonte',
        p_nm_estado => 'MG',
        p_ds_localizacao_banca => 'Centro',
        p_nm_rua => 'Avenida Afonso Pena',
        p_nr_latitude_x => '-19.9191',
        p_nr_latitude_y => '-43.9386',
        p_nm_usuario => 'Usuario3'
    );

    insert_t_cp_area(
        p_nr_cep => '80010-100',
        p_nm_cidade => 'Curitiba',
        p_nm_estado => 'PR',
        p_ds_localizacao_banca => 'Proximo ao Jardim Botanico',
        p_nm_rua => 'Avenida Sete de Setembro',
        p_nr_latitude_x => '-25.4284',
        p_nr_latitude_y => '-49.2733',
        p_nm_usuario => 'Usuario4'
    );

    insert_t_cp_area(
        p_nr_cep => '40010-150',
        p_nm_cidade => 'Salvador',
        p_nm_estado => 'BA',
        p_ds_localizacao_banca => 'Proximo ao Pelourinho',
        p_nm_rua => 'Rua Chile',
        p_nr_latitude_x => '-12.9714',
        p_nr_latitude_y => '-38.5014',
        p_nm_usuario => 'Usuario5'
    );
END;


CREATE OR REPLACE PROCEDURE exception_area AS
BEGIN
    insert_t_cp_area(
        p_nr_cep => '40010-150',
        p_nm_cidade => 'Salvador',
        p_nm_estado => 'BA',
        p_ds_localizacao_banca => 'Proximo ao Pelourinho',
        p_nm_rua => 'Rua Chile',
        p_nr_latitude_x => '-12.9714',
        p_nr_latitude_y => '-38.5014',
        p_nm_usuario => 'Usuario5'
    );  
END;

exec todos_inserts_area;
exec exception_area;
select * from t_cp_log_errors;

-- USUARIO
CREATE OR REPLACE PROCEDURE insert_t_cp_usuario (
    p_cd_usuario  IN VARCHAR2,
    p_cd_senha    IN VARCHAR2,
    p_st_funcao   IN CHAR,
    p_nm_usuario  IN VARCHAR2
) AS
    v_id_usuario char(9);
    v_id_log CHAR(9);
    v_dt_ocorrencia DATE;
    v_cd_erro INTEGER;
    v_ds_erro VARCHAR2(255);
BEGIN
    v_id_usuario := seq_usuario.NEXTVAL;
    
    INSERT INTO t_cp_usuario (id_usuario, cd_usuario, cd_senha, st_funcao)
    VALUES (v_id_usuario, p_cd_usuario, p_cd_senha, p_st_funcao);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        
        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_usuario', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro DUP_VAL_ON_INDEX capturado, cheque T_cp_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
    WHEN VALUE_ERROR THEN
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;

        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_usuario', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro VALUE_ERROR capturado, cheque T_cp_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
    WHEN OTHERS THEN
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;

        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_usuario', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro OTHERS capturado, cheque T_cp_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
END;

CREATE OR REPLACE PROCEDURE todos_inserts_usuario AS
BEGIN
    insert_t_cp_usuario(
        p_cd_usuario => 'jdoe',
        p_cd_senha => 'securePass123',
        p_st_funcao => 'A',
        p_nm_usuario => 'John Doe'
    );
    
    insert_t_cp_usuario(
        p_cd_usuario => 'asmith',
        p_cd_senha => 'password456',
        p_st_funcao => 'P',
        p_nm_usuario => 'Alice Smith'
    );
    
    insert_t_cp_usuario(
        p_cd_usuario => 'bwayne',
        p_cd_senha => 'batman789',
        p_st_funcao => 'A',
        p_nm_usuario => 'Bruce Wayne'
    );
    
    insert_t_cp_usuario(
        p_cd_usuario => 'ckent',
        p_cd_senha => 'superman101',
        p_st_funcao => 'P',
        p_nm_usuario => 'Clark Kent'
    );

    insert_t_cp_usuario(
        p_cd_usuario => 'pparker',
        p_cd_senha => 'spiderman202',
        p_st_funcao => 'A',
        p_nm_usuario => 'Peter Parker'
    );
END;


CREATE OR REPLACE PROCEDURE exception_usuario AS
BEGIN
    -- DUP_VAL_ON_INDEX
    insert_t_cp_usuario(
        p_cd_usuario => 'jdoe',
        p_cd_senha => 'securePass123',
        p_st_funcao => 'A',
        p_nm_usuario => 'John Doe'
    );
END;

exec todos_inserts_usuario;
exec exception_usuario;
select * from t_cp_log_errors;

-- participante
CREATE OR REPLACE PROCEDURE insert_t_cp_participante (
    p_nm_participante  IN VARCHAR2,
    p_dt_nascimento  IN DATE,
    p_tp_sexo        IN CHAR,
    p_ds_email       IN VARCHAR2,
    p_id_usuario     IN CHAR,
    p_nm_usuario     IN VARCHAR2
) AS
    v_id_participante char(9);
    v_id_log CHAR(9);
    v_dt_ocorrencia DATE;
    v_cd_erro INTEGER;
    v_ds_erro VARCHAR2(255);
BEGIN
    v_id_participante := seq_participante.NEXTVAL;
    
    INSERT INTO t_cp_participante (id_participante, nm_participante, dt_nascimento, tp_sexo, ds_email, id_usuario)
    VALUES (v_id_participante, p_nm_participante, p_dt_nascimento, p_tp_sexo, p_ds_email, p_id_usuario);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        
        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_participante', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro DUP_VAL_ON_INDEX capturado, cheque T_CP_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
    WHEN VALUE_ERROR THEN
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;

        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_participante', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro VALUE_ERROR capturado, cheque T_CP_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
    WHEN OTHERS THEN
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;

        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_participante', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro OTHERS capturado, cheque T_CP_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
END;

CREATE OR REPLACE PROCEDURE todos_inserts_participante AS
BEGIN
    insert_t_cp_participante(
        p_nm_participante => 'Carlos Silva',
        p_dt_nascimento => TO_DATE('1990/01/01', 'yyyy/mm/dd'),
        p_tp_sexo => 'M',
        p_ds_email => 'carlos.silva@example.com',
        p_id_usuario => '1',
        p_nm_usuario => 'Carlos Silva'
    );

    insert_t_cp_participante(
        p_nm_participante => 'Maria Oliveira',
        p_dt_nascimento => TO_DATE('1990/01/02', 'yyyy/mm/dd'),
        p_tp_sexo => 'F',
        p_ds_email => 'maria.oliveira@example.com',
        p_id_usuario => '2',
        p_nm_usuario => 'Maria Oliveira'
    );

    insert_t_cp_participante(
        p_nm_participante => 'João Souza',
        p_dt_nascimento => TO_DATE('1990/01/03', 'yyyy/mm/dd'),
        p_tp_sexo => 'M',
        p_ds_email => 'joao.souza@example.com',
        p_id_usuario => '3',
        p_nm_usuario => 'João Souza'
    );
    
    insert_t_cp_participante(
        p_nm_participante => 'Ana Pereira',
        p_dt_nascimento => TO_DATE('1990/01/04', 'yyyy/mm/dd'),
        p_tp_sexo => 'F',
        p_ds_email => 'ana.pereira@example.com',
        p_id_usuario => '4',
        p_nm_usuario => 'Ana Pereira'
    );

    insert_t_cp_participante(
        p_nm_participante => 'Pedro Lima',
        p_dt_nascimento => TO_DATE('1990/01/05', 'yyyy/mm/dd'),
        p_tp_sexo => 'M',
        p_ds_email => 'pedro.lima@example.com',
        p_id_usuario => '5',
        p_nm_usuario => 'Pedro Lima'
    );
END;


CREATE OR REPLACE PROCEDURE exception_participante AS
BEGIN
    insert_t_cp_participante(
        p_nm_participante => 'Pedro Lima',
        p_dt_nascimento => TO_DATE('1990/01/05', 'yyyy/mm/dd'),
        p_tp_sexo => 'M',
        p_ds_email => 'pedro.lima@example.com',
        p_id_usuario => 5,
        p_nm_usuario => 'Pedro Lima'
    );
END;

exec todos_inserts_participante;
exec exception_participante;
select * from t_cp_log_errors;

--  ADMIN
CREATE OR REPLACE PROCEDURE insert_t_cp_admin (
    p_nm_admin  IN VARCHAR2,
    p_id_usuario           IN CHAR,
    p_ds_email             IN VARCHAR2,
    p_nm_usuario           IN VARCHAR2
) AS
    v_id_admin CHAR(9);
    v_id_log CHAR(9);
    v_dt_ocorrencia DATE;
    v_cd_erro INTEGER;
    v_ds_erro VARCHAR2(255);
BEGIN
    v_id_admin := seq_admin.NEXTVAL;

    INSERT INTO t_cp_admin (id_admin, nm_admin, id_usuario, ds_email)
    VALUES (v_id_admin, p_nm_admin, p_id_usuario, p_ds_email);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        
        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_admin', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro DUP_VAL_ON_INDEX capturado, cheque T_CP_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
    WHEN VALUE_ERROR THEN
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;

        -- Insere o erro no log
        INSERT INTO t_CP_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_admin', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro VALUE_ERROR capturado, cheque T_CP_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
    WHEN OTHERS THEN
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;

        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_admin', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro OTHERS capturado, cheque T_CP_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
END;

CREATE OR REPLACE PROCEDURE todos_inserts_admin AS
BEGIN
  -- 1º Insert
  insert_t_cp_admin(
    p_nm_admin => 'Lucas Martins',
    p_id_usuario => '1',
    p_ds_email => 'lucas.martins@empresa.com',
    p_nm_usuario => 'lucas.martins'
  );

  -- 2º Insert
  insert_t_cp_admin(
    p_nm_admin => 'Fernanda Silva',
    p_id_usuario => '2',
    p_ds_email => 'fernanda.silva@empresa.com',
    p_nm_usuario => 'fernanda.silva'
  );

  -- 3º Insert
  insert_t_cp_admin(
    p_nm_admin => 'Carlos Pereira',
    p_id_usuario => '3',
    p_ds_email => 'carlos.pereira@empresa.com',
    p_nm_usuario => 'carlos.pereira'
  );

  -- 4º Insert
  insert_t_cp_admin(
    p_nm_admin => 'Ana Costa',
    p_id_usuario => '4',
    p_ds_email => 'ana.costa@empresa.com',
    p_nm_usuario => 'ana.costa'
  );

  -- 5º Insert
  insert_t_cp_admin(
    p_nm_admin => 'João Souzaa',
    p_id_usuario => '5',
    p_ds_email => 'joao.souzaa@empresa.com',
    p_nm_usuario => 'joao.souzaa'
  );
END;

CREATE OR REPLACE PROCEDURE exception_admin AS
BEGIN
  insert_t_cp_admin(
    p_nm_admin => 'João Souzaa',
    p_id_usuario => '5',
    p_ds_email => 'joao.souzaa@empresa.com',
    p_nm_usuario => 'joao.souzaa'
  );
END;

exec todos_inserts_admin;
exec exception_admin;
select * from t_cp_log_errors;

-- evento
CREATE OR REPLACE PROCEDURE insert_t_cp_evento (
    p_dt_evento_inicio      IN DATE,
    p_id_area                IN CHAR,
    p_st_evento             IN CHAR,
    p_dt_evento_encerramento IN DATE,
    p_id_admin    IN CHAR,
    p_nm_usuario             IN VARCHAR2
) AS
    v_id_evento CHAR(9);
    v_id_log CHAR(9);
    v_dt_ocorrencia DATE;
    v_cd_erro INTEGER;
    v_ds_erro VARCHAR2(255);
BEGIN
    v_id_evento := seq_evento.NEXTVAL;

    INSERT INTO t_cp_evento (id_evento, dt_evento_inicio, id_area, st_evento, dt_evento_encerramento, id_admin)
    VALUES (v_id_evento, p_dt_evento_inicio, p_id_area, p_st_evento, p_dt_evento_encerramento, p_id_admin);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        
        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_evento', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro DUP_VAL_ON_INDEX capturado, cheque T_cp_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
    WHEN VALUE_ERROR THEN
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;

        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_evento', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro VALUE_ERROR capturado, cheque T_cp_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
    WHEN OTHERS THEN
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;

        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_evento', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro OTHERS capturado, cheque T_cp_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
END;

CREATE OR REPLACE PROCEDURE todos_inserts_evento AS
BEGIN
    -- 1º Insert
    insert_t_cp_evento(
        p_dt_evento_inicio => TO_DATE('2024/01/01', 'yyyy/mm/dd'),
        p_id_area => 1,
        p_st_evento => 'A',  -- 'A' para ativo
        p_dt_evento_encerramento => TO_DATE('2024/01/02', 'yyyy/mm/dd'),
        p_id_admin => 1,
        p_nm_usuario => 'Lucas Martins'
    );

    -- 2º Insert
    insert_t_cp_evento(
        p_dt_evento_inicio => TO_DATE('2024/01/01', 'yyyy/mm/dd'),
        p_id_area => 2,
        p_st_evento => 'E',  -- 'E' para encerrado
        p_dt_evento_encerramento => TO_DATE('2024/01/02', 'yyyy/mm/dd'),
        p_id_admin => 2,
        p_nm_usuario => 'Fernanda Silva'
    );
    
    -- 3º Insert
    insert_t_cp_evento(
        p_dt_evento_inicio => TO_DATE('2024/01/01', 'yyyy/mm/dd'),
        p_id_area => 3,
        p_st_evento => 'A',  -- 'A' para ativo
        p_dt_evento_encerramento => TO_DATE('2024/01/02', 'yyyy/mm/dd'),
        p_id_admin => 3,
        p_nm_usuario => 'Carlos Pereira'
    );
    
    -- 4º Insert
    insert_t_cp_evento(
        p_dt_evento_inicio => TO_DATE('2024/01/01', 'yyyy/mm/dd'),
        p_id_area => 4,
        p_st_evento => 'E',  -- 'E' para encerrado
        p_dt_evento_encerramento => TO_DATE('2024/01/02', 'yyyy/mm/dd'),
        p_id_admin => 4,
        p_nm_usuario => 'Ana Costa'
    );

    -- 5º Insert
    insert_t_cp_evento(
        p_dt_evento_inicio => TO_DATE('2024/01/01', 'yyyy/mm/dd'),
        p_id_area => 5,
        p_st_evento => 'A',  -- 'A' para ativo
        p_dt_evento_encerramento => TO_DATE('2024/01/02', 'yyyy/mm/dd'),
        p_id_admin => 5,
        p_nm_usuario => 'João Souza'
    );
END;

CREATE OR REPLACE PROCEDURE exception_evento AS
BEGIN
    insert_t_cp_evento(
        p_dt_evento_inicio => TO_DATE('2024/01/01', 'yyyy/mm/dd'),
        p_id_area => 5,
        p_st_evento => 'A',  -- 'A' para ativo
        p_dt_evento_encerramento => TO_DATE('2024/01/02', 'yyyy/mm/dd'),
        p_id_admin => 5,
        p_nm_usuario => 'João Souza'
    );
END;

exec todos_inserts_evento;
exec exception_evento;
select * from t_cp_log_errors;

-- Participacao
CREATE OR REPLACE PROCEDURE insert_t_cp_participacao (
    p_id_evento          IN CHAR,
    p_id_participante    IN CHAR,
    p_dt_participacao    IN DATE,
    p_nm_usuario         IN VARCHAR2
) AS
    v_id_participacao CHAR(9);
    v_id_log CHAR(9);
    v_dt_ocorrencia DATE;
    v_cd_erro INTEGER;
    v_ds_erro VARCHAR2(255);
BEGIN
    -- Gera um novo ID de participação usando a sequência
    v_id_participacao := seq_participacao.NEXTVAL;

    -- Inserção na tabela t_cp_participacao
    INSERT INTO t_cp_participacao (id_participacao, id_evento, id_participante, dt_participacao)
    VALUES (v_id_participacao, p_id_evento, p_id_participante, p_dt_participacao);

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        -- Trata erro de valor duplicado
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;

        -- Insere erro no log de erros
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_participacao', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro DUP_VAL_ON_INDEX capturado, cheque T_CP_LOG_ERRORS para mais detalhes: ' || v_ds_erro);

    WHEN VALUE_ERROR THEN
        -- Trata erro de valor inválido
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;

        -- Insere erro no log de erros
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_participacao', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro VALUE_ERROR capturado, cheque T_CP_LOG_ERRORS para mais detalhes: ' || v_ds_erro);

    WHEN OTHERS THEN
        -- Trata outros erros
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;

        -- Insere erro no log de erros
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_t_cp_participacao', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro OTHERS capturado, cheque T_CP_LOG_ERRORS para mais detalhes: ' || v_ds_erro);
END;

CREATE OR REPLACE PROCEDURE todos_inserts_participacao AS
BEGIN
    -- 1º Insert
    insert_t_cp_participacao(
        p_id_evento => '1', 
        p_id_participante => '1', 
        p_dt_participacao => TO_DATE('2024/01/01', 'yyyy/mm/dd'),
        p_nm_usuario => 'Lucas Martins'
    );

    -- 2º Insert
    insert_t_cp_participacao(
        p_id_evento => '2', 
        p_id_participante => '2', 
        p_dt_participacao => TO_DATE('2024/01/01', 'yyyy/mm/dd'),
        p_nm_usuario => 'Fernanda Silva'
    );
    
    -- 3º Insert
    insert_t_cp_participacao(
        p_id_evento => '3', 
        p_id_participante => '3', 
        p_dt_participacao => TO_DATE('2024/01/01', 'yyyy/mm/dd'),
        p_nm_usuario => 'Carlos Pereira'
    );
    
    -- 4º Insert
    insert_t_cp_participacao(
        p_id_evento => '4', 
        p_id_participante => '4', 
        p_dt_participacao => TO_DATE('2024/01/01', 'yyyy/mm/dd'),
        p_nm_usuario => 'Ana Costa'
    );

    -- 5º Insert
    insert_t_cp_participacao(
        p_id_evento => '5', 
        p_id_participante => '5', 
        p_dt_participacao => TO_DATE('2024/01/01', 'yyyy/mm/dd'),
        p_nm_usuario => 'João Souza'
    );
END;

CREATE OR REPLACE PROCEDURE exception_participacao AS
BEGIN -- Recriar exception
    insert_t_cp_participacao(
        p_id_evento => '999999999', -- Um ID de evento que não existe
        p_id_participante => '999999999', -- Um ID de participante que não existe
        p_dt_participacao => TO_DATE('2024/01/01', 'yyyy/mm/dd'),
        p_nm_usuario => 'João Souza'
    );
END;

exec todos_inserts_participacao;
exec exception_participacao;
select * from t_cp_log_errors;

commit;
-- agr o negocio de vdd
set serveroutput on;

-- functions

-- Calcula idade
CREATE OR REPLACE FUNCTION fn_calcular_idade(
    p_id_participante CHAR
) RETURN NUMBER IS
    v_idade NUMBER;
    v_dt_nascimento DATE;
BEGIN
    -- Busca a data de nascimento do participante informado
    SELECT dt_nascimento INTO v_dt_nascimento 
    FROM t_cp_participante 
    WHERE id_participante = p_id_participante;

    -- Calcula a idade com base na data atual
    v_idade := FLOOR(MONTHS_BETWEEN(SYSDATE, v_dt_nascimento) / 12);

    RETURN v_idade;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Participante não encontrado.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erro ao calcular a idade.');
END;

SELECT fn_calcular_idade('1') AS idade FROM dual;


-- ver se participa de x evento
CREATE OR REPLACE FUNCTION fn_verificar_participacao (
    p_id_participante CHAR,
    p_id_evento CHAR
) RETURN NUMBER IS
    v_contagem NUMBER;
BEGIN
    -- Conta quantas participações o participante tem no evento informado
    SELECT COUNT(*)
    INTO v_contagem
    FROM t_cp_participacao
    WHERE id_participante = p_id_participante
    AND id_evento = p_id_evento;

    -- Se a contagem for maior que 0, já está registrado no evento
    IF v_contagem > 0 THEN
        RETURN 1;  -- Verdadeiro (participante já registrado)
    ELSE
        RETURN 0;  -- Falso (participante não registrado)
    END IF;

EXCEPTION
    -- Tratamento de erros
    WHEN OTHERS THEN
        -- Captura outros erros e levanta uma exceção
        RAISE_APPLICATION_ERROR(-20003, 'Erro ao verificar a participação: ' || SQLERRM);
END;


-- Procedures

-- verifica participação antes de fazer o insert
CREATE OR REPLACE PROCEDURE insert_participacao_verificada (
    p_id_participante   CHAR,
    p_id_evento         CHAR,
    p_dt_participacao   DATE,
    p_nm_usuario        VARCHAR2
) AS
    v_participacao_existe NUMBER;
    v_id_participacao CHAR(9);
    v_id_log CHAR(9);
    v_dt_ocorrencia DATE;
    v_cd_erro INTEGER;
    v_ds_erro VARCHAR2(255);
BEGIN
    -- Verifica se o participante já está registrado no evento
    v_participacao_existe := fn_verificar_participacao(p_id_participante, p_id_evento);

    IF v_participacao_existe = 1 THEN
        -- Se o participante já estiver registrado, registra o erro e não insere
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := -20004;
        v_ds_erro := 'Participante já registrado no evento. Inserção não permitida.';

        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_participacao_verificada', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);

        DBMS_OUTPUT.PUT_LINE('Erro: ' || v_ds_erro);
    ELSE
        -- Caso o participante não esteja registrado, procede com a inserção
        v_id_participacao := LPAD(seq_participacao.NEXTVAL, 9, '0');

        INSERT INTO t_cp_participacao (id_participacao, id_evento, id_participante, dt_participacao)
        VALUES (v_id_participacao, p_id_evento, p_id_participante, p_dt_participacao);

        DBMS_OUTPUT.PUT_LINE('Participação inserida com sucesso.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Se ocorrer um erro, registra no log de erros
        v_id_log := LPAD(seq_log_errors.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_cp_log_errors (id_log, nm_procedure, nm_usuario, dt_ocorrencia, cd_erro, ds_erro)
        VALUES (v_id_log, 'insert_participacao_verificada', p_nm_usuario, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro OTHERS capturado: ' || v_ds_erro);
END;

BEGIN
    insert_participacao_verificada(
        p_id_participante => '4',
        p_id_evento => '1',
        p_dt_participacao => TO_DATE('2024/01/01', 'yyyy/mm/dd'),
        p_nm_usuario => 'João Souza'
    );
END;

-- Para dar exception

BEGIN
    insert_participacao_verificada(
        p_id_participante => '99',
        p_id_evento => '3',
        p_dt_participacao => TO_DATE('2024/01/01', 'yyyy/mm/dd'),
        p_nm_usuario => 'João Souza'
    );
END;
select * from t_cp_log_errors;


-- Listar participantes de um evento
CREATE OR REPLACE PROCEDURE listar_participantes_evento (
    p_id_evento CHAR
) AS
BEGIN
    FOR rec IN (
        SELECT p.nm_participante, p.dt_nascimento, e.dt_evento_inicio
        FROM t_cp_participante p
        INNER JOIN t_cp_participacao pp ON p.id_participante = pp.id_participante
        INNER JOIN t_cp_evento e ON pp.id_evento = e.id_evento
        WHERE e.id_evento = p_id_evento
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Participante: ' || rec.nm_participante || 
                             ', Data de Nascimento: ' || TO_CHAR(rec.dt_nascimento, 'DD/MM/YYYY') ||
                             ', Data do Evento: ' || TO_CHAR(rec.dt_evento_inicio, 'DD/MM/YYYY'));
    END LOOP;
    
    -- Se nenhum participante for encontrado, exibir mensagem
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum participante encontrado para o evento ID: ' || p_id_evento);
    END IF;
END;

BEGIN
    listar_participantes_evento(p_id_evento => '1'); -- Substitua pelo ID de um evento existente
END;


-- trigger
CREATE OR REPLACE TRIGGER trg_auditoria_evento
BEFORE INSERT OR UPDATE OR DELETE
ON t_cp_evento
FOR EACH ROW
DECLARE
    v_operacao VARCHAR2(10);
    v_old_data VARCHAR2(250);
    v_new_data VARCHAR2(250);
BEGIN
    -- Determinar o tipo de operação
    IF INSERTING THEN
        v_operacao := 'INSERT';
        v_new_data := 'ID_EVENTO=' || :NEW.id_evento || ', DT_INICIO=' || TO_CHAR(:NEW.dt_evento_inicio, 'DD/MM/YYYY') || 
                      ', ID_AREA=' || :NEW.id_area || ', ST_EVENTO=' || :NEW.st_evento || 
                      ', DT_ENCERRAMENTO=' || TO_CHAR(:NEW.dt_evento_encerramento, 'DD/MM/YYYY');
        v_old_data := NULL; -- Não há dados antigos para inserção
    ELSIF UPDATING THEN
        v_operacao := 'UPDATE';
        v_new_data := 'ID_EVENTO=' || :NEW.id_evento || ', DT_INICIO=' || TO_CHAR(:NEW.dt_evento_inicio, 'DD/MM/YYYY') || 
                      ', ID_AREA=' || :NEW.id_area || ', ST_EVENTO=' || :NEW.st_evento || 
                      ', DT_ENCERRAMENTO=' || TO_CHAR(:NEW.dt_evento_encerramento, 'DD/MM/YYYY');
        v_old_data := 'ID_EVENTO=' || :OLD.id_evento || ', DT_INICIO=' || TO_CHAR(:OLD.dt_evento_inicio, 'DD/MM/YYYY') || 
                      ', ID_AREA=' || :OLD.id_area || ', ST_EVENTO=' || :OLD.st_evento || 
                      ', DT_ENCERRAMENTO=' || TO_CHAR(:OLD.dt_evento_encerramento, 'DD/MM/YYYY');
    ELSIF DELETING THEN
        v_operacao := 'DELETE';
        v_old_data := 'ID_EVENTO=' || :OLD.id_evento || ', DT_INICIO=' || TO_CHAR(:OLD.dt_evento_inicio, 'DD/MM/YYYY') || 
                      ', ID_AREA=' || :OLD.id_area || ', ST_EVENTO=' || :OLD.st_evento || 
                      ', DT_ENCERRAMENTO=' || TO_CHAR(:OLD.dt_evento_encerramento, 'DD/MM/YYYY');
        v_new_data := NULL; -- Não há dados novos para exclusão
    END IF;

    -- Inserir o registro de auditoria na tabela T_CP_AUDITORIA
    INSERT INTO t_cp_auditoria (
        id_auditoria, tabela_auditada, operacao, usuario, data_operacao, old_data, new_data
    ) VALUES (
        seq_auditoria.NEXTVAL,
        'T_CP_EVENTO',
        v_operacao,
        SYS_CONTEXT('USERENV', 'SESSION_USER'), -- Obtém o usuário atual
        SYSDATE,
        v_old_data,
        v_new_data
    );
END;

INSERT INTO t_cp_area (
    id_area, nr_cep, nm_cidade, nm_estado, ds_localizacao_banca, nm_rua, nr_latitude_x, nr_latitude_y
) VALUES (
    '11', '12345-678', 'São Paulo', 'SP', 'Centro', 'Rua A', '23.5505S', '46.6333W'
);

INSERT INTO t_cp_evento (id_evento, dt_evento_inicio, id_area, st_evento, dt_evento_encerramento, id_admin)
VALUES ('11', TO_DATE('2024-01-01', 'YYYY-MM-DD'), '11', 'A', TO_DATE('2024-01-02', 'YYYY-MM-DD'), '1');

UPDATE t_cp_evento
SET st_evento = 'E'
WHERE id_evento = '11';

DELETE FROM t_cp_evento
WHERE id_evento = '11';

select * from t_cp_auditoria;


-- Pacotes -- 
CREATE OR REPLACE PACKAGE pkg_participantes AS
    -- Procedure para inserir um novo participante
    PROCEDURE inserir_participante(
        p_id_participante  CHAR,
        p_nm_participante  VARCHAR2,
        p_dt_nascimento    DATE,
        p_tp_sexo          CHAR,
        p_ds_email         VARCHAR2,
        p_id_usuario       CHAR
    );
    
    -- Função para consultar o nome de um participante
    FUNCTION consultar_participante(
        p_id_participante  CHAR
    ) RETURN VARCHAR2;
END pkg_participantes;

CREATE OR REPLACE PACKAGE BODY pkg_participantes AS

    -- Procedure para inserir um novo participante
    PROCEDURE inserir_participante(
        p_id_participante  CHAR,
        p_nm_participante  VARCHAR2,
        p_dt_nascimento    DATE,
        p_tp_sexo          CHAR,
        p_ds_email         VARCHAR2,
        p_id_usuario       CHAR
    ) IS
    BEGIN
        INSERT INTO t_cp_participante (
            id_participante, nm_participante, dt_nascimento, tp_sexo, ds_email, id_usuario
        ) VALUES (
            p_id_participante, p_nm_participante, p_dt_nascimento, p_tp_sexo, p_ds_email, p_id_usuario
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Erro ao inserir participante.');
    END inserir_participante;
    
    -- Função para consultar o nome de um participante
    FUNCTION consultar_participante(
        p_id_participante  CHAR
    ) RETURN VARCHAR2 IS
        v_nm_participante VARCHAR2(255);
    BEGIN
        SELECT nm_participante INTO v_nm_participante
        FROM t_cp_participante
        WHERE id_participante = p_id_participante;

        RETURN v_nm_participante;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Participante não encontrado';
        WHEN OTHERS THEN
            RETURN 'Erro ao consultar o participante';
    END consultar_participante;

END pkg_participantes;

BEGIN
    pkg_participantes.inserir_participante(
        p_id_participante => '21',
        p_nm_participante => 'João Silvaa',
        p_dt_nascimento => TO_DATE('1990-01-01', 'YYYY-MM-DD'),
        p_tp_sexo => 'M',
        p_ds_email => 'joao.silva@email.com',
        p_id_usuario => '4'
    );
END;

DECLARE
    v_nome_participante VARCHAR2(255);
BEGIN
    v_nome_participante := pkg_participantes.consultar_participante('21');
    DBMS_OUTPUT.PUT_LINE('Nome do Participante: ' || v_nome_participante);
END;


exec todos_inserts_area;
select * from t_cp_area;
exec todos_inserts_usuario;
select * from t_cp_usuario;
exec todos_inserts_participante;
select * from t_cp_participante;
exec todos_inserts_admin;
select * from t_cp_admin;
exec todos_inserts_evento;
select * from t_cp_evento;
exec todos_inserts_participacao;
select * from t_cp_participacao;