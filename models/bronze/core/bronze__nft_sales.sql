{{ config (
    materialized = 'view'
) }}
{{ streamline_external_table_query_v2(
    model = 'nft_sales_tdl',
    partition_function = "SPLIT_PART(SPLIT_PART(file_name, '/', 3), '=', 2) ",
    partition_name = "block_date",
    other_cols = "IS_CANCELED,MARKETPLACE_FEE_ADDRESS,END_TIME,IS_COMPLETE,LAST_MEMBER,MARKETPLACE_ADDRESS,ROYALTY_AMOUNT,CREATED_AT,NFT_ADDRESS,MARKETPLACE_FEE,ASSET,PRICE,NFT_OWNER_ADDRESS,ADDRESS,MIN_BID,TIMESTAMP,ROYALTY_ADDRESS,MIN_STEP,MAX_BID,LAST_BID_AT,LT,TYPE"
) }}
