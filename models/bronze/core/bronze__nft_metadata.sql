{{ config (
    materialized = 'view'
) }}
{{ streamline_external_table_FR_query_v2(
    model = 'nft_metadata_tdl',
    partition_function = "TO_DATE(SPLIT_PART(SPLIT_PART(file_name, '/', 3), '=', 2), 'YYYYMMDD')",
    partition_name = "adding_date",
    other_cols = "DESCRIPTION,IMAGE,METADATA_STATUS,PARENT_ADDRESS,UPDATE_TIME_METADATA,ADDING_AT,UPDATE_TIME_ONCHAIN,ADDRESS,TONAPI_IMAGE_URL,CONTENT_ONCHAIN,TYPE,ATTRIBUTES,NAME,SOURCES,IMAGE_DATA"
) }}
