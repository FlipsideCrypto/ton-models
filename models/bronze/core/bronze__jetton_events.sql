{{ config (
    materialized = 'view'
) }}
{{ streamline_external_table_query_v2(
    model = 'jetton_events_tdl',
    partition_function = "SPLIT_PART(SPLIT_PART(file_name, '/', 3), '=', 2) ",
    partition_name = "block_date",
    other_cols = "TX_HASH,TYPE,JETTON,COMMENT,FORWARD_TON_AMOUNT,AMOUNT,UTIME,TX_LT,SOURCE,TX_ABORTED,QUERY_ID,DESTINATION"
) }}
