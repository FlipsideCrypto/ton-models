-- depends_on: {{ ref('bronze__shards') }}
-- depends_on: {{ ref('bronze__shards_FR') }}
{{ config (
    materialized = "incremental",
    unique_key = 'sequence_number',
    merge_exclude_columns = ["inserted_timestamp"],
    cluster_by = "ROUND(sequence_number, -5)",
    tags = ['streamline_realtime'],
    enabled = false
) }}

SELECT
    sequence_number AS sequence_number,
    partition_key,
    DATA :result :shards AS shards,
    _inserted_timestamp,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id,
FROM

{% if is_incremental() %}
{{ ref('bronze__shards') }}
{% else %}
    {{ ref('bronze__shards_FR') }}
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
        PARTITION BY sequence_number
        ORDER BY
            _inserted_timestamp DESC
    ) = 1
