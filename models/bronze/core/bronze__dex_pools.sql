{{ config (
    materialized = 'view'
) }}
{{ streamline_external_table_FR_query_v2(
    model = 'dex_pools_tdl',
    partition_function = "TO_DATE(SPLIT_PART(SPLIT_PART(file_name, '/', 3), '=', 2), 'YYYYMMDD')",
    partition_name = "block_date",
    other_cols = "RESERVES_RIGHT,PROJECT,POOL,PROTOCOL_FEE,LAST_UPDATED,DISCOVERED_AT,VERSION,JETTON_RIGHT,TVL_TON,JETTON_LEFT,RESERVES_LEFT,REFERRAL_FEE,IS_LIQUID,TOTAL_SUPPLY,TVL_USD,LP_FEE"
) }}
