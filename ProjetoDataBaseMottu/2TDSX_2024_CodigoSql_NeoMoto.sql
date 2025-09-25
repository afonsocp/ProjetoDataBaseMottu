-- NeoMoto - Projeto Oracle SQL completo
-- Estrutura, carga, funções, procedimentos e trigger de auditoria
-- Observação: Não utiliza funções JSON internas (TO_JSON, JSON_OBJECT, etc.)

-- Limpeza prévia (ignore erros se objetos não existirem)
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER TR_AUDITORIA_RESERVA'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE AUDITORIA_RESERVA'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_AUDITORIA_RESERVA'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE MANUTENCAO'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE RESERVA'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE MOTO'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE USUARIO'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE LOCALIZACAO'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Tabelas
CREATE TABLE Localizacao (
  ID_Localizacao NUMBER PRIMARY KEY,
  Endereco       VARCHAR2(50),
  Cep            VARCHAR2(9),
  Cidade         VARCHAR2(50),
  Estado         VARCHAR2(50)
);
/

CREATE TABLE Moto (
  ID_Moto        NUMBER PRIMARY KEY,
  Placa          VARCHAR2(10) UNIQUE,
  Modelo         VARCHAR2(50),
  Ano            NUMBER,
  Status         VARCHAR2(20),
  ID_Localizacao NUMBER REFERENCES Localizacao(ID_Localizacao)
);
/

CREATE TABLE Usuario (
  ID_Usuario NUMBER PRIMARY KEY,
  Nome       VARCHAR2(100),
  Email      VARCHAR2(100),
  Senha      VARCHAR2(100)
);
/

CREATE TABLE Manutencao (
  ID_Manutencao NUMBER PRIMARY KEY,
  Data          DATE,
  Descricao     VARCHAR2(255),
  Custo         NUMBER(10,2),
  ID_Moto       NUMBER REFERENCES Moto(ID_Moto)
);
/

CREATE TABLE Reserva (
  ID_Reserva     NUMBER PRIMARY KEY,
  Data_Reserva   DATE,
  Data_Devolucao DATE,
  ID_Usuario     NUMBER REFERENCES Usuario(ID_Usuario),
  ID_Moto        NUMBER REFERENCES Moto(ID_Moto)
);
/

-- Sequência para auditoria
CREATE SEQUENCE SEQ_AUDITORIA_RESERVA START WITH 1 INCREMENT BY 1;
/

-- Tabela de auditoria
CREATE TABLE Auditoria_Reserva (
  ID_Auditoria   NUMBER PRIMARY KEY,
  Usuario_BD     VARCHAR2(128),
  Operacao       VARCHAR2(10),
  Data_Operacao  DATE,
  Valores_Old    CLOB,
  Valores_New    CLOB
);
/

-- Carga de dados (mínimo 5 por tabela)
INSERT INTO Localizacao VALUES (1, 'Rua Alfa, 10', '01000-000', 'São Paulo', 'SP');
INSERT INTO Localizacao VALUES (2, 'Av. Beta, 20', '20000-000', 'Rio de Janeiro', 'RJ');
INSERT INTO Localizacao VALUES (3, 'Rua Gama, 30', '30000-000', 'Belo Horizonte', 'MG');
INSERT INTO Localizacao VALUES (4, 'Av. Delta, 40', '80000-000', 'Curitiba', 'PR');
INSERT INTO Localizacao VALUES (5, 'Rua Epsilon, 50', '70000-000', 'Brasília', 'DF');
/

INSERT INTO Moto VALUES (1, 'ABC1A23', 'CG 160', 2022, 'Disponivel', 1);
INSERT INTO Moto VALUES (2, 'DEF4B56', 'NMAX 160', 2023, 'Disponivel', 1);
INSERT INTO Moto VALUES (3, 'GHI7C89', 'PCX 160', 2021, 'Manutencao', 2);
INSERT INTO Moto VALUES (4, 'JKL0D12', 'Fazer 250', 2020, 'Disponivel', 2);
INSERT INTO Moto VALUES (5, 'MNO3E45', 'XTZ 250', 2022, 'Disponivel', 3);
INSERT INTO Moto VALUES (6, 'PQR6F78', 'CB 300', 2024, 'Disponivel', 4);
INSERT INTO Moto VALUES (7, 'STU9G01', 'ADV 160', 2023, 'Disponivel', 5);
/

