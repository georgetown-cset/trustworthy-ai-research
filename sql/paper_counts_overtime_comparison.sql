WITH
  --get AI pubs
  ai_pubs AS(
  SELECT
    cset_id AS merged_id,
    year
  FROM
    `article_classification.predictions_2023_01_19`
  WHERE
    ai_filtered IS TRUE
    AND year >= 2010
    AND year <= 2021),
  --get Trustworthy AI papers
  trustworthy_pubs AS(
  SELECT
    merged_id,
    year
  FROM
    gcp_cset_links_v2.corpus_merged
  INNER JOIN
    ai_pubs
  USING
    (merged_id,
      year)
  WHERE
    year >= 2010
    AND year <=2021
    AND (trusted_ml_research.trustworthy_keywords(LOWER(title_english))
      OR trusted_ml_research.trustworthy_keywords(LOWER(abstract_english)))),
  ai_counts AS(
  SELECT
    COUNT(DISTINCT merged_id) AS n_ai,
    year
  FROM
    ai_pubs
  GROUP BY
    year),
  trustworthy_counts AS(
  SELECT
    COUNT(DISTINCT merged_id) AS n_trust,
    year
  FROM
    trustworthy_pubs
  GROUP BY
    year)
SELECT
  *
FROM
  ai_counts
JOIN
  trustworthy_counts
USING
  (year)




  
