{{ config (
    materialized = 'view'
) }}
{{ streamline_external_table_FR_query_v2(
    model = 'messages_with_data_tdl',
    partition_function = "TO_DATE(SPLIT_PART(SPLIT_PART(file_name, '/', 3), '=', 2), 'YYYYMMDD')",
    partition_name = "block_date",
    other_cols = "BODY_BOC,CREATED_LT,INIT_STATE_HASH,OPCODE,TRACE_ID,BOUNCED,BODY_HASH,DIRECTION,TX_LT,TX_HASH,IHR_FEE,INIT_STATE_BOC,CREATED_AT,SOURCE,MSG_HASH,IHR_DISABLED,TX_NOW,BOUNCE,_VALUE,IMPORT_FEE,DESTINATION,COMMENT,FWD_FEE"
) }}
