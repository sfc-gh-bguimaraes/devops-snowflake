USE ROLE ACCOUNTADMIN;
USE DATABASE DEMO_DB;
USE SCHEMA OPS;

-- 1) Network Rule para acesso externo (Google APIs)
CREATE OR REPLACE NETWORK RULE NR_GSHEETS
  MODE=EGRESS
  TYPE=HOST_PORT
  VALUE_LIST=('www.googleapis.com:443','oauth2.googleapis.com:443');

-- 2) Secret para credenciais (Service Account JSON base64)
-- Crie o secret com o conteúdo do JSON codificado em BASE64
CREATE OR REPLACE SECRET SECRET_GSHEETS
  TYPE=GENERIC_STRING
  SECRET_STRING='<BASE64_SERVICE_ACCOUNT_JSON>';

-- 3) External Access Integration
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION EAI_GSHEETS
  ALLOWED_NETWORK_RULES=(NR_GSHEETS)
  ALLOWED_AUTHENTICATION_SECRETS=(SECRET_GSHEETS)
  ENABLED=TRUE;

-- 4) Procedure Python para ler GSheets e carregar tabela RAW
USE SCHEMA DEMO_DB.RAW;
CREATE OR REPLACE TABLE GSHEET_CUSTOMERS_RAW (
  ID STRING,
  NAME STRING,
  EMAIL STRING,
  COUNTRY STRING,
  UPDATED_AT TIMESTAMP_NTZ
);

CREATE OR REPLACE PROCEDURE OPS.INGEST_GSHEET_CUSTOMERS(
  SHEET_ID STRING,
  RANGE_A1 STRING
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION='3.10'
PACKAGES=('snowflake-snowpark-python','requests','google-auth','google-auth-httplib2','google-api-python-client','pandas')
EXTERNAL_ACCESS_INTEGRATIONS=(OPS.EAI_GSHEETS)
SECRETS=(service_account=OPS.SECRET_GSHEETS)
HANDLER='main'
AS
$$
import base64
import json
import pandas
from datetime import datetime
from google.oauth2 import service_account
from googleapiclient.discovery import build

def main(snow_ctx, SHEET_ID, RANGE_A1):
    secret_b64 = snow_ctx.get_secret('service_account')
    sa_json = json.loads(base64.b64decode(secret_b64).decode('utf-8'))

    creds = service_account.Credentials.from_service_account_info(sa_json, scopes=[
        'https://www.googleapis.com/auth/spreadsheets.readonly'
    ])
    service = build('sheets', 'v4', credentials=creds)
    sheet = service.spreadsheets()
    result = sheet.values().get(spreadsheetId=SHEET_ID, range=RANGE_A1).execute()
    values = result.get('values', [])

    if not values:
        return 'No data found.'

    header = [h.strip().lower() for h in values[0]]
    col_idx = {name: idx for idx, name in enumerate(header)}

    to_insert = []
    for row in values[1:]:
        def get(name):
            idx = col_idx.get(name, None)
            return row[idx] if idx is not None and idx < len(row) else None
        to_insert.append((
            get('id'),
            get('name'),
            get('email'),
            get('country'),
            datetime.utcnow().isoformat()
        ))

    import snowflake.snowpark as snowpark
    session = snowpark.Session.builder.getOrCreate()
    df = pandas.DataFrame(to_insert, columns=['ID','NAME','EMAIL','COUNTRY','UPDATED_AT'])
    session.write_pandas(df, 'GSHEET_CUSTOMERS_RAW', auto_create_table=False)
    return f'Inserted {len(to_insert)} rows.'
$$;

-- Execução:
-- CALL OPS.INGEST_GSHEET_CUSTOMERS('<SHEET_ID>', 'A1:D1000');