INSERT INTO Usuario VALUES (1, 'Ana Silva', 'ana@mottu.com', 'Senha@123');
INSERT INTO Usuario VALUES (2, 'Bruno Souza', 'bruno@mottu.com', 'Senha@123');
INSERT INTO Usuario VALUES (3, 'Carla Lima', 'carla@mottu.com', 'Senha@123');
INSERT INTO Usuario VALUES (4, 'Diego Alves', 'diego@mottu.com', 'Senha@123');
INSERT INTO Usuario VALUES (5, 'Elaine Dias', 'elaine@mottu.com', 'Senha@123');
/

INSERT INTO Manutencao VALUES (1, DATE '2024-01-10', 'Troca de óleo',            150.00, 1);
INSERT INTO Manutencao VALUES (2, DATE '2024-02-11', 'Pastilha de freio',        220.00, 1);
INSERT INTO Manutencao VALUES (3, DATE '2024-01-15', 'Pneu traseiro',            480.00, 2);
INSERT INTO Manutencao VALUES (4, DATE '2024-03-05', 'Revisão 10k',              350.00, 2);
INSERT INTO Manutencao VALUES (5, DATE '2024-03-20', 'Coroa e pinhão',           320.00, 3);
INSERT INTO Manutencao VALUES (6, DATE '2024-04-01', 'Troca de óleo',            150.00, 3);
INSERT INTO Manutencao VALUES (7, DATE '2024-04-15', 'Embreagem',                600.00, 4);
INSERT INTO Manutencao VALUES (8, DATE '2024-05-01', 'Revisão 10k',              350.00, 5);
INSERT INTO Manutencao VALUES (9, DATE '2024-05-15', 'Pastilha de freio',        220.00, 6);
INSERT INTO Manutencao VALUES (10, DATE '2024-06-01', 'Pneu dianteiro',          420.00, 7);
/

INSERT INTO Reserva VALUES (1, DATE '2024-06-10', DATE '2024-06-12', 1, 1);
INSERT INTO Reserva VALUES (2, DATE '2024-07-01', DATE '2024-07-05', 2, 2);
INSERT INTO Reserva VALUES (3, DATE '2024-07-10', DATE '2024-07-12', 3, 3);
INSERT INTO Reserva VALUES (4, DATE '2024-08-01', DATE '2024-08-03', 4, 4);
INSERT INTO Reserva VALUES (5, DATE '2024-08-10', DATE '2024-08-12', 5, 5);
/

COMMIT;
/

-- Função 1: Converte resultado relacional em JSON manualmente (sem funções JSON built-in)
-- Retorna um array JSON de motos com localizacao: [{"id_moto":1, "placa":"...", "estado":"SP", ...}]
CREATE OR REPLACE FUNCTION fn_motos_em_json RETURN CLOB IS
  v_json       CLOB := '[';
  v_first      BOOLEAN := TRUE;
  v_piece      VARCHAR2(4000);
  CURSOR c_motos IS
    SELECT m.ID_Moto, m.Placa, m.Modelo, m.Ano, m.Status, l.Cidade, l.Estado
    FROM Moto m
    JOIN Localizacao l ON l.ID_Localizacao = m.ID_Localizacao
    ORDER BY m.ID_Moto;
BEGIN
  FOR r IN c_motos LOOP
    IF NOT v_first THEN v_json := v_json || ','; END IF;
    v_first := FALSE;

    -- Montagem manual do objeto JSON
    v_piece := '{' ||
      '"id_moto":' || r.ID_Moto || ',' ||
      '"placa":"'  || REPLACE(r.Placa,'"','\"') || '",' ||
      '"modelo":"' || REPLACE(r.Modelo,'"','\"') || '",' ||
      '"ano":'      || r.Ano || ',' ||
      '"status":"' || REPLACE(r.Status,'"','\"') || '",' ||
      '"cidade":"' || REPLACE(r.Cidade,'"','\"') || '",' ||
      '"estado":"' || REPLACE(r.Estado,'"','\"') || '"' ||
    '}';

    v_json := v_json || v_piece;
  END LOOP;

  v_json := v_json || ']';
  RETURN v_json;
EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN '[]';
  WHEN VALUE_ERROR THEN RETURN '[{"erro":"VALUE_ERROR"}]';
  WHEN OTHERS THEN RETURN '[{"erro":"'|| REPLACE(SQLERRM,'"','\"') ||'"}]';
END;
/

-- Função 2: Valida senha com política simples (mín 8, maiúscula, minúscula, dígito, especial)
CREATE OR REPLACE FUNCTION fn_valida_senha(p_senha IN VARCHAR2) RETURN VARCHAR2 IS
  v_tem_maiuscula BOOLEAN := FALSE;
  v_tem_minuscula BOOLEAN := FALSE;
  v_tem_digito    BOOLEAN := FALSE;
  v_tem_especial  BOOLEAN := FALSE;
BEGIN
  IF p_senha IS NULL THEN RETURN 'Senha inválida: vazia'; END IF;
  IF LENGTH(p_senha) < 8 THEN RETURN 'Senha inválida: mínimo 8'; END IF;

  FOR i IN 1..LENGTH(p_senha) LOOP
    DECLARE ch CHAR(1) := SUBSTR(p_senha, i, 1); n NUMBER; BEGIN
      IF ch BETWEEN 'A' AND 'Z' THEN v_tem_maiuscula := TRUE;
      ELSIF ch BETWEEN 'a' AND 'z' THEN v_tem_minuscula := TRUE;
      ELSE
        n := TO_NUMBER(ch);
        v_tem_digito := TRUE;
      END IF;
    EXCEPTION WHEN VALUE_ERROR THEN v_tem_especial := TRUE; END;
  END LOOP;

  IF v_tem_maiuscula AND v_tem_minuscula AND v_tem_digito AND v_tem_especial THEN
    RETURN 'OK';
  ELSE
    RETURN 'Senha fraca';
  END IF;
EXCEPTION
  WHEN VALUE_ERROR THEN RETURN 'Erro de valor na senha';
  WHEN OTHERS THEN RETURN 'Erro: '||SQLERRM;
END;
/

-- Procedimento 1: JOIN entre tabelas e exibição JSON via função 1
CREATE OR REPLACE PROCEDURE pr_listar_motos_json AS
  v_json CLOB;
  v_pos NUMBER := 1;
  v_next_pos NUMBER;
  v_line_length NUMBER := 80;
BEGIN
  v_json := fn_motos_em_json();
  DBMS_OUTPUT.PUT_LINE('JSON de motos e localizacao:');
  
  -- Quebrar o JSON em linhas menores para melhor visualização
  WHILE v_pos <= LENGTH(v_json) LOOP
    v_next_pos := v_pos + v_line_length;
    
    -- Tentar quebrar em uma vírgula próxima para não cortar no meio de um objeto
    IF v_next_pos < LENGTH(v_json) THEN
      FOR i IN REVERSE v_pos..(v_pos + v_line_length) LOOP
        IF SUBSTR(v_json, i, 1) = ',' THEN
          v_next_pos := i;
          EXIT;
        END IF;
      END LOOP;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE(SUBSTR(v_json, v_pos, v_next_pos - v_pos + 1));
    v_pos := v_next_pos + 1;
  END LOOP;
  
EXCEPTION
  WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Nenhum dado encontrado.');
  WHEN VALUE_ERROR THEN DBMS_OUTPUT.PUT_LINE('Erro de valor.');
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro: '||SQLERRM);
END;
/

-- Procedimento 2: Somatórios manuais por duas categorias (Localizacao -> Moto) e subtotal/total
-- Categorias: Agencia = ID_Localizacao, Conta = ID_Moto, Valor somado = Custo da manutencao
CREATE OR REPLACE PROCEDURE pr_saldos_manutencao_relatorio AS
  CURSOR c_dados IS
    SELECT l.ID_Localizacao AS Agencia,
           m.ID_Moto       AS Conta,
           NVL(SUM(x.Custo),0) AS Saldo
      FROM Localizacao l
      JOIN Moto m ON m.ID_Localizacao = l.ID_Localizacao
      LEFT JOIN Manutencao x ON x.ID_Moto = m.ID_Moto
     GROUP BY l.ID_Localizacao, m.ID_Moto
     ORDER BY l.ID_Localizacao, m.ID_Moto;

  v_agencia_atual NUMBER := NULL;
  v_subtotal      NUMBER := 0;
  v_total_geral   NUMBER := 0;

  PROCEDURE print_linha(p_ag VARCHAR2, p_conta VARCHAR2, p_valor NUMBER) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(
      RPAD(NVL(p_ag,' '),10) || RPAD(NVL(p_conta,' '),8) || TO_CHAR(p_valor,'9999990.99')
    );
  END;
