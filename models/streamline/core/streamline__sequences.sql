{{ config (
    materialized = "view",
    tags = ['streamline_view']
) }}

SELECT
    0 AS sequence_number
UNION
SELECT
    _id AS sequence_number
FROM
    {{ source(
        'crosschain_silver',
        'number_sequence'
    ) }}
WHERE
    _id <= (
        SELECT
            MAX(sequence_number)
        FROM
            {{ ref('streamline__chainhead') }}
    )
