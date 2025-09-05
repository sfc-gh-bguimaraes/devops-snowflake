# CI/CD para Snowflake (schemachange + Snowflake CLI)

## Opção 1: schemachange
- Instale: `pip install schemachange`
- Estruture migrações (ex.: `snowflake_demo/migrations/V1__init.sql`, `V2__modeling.sql` ...)
- Parâmetros principais:
  - `--snowflake-account`, `--snowflake-user`, `--modules-folder`, `--change-history-table`.
- Execução local de exemplo:
```bash
schemachange --snowflake-account <account> --snowflake-user <user> \
  --modules-folder snowflake_demo/migrations \
  --change-history-table DEMO_DB.OPS.SCHEMACHANGE_HISTORY \
  --create-change-history-table
```
- Em pipelines (GitHub Actions/GitLab): use secrets e execute o mesmo comando nos PRs/main.

## Opção 2: Snowflake CLI (preview)
- Instale: `pip install snowflake-cli-labs`
- Configure `snowflake.yml` com ambientes (dev/prod) e comandos para `snow sql -f`.
- Exemplo:
```yaml
connections:
  dev:
    account: <account>
    user: <user>
    role: ACCOUNTADMIN
    warehouse: WH_ETL
    database: DEMO_DB
    schema: OPS
tasks:
  init: snow sql -f snowflake_demo/01_finops_and_wh_setup.sql
  storage: snow sql -f snowflake_demo/02_storage_and_stages.sql
```

## Boas práticas
- Versione todos os `.sql` de DDL/DML.
- Use `ACCOUNT_USAGE` para auditoria de alterações.
- Promova via branches e variáveis de ambiente.
- Aplique revisões obrigatórias para objetos sensíveis (policies, grants).
