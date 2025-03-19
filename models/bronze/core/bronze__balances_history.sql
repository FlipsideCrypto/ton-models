{{ config (
    materialized = 'view'
) }}
{{ streamline_external_table_query_v2(
    model = 'balances_history_tdl',
    partition_function = "SPLIT_PART(SPLIT_PART(file_name, '/', 3), '=', 2) ",
    partition_name = "block_date",
    other_cols = "LT,ASSET,ADDRESS,AMOUNT,TIMESTAMP,MINTLESS_CLAIMED"
) }}
