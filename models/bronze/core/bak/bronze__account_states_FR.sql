{{ config (
    materialized = 'view'
) }}
{{ streamline_external_table_FR_query_v2(
    model = 'account_states_tdl',
    partition_function = "TO_DATE(SPLIT_PART(SPLIT_PART(file_name, '/', 3), '=', 2), 'YYYYMMDD')",
    partition_name = "block_date",
    other_cols = "ACCOUNT,LAST_TRANS_LT,LAST_TRANS_HASH,ACCOUNT_STATUS,BALANCE,DATA_BOC,DATA_HASH,FROZEN_HASH,TIMESTAMP,CODE_HASH,CODE_BOC,HASH"
) }}
