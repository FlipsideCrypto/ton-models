{{ config (
    materialized = 'view'
) }}
{{ streamline_external_table_FR_query_v2(
    model = 'jetton_events_tdl',
    partition_function = "TO_DATE(SPLIT_PART(SPLIT_PART(file_name, '/', 3), '=', 2), 'YYYYMMDD')",
    partition_name = "block_date",
    other_cols = "TX_HASH,TYPE,JETTON_MASTER,JETTON_WALLET,COMMENT,FORWARD_TON_AMOUNT,AMOUNT,UTIME,TX_LT,SOURCE,TX_ABORTED,QUERY_ID,DESTINATION"
) }}
