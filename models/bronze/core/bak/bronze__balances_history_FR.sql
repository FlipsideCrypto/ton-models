{{ config (
    materialized = 'view'
) }}
{{ streamline_external_table_FR_query_v2(
    model = 'balances_history_tdl',
    partition_function = "TO_DATE(SPLIT_PART(SPLIT_PART(file_name, '/', 3), '=', 2), 'YYYYMMDD')",
    partition_name = "block_date",
    other_cols = "LT,ASSET,ADDRESS,AMOUNT,TIMESTAMP,MINTLESS_CLAIMED"
) }}
