{{ config (
    materialized = 'view'
) }}
{{ streamline_external_table_FR_query_v2(
    model = 'jetton_metadata_tdl',
    partition_function = "TO_DATE(SPLIT_PART(SPLIT_PART(file_name, '/', 3), '=', 2), 'YYYYMMDD')",
    partition_name = "adding_date",
    other_cols = "TONAPI_IMAGE_URL,IMAGE_DATA,IMAGE,UPDATE_TIME_ONCHAIN,SYMBOL,JETTON_CONTENT_ONCHAIN,UPDATE_TIME_METADATA,NAME,JETTON_WALLET_CODE_HASH,CODE_HASH,ADMIN_ADDRESS,ADDING_AT,ADDRESS,SOURCES,MINTABLE,DECIMALS,METADATA_STATUS,DESCRIPTION"
) }}
