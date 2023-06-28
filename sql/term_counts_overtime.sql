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
    title_english,
    abstract_english,
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
  term_counts AS(
  SELECT
    merged_id,
    year,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(title_english),"trust") OR REGEXP_CONTAINS(LOWER(abstract_english), "trust") THEN 1
    ELSE
    0
  END
    AS trust,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(title_english),"explainable") OR REGEXP_CONTAINS(LOWER(abstract_english), "explainable") OR REGEXP_CONTAINS(LOWER(title_english),"explainability") OR REGEXP_CONTAINS(LOWER(abstract_english), "explainability") THEN 1
    ELSE
    0
  END
    AS explainable,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(title_english),"robustness") OR REGEXP_CONTAINS(LOWER(abstract_english), "robustness")THEN 1
    ELSE
    0
  END
    AS robustness,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(title_english),"reliability") OR REGEXP_CONTAINS(LOWER(abstract_english), "reliability") OR REGEXP_CONTAINS(LOWER(title_english),"reliable") OR REGEXP_CONTAINS(LOWER(abstract_english), "reliable") THEN 1
    ELSE
    0
  END
    AS reliability,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(title_english),"security") OR REGEXP_CONTAINS(LOWER(abstract_english), "security") THEN 1
    ELSE
    0
  END
    AS security,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(title_english),"resilience") OR REGEXP_CONTAINS(LOWER(abstract_english), "resilience") THEN 1
    ELSE
    0
  END
    AS resilience,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(title_english),"interpretability") OR REGEXP_CONTAINS(LOWER(abstract_english), "interpretability") OR REGEXP_CONTAINS(LOWER(title_english),"interpretable") OR REGEXP_CONTAINS(LOWER(abstract_english), "interpretable") THEN 1
    ELSE
    0
  END
    AS interpretability,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(title_english),"privacy") OR REGEXP_CONTAINS(LOWER(abstract_english), "privacy") THEN 1
    ELSE
    0
  END
    AS privacy,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(title_english),"safety") OR REGEXP_CONTAINS(LOWER(abstract_english), "safety") THEN 1
    ELSE
    0
  END
    AS safety,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(title_english),"bias") OR REGEXP_CONTAINS(LOWER(abstract_english), "bias") THEN 1
    ELSE
    0
  END
    AS bias,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(title_english),"fairness") OR REGEXP_CONTAINS(LOWER(abstract_english), "fairness") THEN 1
    ELSE
    0
  END
    AS fairness,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(title_english),"accountability") OR REGEXP_CONTAINS(LOWER(abstract_english), "accountability") OR REGEXP_CONTAINS(LOWER(title_english),"accountable") OR REGEXP_CONTAINS(LOWER(abstract_english), "accountable") THEN 1
    ELSE
    0
  END
    AS accountability,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(title_english),"transparency") OR REGEXP_CONTAINS(LOWER(abstract_english), "transparency") THEN 1
    ELSE
    0
  END
    AS transparency
  FROM
    trustworthy_pubs)
SELECT
  SUM(trust) AS Trust,
  SUM(explainable) AS Explainability,
  SUM(robustness) AS Robustness,
  SUM(security) AS Security,
  SUM(resilience) AS Resiliency,
  SUM(interpretability) AS Interpretability,
  SUM(privacy) AS Privacy,
  SUM(safety) AS Safety,
  SUM(bias) AS Bias,
  SUM(fairness) AS Fairness,
  SUM(accountability) AS Accountability,
  SUM(transparency) AS Transparency,
  SUM(reliability) AS Reliability,
  year
FROM
  term_counts
WHERE
  year >= 2010
  AND year <=2021
GROUP BY
  year
