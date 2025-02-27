-- depends_on: {{ ref('bronze__blocks') }}
-- depends_on: {{ ref('bronze__blocks_FR') }}
{{ config (
    materialized = "incremental",
    unique_key = ['sequence_number','shard','workchain'],
    merge_exclude_columns = ["inserted_timestamp"],
    cluster_by = "ROUND(sequence_number, -5)",
    tags = ['streamline_realtime']
) }}

SELECT
    sequence_number,
    shard,
    workchain,
    partition_key,
    _inserted_timestamp,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    file_name,
    '{{ invocation_id }}' AS _invocation_id,
FROM

{% if is_incremental() %}
{{ ref('bronze__blocks') }}
{% else %}
    {{ ref('bronze__blocks_FR') }}
{% endif %}
WHERE
    DATA :ok = TRUE

{% if is_incremental() %}
AND _inserted_timestamp >= (
    SELECT
        COALESCE(MAX(_INSERTED_TIMESTAMP), '1970-01-01' :: DATE) max_INSERTED_TIMESTAMP
    FROM
        {{ this }})
        AND DATA IS NOT NULL
    {% endif %}

    qualify ROW_NUMBER() over (
        PARTITION BY sequence_number,
        shard,
        workchain
        ORDER BY
            _inserted_timestamp DESC
    ) = 1
