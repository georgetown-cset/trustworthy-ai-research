WITH
  ai_pubs AS(
  SELECT
    cset_id AS merged_id
  FROM
    `article_classification.predictions_2023_01_19`
  WHERE
    ai_filtered IS TRUE),
  trustworthy_pubs AS(
  SELECT
    merged_id,
    title_english,
    abstract_english,
    title_foreign,
    abstract_foreign,
    year,
    doctype,
    source_title
  FROM
    gcp_cset_links_v2.corpus_merged
  INNER JOIN
    ai_pubs
  USING
    (merged_id)
  WHERE
    trusted_ml_research.trustworthy_keywords(LOWER(title_english))
    OR trusted_ml_research.trustworthy_keywords(LOWER(abstract_english)))
SELECT
  *
FROM
  trustworthy_pubs
WHERE
  year >= 2010
  AND year <= 2021
