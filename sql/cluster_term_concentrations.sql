WITH
  --get trustworthy corpus
  ai_pubs AS(
  SELECT
    cset_id AS merged_id,
    year
  FROM
    `article_classification.predictions_2023_01_19`
  WHERE
    ai_filtered IS TRUE),
  trustworthy_pubs AS(
  SELECT
    merged_id,
    title_english,
    abstract_english,
    year,
    doctype,
    source_title,
    cluster_id,
    NP_all_years
  FROM
    gcp_cset_links_v2.corpus_merged
  INNER JOIN
    ai_pubs
  USING
    (merged_id,
      year)
  INNER JOIN
    `science_map_v2.dc5_cluster_assignment_stable`
  USING
    (merged_id)
  INNER JOIN
    `science_map_v2.dc5_cluster_description_stable`
  USING
    (cluster_id)
  WHERE
    year >= 2010
    AND year <=2021
    AND (trusted_ml_research.trustworthy_keywords(LOWER(title_english))
      OR trusted_ml_research.trustworthy_keywords(LOWER(abstract_english)))),
  
  --get term counts by cluster and year
  term_counts AS(
  SELECT
    merged_id,
    year,
    cluster_id,
    NP_all_years,
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
--get the number of papers by keyword, the percentages of keyword papers, and label if the concentration is greater than or equal to 10%
SELECT
  SUM(trust) AS Trust,
  SUM(trust)/NP_all_years AS Trust_pct,
  SUM(explainable) AS Explainability,
  SUM(explainable)/NP_all_years AS Explainability_pct,
  SUM(robustness) AS Robustness,
  SUM(robustness)/NP_all_years AS Robustness_pct,
  SUM(security) AS Security,
  SUM(security)/NP_all_years AS Security_pct,
  SUM(resilience) AS Resiliency,
  SUM(resilience)/NP_all_years AS Resiliency_pct,
  SUM(interpretability) AS Interpretability,
  SUM(interpretability)/NP_all_years AS Interpretability_pct,
  SUM(privacy) AS Privacy,
  SUM(privacy)/NP_all_years AS Privacy_pct,
  SUM(safety) AS Safety,
  SUM(safety)/NP_all_years AS safety_pct,
  SUM(bias) AS Bias,
  SUM(bias)/NP_all_years AS Bias_pct,
  SUM(fairness) AS Fairness,
  SUM(fairness)/NP_all_years AS Fairness_pct,
  SUM(accountability) AS Accountability,
  SUM(accountability)/NP_all_years AS accountability_pct,
  SUM(transparency) AS Transparency,
  SUM(transparency)/NP_all_years AS Transparency_pct,
  SUM(reliability) AS Reliability,
  SUM(reliability)/NP_all_years AS Reliability_pct,
  CASE
    WHEN SUM(accountability)/NP_all_years >= 0.1 THEN 1
  ELSE
  0
END
  AS is_accountability,
  CASE
    WHEN SUM(bias)/NP_all_years >= 0.1 THEN 1
  ELSE
  0
END
  AS is_bias,
  CASE
    WHEN SUM(fairness)/NP_all_years >= 0.1 THEN 1
  ELSE
  0
END
  AS is_fairness,
  CASE
    WHEN SUM(explainable)/NP_all_years >= 0.1 THEN 1
  ELSE
  0
END
  AS is_explainable,
  CASE
    WHEN SUM(interpretability)/NP_all_years >= 0.1 THEN 1
  ELSE
  0
END
  AS is_interpretable,
  CASE
    WHEN SUM(transparency)/NP_all_years >= 0.1 THEN 1
  ELSE
  0
END
  AS is_transparency,
  CASE
    WHEN SUM(safety)/NP_all_years >= 0.1 THEN 1
  ELSE
  0
END
  AS is_safety,
  CASE
    WHEN SUM(privacy)/NP_all_years >= 0.1 THEN 1
  ELSE
  0
END
  AS is_privacy,
  CASE
    WHEN SUM(trust)/NP_all_years >= 0.1 THEN 1
  ELSE
  0
END
  AS is_trust,
  CASE
    WHEN SUM(resilience)/NP_all_years >= 0.1 THEN 1
  ELSE
  0
END
  AS is_resilience,
  CASE
    WHEN SUM(reliability)/NP_all_years >= 0.1 THEN 1
  ELSE
  0
END
  AS is_reliable,
  CASE
    WHEN SUM(robustness)/NP_all_years >= 0.1 THEN 1
  ELSE
  0
END
  AS is_robustness,
  CASE
    WHEN SUM(security)/NP_all_years >= 0.1 THEN 1
  ELSE
  0
END
  AS is_security,
  cluster_id,
FROM
  term_counts
GROUP BY
  cluster_id,
  NP_all_years