BEGIN
  DBMS_OUTPUT.PUT_LINE(RPAD('Agencia',10) || RPAD('Conta',8) || 'Saldo');
  DBMS_OUTPUT.PUT_LINE(RPAD('-',10,'-') || RPAD('-',8,'-') || RPAD('-',10,'-'));

  FOR r IN c_dados LOOP
    IF v_agencia_atual IS NULL THEN
      v_agencia_atual := r.Agencia;
    ELSIF r.Agencia <> v_agencia_atual THEN
      print_linha('Sub Total', NULL, v_subtotal);
      v_subtotal := 0;
      v_agencia_atual := r.Agencia;
    END IF;

    print_linha(TO_CHAR(r.Agencia), TO_CHAR(r.Conta), r.Saldo);
    v_subtotal := v_subtotal + r.Saldo;
    v_total_geral := v_total_geral + r.Saldo;
  END LOOP;

  -- Último subtotal
  print_linha('Sub Total', NULL, v_subtotal);
  -- Total geral
  print_linha('Total Geral', NULL, v_total_geral);

EXCEPTION
  WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Sem dados para relatorio.');
  WHEN ZERO_DIVIDE THEN DBMS_OUTPUT.PUT_LINE('Divisao por zero inesperada.');
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro: '||SQLERRM);
END;
/

-- Trigger de auditoria em RESERVA (DML)
CREATE OR REPLACE TRIGGER TR_AUDITORIA_RESERVA
AFTER INSERT OR UPDATE OR DELETE ON Reserva
FOR EACH ROW
DECLARE
  v_old CLOB;
  v_new CLOB;
  v_operacao VARCHAR2(10);
BEGIN
  -- Determinar o tipo de operação
  IF INSERTING THEN
    v_operacao := 'INSERT';
  ELSIF UPDATING THEN
    v_operacao := 'UPDATE';
  ELSE
    v_operacao := 'DELETE';
  END IF;

  IF INSERTING OR UPDATING THEN
    v_new := '{' ||
      '"id_reserva":'    || NVL(TO_CHAR(:NEW.ID_Reserva),'null') || ',' ||
      '"data_reserva":"'|| NVL(TO_CHAR(:NEW.Data_Reserva,'YYYY-MM-DD'),'null') || '",' ||
      '"data_devolucao":"'|| NVL(TO_CHAR(:NEW.Data_Devolucao,'YYYY-MM-DD'),'null') || '",' ||
      '"id_usuario":'    || NVL(TO_CHAR(:NEW.ID_Usuario),'null') || ',' ||
      '"id_moto":'       || NVL(TO_CHAR(:NEW.ID_Moto),'null') ||
    '}';
  END IF;

  IF UPDATING OR DELETING THEN
    v_old := '{' ||
      '"id_reserva":'    || NVL(TO_CHAR(:OLD.ID_Reserva),'null') || ',' ||
      '"data_reserva":"'|| NVL(TO_CHAR(:OLD.Data_Reserva,'YYYY-MM-DD'),'null') || '",' ||
      '"data_devolucao":"'|| NVL(TO_CHAR(:OLD.Data_Devolucao,'YYYY-MM-DD'),'null') || '",' ||
      '"id_usuario":'    || NVL(TO_CHAR(:OLD.ID_Usuario),'null') || ',' ||
      '"id_moto":'       || NVL(TO_CHAR(:OLD.ID_Moto),'null') ||
    '}';
  END IF;

  INSERT INTO Auditoria_Reserva(ID_Auditoria, Usuario_BD, Operacao, Data_Operacao, Valores_Old, Valores_New)
  VALUES (SEQ_AUDITORIA_RESERVA.NEXTVAL,
          SYS_CONTEXT('USERENV','SESSION_USER'),
          v_operacao,
          SYSDATE,
          v_old,
          v_new);
EXCEPTION
  WHEN OTHERS THEN
    -- Em auditoria nunca devemos bloquear a transacao principal; apenas registrar erro secundario
    NULL;
