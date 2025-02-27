{{ config (
    materialized = "view",
    tags = ['streamline_view']
) }}

SELECT
    {{ target.database }}.live.udf_api(
        'GET',
        '{Service}/{Authentication}/getMasterchainInfo',
        OBJECT_CONSTRUCT(
            'Content-Type',
            'application/json',
            'fsc-quantum-state',
            'livequery'
        ),
        OBJECT_CONSTRUCT(),
        'Vault/prod/ton/quicknode/mainnet'
    ) :data: "result" :"last" :"seqno" AS sequence_number
