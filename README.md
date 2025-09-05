# Snowflake Demo Completo (FinOps, Ingestão, Armazenamento, Consumo, Arquitetura, Streaming, CI/CD, Data Quality, Governança e Segurança)

Este demo cobre ponta a ponta:
- FinOps (warehouses, resource monitor, visões de custo)
- Ingestão (S3/Snowpipe, GSheets via External Access; notas para SFTP/Drive e conectores SQL Server/MySQL)
- Armazenamento (stages internos/externos, formatos)
- Arquitetura (camadas RAW/STAGE/CURATED/OPS), Streams + Tasks
- Consumo (views seguras, procedures e schedules; integração com BI)
- Streaming (visão operacional com Streams/Tasks; notas Snowpipe Streaming/Kafka)
- CI/CD (schemachange e Snowflake CLI)
- Data Quality (regras e scheduler)
- Governança e Segurança (roles, grants, masking/row policies, tags, network policy)

## Pré-requisitos
- Papel com privilégios para criar integrações, warehouses, databases e políticas (ex.: `ACCOUNTADMIN`).
- (Opcional) Acesso a um bucket S3 e permissões para configurar notificações (S3 Event → SNS → SQS) para Snowpipe.
- (Opcional) Credenciais de Service Account do Google com acesso ao Google Sheets (para ingestão via API).
- SnowSQL ou Worksheets do Snowsight para executar os scripts `.sql`.

## Como executar
Execute os scripts na ordem sugerida:
1. `01_finops_and_wh_setup.sql`
2. `02_storage_and_stages.sql`
3. `03_ingestion_snowpipe_s3.sql`
4. `03b_ingestion_gsheets_external_access.sql` (opcional)
5. `04_modeling_layers.sql`
6. `05_consumption_tasks_bi.sql`
7. `06_streaming_streams_tasks.sql`
8. `07_data_quality.sql`
9. `08_governance_security.sql`
10. `09_cicd/README.md` (instruções CI/CD)

Ajuste os placeholders marcados com <> conforme seu ambiente (ARNs, nomes de buckets, IDs, IPs, etc.).

## Observações sobre conectores
- SQL Server/MySQL: recomenda-se usar Partner Connect (ex.: Fivetran/Matillion) ou Snowflake Connector para Kafka/DBT/Spark. Este demo foca no caminho nativo (stages + Snowpipe) para dados em arquivos e API via External Access.
- SFTP/Google Drive: use conector/ETL para mover até S3/GCS e então ingerir por stages/Snowpipe. Alternativamente, implemente External Access + procedure para baixar e carregar (fora do escopo básico deste demo).

## Integração com BI (Power BI e outros)
- Power BI: use o conector nativo Snowflake (ODBC) apontando para o warehouse e database criados. Publique relatórios agendando refresh conforme necessário.
- Outros (Tableau/Looker/Superset): conecte via drivers nativos e privilégios de leitura nas views/tables em `CURATED`.

## Limpeza (opcional)
Ao finalizar, você pode remover objetos criados (roles, warehouses, databases, integrações e políticas) conforme a sua política interna.