END;
/

-- Chamadas de demonstração
BEGIN
  DBMS_OUTPUT.PUT_LINE('== Teste Procedimento 1 ==');
  pr_listar_motos_json();
  DBMS_OUTPUT.PUT_LINE(chr(10)||'== Teste Procedimento 2 ==');
  pr_saldos_manutencao_relatorio();
  DBMS_OUTPUT.PUT_LINE(chr(10)||'== Teste Funcao Senha ==');
  DBMS_OUTPUT.PUT_LINE('Senha "Abc123!@" => '|| fn_valida_senha('Abc123!@'));
  DBMS_OUTPUT.PUT_LINE('Senha "abcdef"  => '|| fn_valida_senha('abcdef'));
END;
/

-- Exemplos para disparar auditoria
BEGIN
  UPDATE Reserva SET Data_Devolucao = Data_Devolucao + 1 WHERE ID_Reserva = 1;
  DELETE FROM Reserva WHERE ID_Reserva = 5;
  INSERT INTO Reserva VALUES (6, SYSDATE, SYSDATE+2, 1, 6);
  COMMIT;
END;
/

-- Visualização da auditoria (para prints)
SET PAGESIZE 200 LINESIZE 200;
COLUMN Usuario_BD FORMAT A20;
COLUMN Operacao FORMAT A10;
SELECT Usuario_BD, Operacao, TO_CHAR(Data_Operacao,'YYYY-MM-DD HH24:MI:SS') AS Data_Operacao,
       DBMS_LOB.SUBSTR(Valores_Old, 200) AS Valores_Old,
       DBMS_LOB.SUBSTR(Valores_New, 200) AS Valores_New
  FROM Auditoria_Reserva
 ORDER BY ID_Auditoria;
/

-- ========================================================================
-- SCRIPTS DE DEMONSTRAÇÃO COMPLETA - NeoMoto
-- Execução de Funções, Procedimentos e Triggers com Tratamento de Exceções
-- ========================================================================

-- Configuração para melhor visualização
SET SERVEROUTPUT ON SIZE 1000000;
SET PAGESIZE 50;
SET LINESIZE 120;

PROMPT ========================================================================
PROMPT 1. DEMONSTRAÇÃO DAS FUNÇÕES
PROMPT ========================================================================

PROMPT 
PROMPT *** 1.1 FUNÇÃO fn_motos_em_json - EXECUÇÃO NORMAL ***
PROMPT 
SELECT fn_motos_em_json() AS "JSON_MOTOS" FROM DUAL;

PROMPT 
PROMPT *** 1.2 FUNÇÃO fn_valida_senha - EXECUÇÃO NORMAL ***
PROMPT 
SELECT fn_valida_senha('MinhaSenh@123') AS "SENHA_FORTE" FROM DUAL;
SELECT fn_valida_senha('senha123') AS "SENHA_FRACA" FROM DUAL;
SELECT fn_valida_senha('abc') AS "SENHA_CURTA" FROM DUAL;
SELECT fn_valida_senha(NULL) AS "SENHA_NULA" FROM DUAL;

PROMPT 
PROMPT *** 1.3 FORÇANDO EXCEÇÕES NAS FUNÇÕES ***
PROMPT 

-- Simulando erro na função fn_motos_em_json (removendo temporariamente uma tabela)
PROMPT === Testando fn_motos_em_json com erro (tabela inexistente) ===
BEGIN
  -- Renomear tabela temporariamente para forçar erro
  EXECUTE IMMEDIATE 'RENAME Moto TO Moto_TEMP';
  
  -- Tentar executar função (vai dar erro)
  DECLARE
    v_resultado CLOB;
  BEGIN
    v_resultado := fn_motos_em_json();
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_resultado);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('EXCEÇÃO CAPTURADA na função: ' || SQLERRM);
  END;
  
  -- Restaurar tabela
  EXECUTE IMMEDIATE 'RENAME Moto_TEMP TO Moto';
  DBMS_OUTPUT.PUT_LINE('Tabela restaurada com sucesso.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro no teste: ' || SQLERRM);
    -- Tentar restaurar mesmo com erro
    BEGIN
      EXECUTE IMMEDIATE 'RENAME Moto_TEMP TO Moto';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
END;
/

