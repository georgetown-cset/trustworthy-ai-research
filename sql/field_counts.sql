WITH
  --get AI pubs
  ai_pubs AS(
  SELECT
    cset_id AS merged_id,
    year
  FROM
    `article_classification.predictions_2023_01_19`
  WHERE
    ai_filtered IS TRUE),
  --get trustworthy pubs
  trustworthy_pubs AS(
  SELECT
    merged_id,
    title_english,
    abstract_english,
    year,
    fields
  FROM
    gcp_cset_links_v2.corpus_merged
  INNER JOIN
    ai_pubs
  USING
    (merged_id,
      year)
  INNER JOIN
    `fields_of_study_v2.top_fields`
  USING
    (merged_id)
  WHERE
    year >= 2010
    AND year <=2021
    AND (trusted_ml_research.trustworthy_keywords(LOWER(title_english))
      OR trusted_ml_research.trustworthy_keywords(LOWER(abstract_english))))
SELECT
  COUNT(DISTINCT merged_id) AS paper_count,
  f.name
FROM
  fields_of_study_v2.top_fields
CROSS JOIN
  UNNEST(fields) AS f
WHERE
  f.level =1 --get level 1 fields only
GROUP BY
  f.name
ORDER BY
  paper_count DESC
