{{ config (
    materialized = 'view'
) }}
{{ streamline_external_table_FR_query_v2(
    model = 'nft_transfers_tdl',
    partition_function = "SPLIT_PART(SPLIT_PART(file_name, '/', 3), '=', 2) ",
    partition_name = "block_date",
    other_cols = "TRACE_ID,TX_NOW,CUSTOM_PAYLOAD,NEW_OWNER,FORWARD_PAYLOAD,COMMENT,OLD_OWNER,TX_ABORTED,QUERY_ID,TX_HASH,TX_LT,RESPONSE_DESTINATION,NFT_COLLECTION_ADDRESS,FORWARD_AMOUNT,NFT_ITEM_ADDRESS,NFT_ITEM_INDEX"
) }}
