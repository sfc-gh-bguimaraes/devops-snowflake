USE DATABASE DEMO;
USE SCHEMA PUBLIC;

CREATE TABLE clientes (
  id_cliente VARCHAR(20) PRIMARY KEY,
  nome_cliente VARCHAR(200) NOT NULL,
  email_cliente VARCHAR(200),
  telefone_cliente VARCHAR(30),
  documento_cliente VARCHAR(20)
);