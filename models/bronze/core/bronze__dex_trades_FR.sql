{{ config (
    materialized = 'view'
) }}
{{ streamline_external_table_FR_query_v2(
    model = 'dex_trades_tdl',
    partition_function = "SPLIT_PART(SPLIT_PART(file_name, '/', 3), '=', 2) ",
    partition_name = "block_date",
    other_cols = "VOLUME_TON,REFERRAL_ADDRESS,TOKEN_BOUGHT_ADDRESS,POOL_ADDRESS,PROJECT_TYPE,AMOUNT_BOUGHT_RAW,ROUTER_ADDRESS,VERSION,TRACE_ID,VOLUME_USD,TOKEN_SOLD_ADDRESS,PROJECT,EVENT_TIME,TX_HASH,TRADER_ADDRESS,EVENT_TYPE,AMOUNT_SOLD_RAW,PLATFORM_TAG,QUERY_ID"
) }}
