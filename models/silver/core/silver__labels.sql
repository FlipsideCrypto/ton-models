{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    unique_key = 'blockchain',
    tags = ['scheduled_core'],
) }}

WITH pre_final AS (

    SELECT
        DATA,
        _inserted_timestamp
    FROM
        {{ ref('bronze_api__labels') }}

{% if is_incremental() %}
WHERE
    _inserted_timestamp >= (
        SELECT
            MAX(_inserted_timestamp)
        FROM
            {{ this }}
    )
{% endif %}

qualify RANK() over (
    ORDER BY
        _inserted_timestamp DESC
) = 1
)
SELECT
    'ton' AS blockchain,
    DATA :address :: STRING AS address,
    DATA :category :: STRING AS category,
    DATA :subcategory :: STRING AS subcategory,
    DATA :label :: STRING AS label,
    DATA :name :: STRING AS NAME,
    DATA :organization :: STRING AS ORGANIZATION,
    DATA :submissionTimestamp :: datetime AS submissionTimestamp,
    DATA :submittedBy :: STRING AS submittedBy,
    DATA :source :: STRING AS source,
    DATA :tags AS tags,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['address']
    ) }} AS labels_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    pre_final
