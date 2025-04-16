{{ config(
    materialized = 'incremental',
    unique_key = ['blockchain'],
    incremental_strategy = 'delete+insert',
    tags = ['scheduled_core']
) }}

SELECT
    address,
    category,
    subcategory,
    label,
    NAME,
    ORGANIZATION,
    submissionTimestamp,
    submittedBy,
    source,
    tags,
    labels_id AS dim_labels_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__labels') }}