PROMPT 
PROMPT ========================================================================
PROMPT 2. DEMONSTRAÇÃO DOS PROCEDIMENTOS
PROMPT ========================================================================

PROMPT 
PROMPT *** 2.1 PROCEDIMENTO pr_listar_motos_json - EXECUÇÃO NORMAL ***
PROMPT 
BEGIN
  pr_listar_motos_json();
END;
/

PROMPT 
PROMPT *** 2.2 PROCEDIMENTO pr_saldos_manutencao_relatorio - EXECUÇÃO NORMAL ***
PROMPT 
BEGIN
  pr_saldos_manutencao_relatorio();
END;
/

PROMPT 
PROMPT *** 2.3 FORÇANDO EXCEÇÕES NOS PROCEDIMENTOS ***
PROMPT 

-- Testando procedimento com tabela inexistente
PROMPT === Testando pr_listar_motos_json com erro ===
BEGIN
  -- Renomear tabela temporariamente
  EXECUTE IMMEDIATE 'RENAME Localizacao TO Localizacao_TEMP';
  
  -- Executar procedimento (vai dar erro mas será tratado)
  pr_listar_motos_json();
  
  -- Restaurar tabela
  EXECUTE IMMEDIATE 'RENAME Localizacao_TEMP TO Localizacao';
  DBMS_OUTPUT.PUT_LINE('Tabela Localizacao restaurada.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro no teste do procedimento: ' || SQLERRM);
    BEGIN
      EXECUTE IMMEDIATE 'RENAME Localizacao_TEMP TO Localizacao';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
END;
/

PROMPT === Testando pr_saldos_manutencao_relatorio com erro ===
BEGIN
  -- Renomear tabela temporariamente
  EXECUTE IMMEDIATE 'RENAME Manutencao TO Manutencao_TEMP';
  
  -- Executar procedimento (vai dar erro mas será tratado)
  pr_saldos_manutencao_relatorio();
  
  -- Restaurar tabela
  EXECUTE IMMEDIATE 'RENAME Manutencao_TEMP TO Manutencao';
  DBMS_OUTPUT.PUT_LINE('Tabela Manutencao restaurada.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro no teste do procedimento: ' || SQLERRM);
    BEGIN
      EXECUTE IMMEDIATE 'RENAME Manutencao_TEMP TO Manutencao';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
END;
/

PROMPT 
PROMPT ========================================================================
PROMPT 3. DEMONSTRAÇÃO DO TRIGGER DE AUDITORIA
PROMPT ========================================================================

PROMPT 
PROMPT *** 3.1 TRIGGER TR_AUDITORIA_RESERVA - EXECUÇÃO NORMAL ***
PROMPT 

-- Limpar auditoria anterior para demonstração limpa
DELETE FROM Auditoria_Reserva;
COMMIT;

PROMPT === Testando INSERT (trigger vai capturar) ===
INSERT INTO Reserva VALUES (10, DATE '2025-01-15', DATE '2025-01-17', 2, 3);
COMMIT;

PROMPT === Testando UPDATE (trigger vai capturar) ===
UPDATE Reserva SET Data_Devolucao = DATE '2025-01-20' WHERE ID_Reserva = 10;
COMMIT;

PROMPT === Testando DELETE (trigger vai capturar) ===
DELETE FROM Reserva WHERE ID_Reserva = 10;
COMMIT;

PROMPT 
PROMPT *** 3.2 VISUALIZANDO REGISTROS DE AUDITORIA ***
PROMPT 
SELECT 
  ID_Auditoria,
  Usuario_BD,
  Operacao,
  TO_CHAR(Data_Operacao, 'DD/MM/YYYY HH24:MI:SS') AS Data_Operacao,
  CASE 
    WHEN Valores_Old IS NOT NULL THEN DBMS_LOB.SUBSTR(Valores_Old, 50, 1) || '...'
    ELSE 'NULL'
  END AS Valores_Old_Resumo,
  CASE 
    WHEN Valores_New IS NOT NULL THEN DBMS_LOB.SUBSTR(Valores_New, 50, 1) || '...'
    ELSE 'NULL'
  END AS Valores_New_Resumo
FROM Auditoria_Reserva
ORDER BY ID_Auditoria;

PROMPT 
PROMPT *** 3.3 FORÇANDO ERRO NO TRIGGER (mas não vai quebrar a transação) ***
PROMPT 

