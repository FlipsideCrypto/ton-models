{{ config (
    materialized = 'view'
) }}
{{ streamline_external_table_FR_query_v2(
    model = 'messages_tdl',
    partition_function = "SPLIT_PART(SPLIT_PART(file_name, '/', 3), '=', 2) ",
    partition_name = "block_date",
    other_cols = "MSG_HASH,IHR_DISABLED,TX_NOW,OPCODE,CREATED_LT,TX_HASH,BOUNCE,BOUNCED,COMMENT,INIT_STATE_HASH,IMPORT_FEE,_VALUE,FWD_FEE,TX_LT,IHR_FEE,SOURCE,TRACE_ID,DIRECTION,BODY_HASH,CREATED_AT,DESTINATION"
) }}