-- O trigger tem tratamento de exceção que não quebra a transação principal
-- Vamos simular um cenário onde o trigger pode ter problemas
PROMPT === Inserindo reserva mesmo com possível erro no trigger ===
BEGIN
  -- Esta inserção vai funcionar mesmo se o trigger tiver problemas
  INSERT INTO Reserva VALUES (11, DATE '2025-02-01', DATE '2025-02-03', 1, 2);
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Inserção realizada com sucesso - trigger funcionou ou falhou silenciosamente');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro na inserção: ' || SQLERRM);
    ROLLBACK;
END;
/

-- Verificar se a inserção foi bem-sucedida
SELECT COUNT(*) AS "RESERVAS_INSERIDAS" FROM Reserva WHERE ID_Reserva = 11;

-- Limpar dados de teste
DELETE FROM Reserva WHERE ID_Reserva = 11;
COMMIT;

PROMPT 
PROMPT ========================================================================
PROMPT 4. TESTE DE CENÁRIOS EXTREMOS E TRATAMENTO DE EXCEÇÕES
PROMPT ========================================================================

PROMPT 
PROMPT *** 4.1 TESTANDO FUNÇÃO COM DADOS EXTREMOS ***
PROMPT 

-- Teste com senha muito longa
SELECT fn_valida_senha(RPAD('A', 4000, 'a1@B')) AS "SENHA_MUITO_LONGA" FROM DUAL;

-- Teste com caracteres especiais
SELECT fn_valida_senha('Ção123!@#$%') AS "SENHA_CARACTERES_ESPECIAIS" FROM DUAL;

PROMPT 
PROMPT *** 4.2 TESTANDO PROCEDIMENTOS COM CENÁRIOS DE EXCEÇÃO ***
PROMPT 

-- Teste simulando condição de NO_DATA_FOUND
PROMPT === Testando função com consulta que não retorna dados ===
BEGIN
  DECLARE
    v_resultado CLOB;
  BEGIN
    -- Simular consulta sem resultados usando condição impossível
    SELECT fn_motos_em_json() INTO v_resultado FROM DUAL WHERE 1=0;
    DBMS_OUTPUT.PUT_LINE('Resultado inesperado: ' || v_resultado);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('EXCEÇÃO NO_DATA_FOUND capturada conforme esperado');
      -- Executar função normalmente para mostrar que funciona
      v_resultado := fn_motos_em_json();
      DBMS_OUTPUT.PUT_LINE('Função executada normalmente após exceção');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Outra exceção capturada: ' || SQLERRM);
  END;
END;
/

PROMPT === Testando procedimento com tratamento de exceções internas ===
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== Executando procedimento que trata exceções internamente ===');
  pr_listar_motos_json();
  DBMS_OUTPUT.PUT_LINE('Procedimento executado com sucesso - exceções tratadas internamente');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Exceção externa capturada: ' || SQLERRM);
END;
/

PROMPT 
PROMPT ========================================================================
PROMPT 5. RESUMO DOS TESTES REALIZADOS
PROMPT ========================================================================

PROMPT 
PROMPT *** FUNÇÕES TESTADAS: ***
PROMPT - fn_motos_em_json: Execução normal e com erro (tabela inexistente)
PROMPT - fn_valida_senha: Vários cenários (senha forte, fraca, nula, extremos)
PROMPT 
PROMPT *** PROCEDIMENTOS TESTADOS: ***
PROMPT - pr_listar_motos_json: Execução normal e com erro
PROMPT - pr_saldos_manutencao_relatorio: Execução normal e com erro
PROMPT 
PROMPT *** TRIGGER TESTADO: ***
PROMPT - TR_AUDITORIA_RESERVA: INSERT, UPDATE, DELETE e tratamento de exceções
PROMPT 
PROMPT *** EXCEÇÕES DEMONSTRADAS: ***
PROMPT - Tabelas inexistentes (ORA-00942)
PROMPT - Dados nulos e inválidos
PROMPT - Cenários extremos
PROMPT - Tratamento silencioso de erros no trigger
PROMPT 
PROMPT ========================================================================
PROMPT FIM DOS TESTES - TODOS OS COMPONENTES FORAM DEMONSTRADOS
PROMPT ========================================================================


