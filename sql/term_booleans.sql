--get term mentions for each publication 
WITH term_counts AS(SELECT merged_id, year,
CASE WHEN REGEXP_CONTAINS(LOWER(title_english),"trust") OR REGEXP_CONTAINS(LOWER(abstract_english), "trust") THEN 1 ELSE 0 END AS trust,
CASE WHEN REGEXP_CONTAINS(LOWER(title_english),"explainable") OR REGEXP_CONTAINS(LOWER(abstract_english), "explainable") OR REGEXP_CONTAINS(LOWER(title_english),"explainability") OR REGEXP_CONTAINS(LOWER(abstract_english), "explainability") THEN 1 ELSE 0 END AS explainable,
CASE WHEN REGEXP_CONTAINS(LOWER(title_english),"robustness") OR REGEXP_CONTAINS(LOWER(abstract_english), "robustness")THEN 1 ELSE 0 END AS robustness,
CASE WHEN REGEXP_CONTAINS(LOWER(title_english),"reliability") OR REGEXP_CONTAINS(LOWER(abstract_english), "reliability") OR REGEXP_CONTAINS(LOWER(title_english),"reliable") OR REGEXP_CONTAINS(LOWER(abstract_english), "reliable") THEN 1 ELSE 0 END AS reliability,
CASE WHEN REGEXP_CONTAINS(LOWER(title_english),"security") OR REGEXP_CONTAINS(LOWER(abstract_english), "security") THEN 1 ELSE 0 END AS security,
CASE WHEN REGEXP_CONTAINS(LOWER(title_english),"resilience") OR REGEXP_CONTAINS(LOWER(abstract_english), "resilience") THEN 1 ELSE 0 END AS resilience,
CASE WHEN REGEXP_CONTAINS(LOWER(title_english),"interpretability") OR REGEXP_CONTAINS(LOWER(abstract_english), "interpretability") OR REGEXP_CONTAINS(LOWER(title_english),"interpretable") OR REGEXP_CONTAINS(LOWER(abstract_english), "interpretable") THEN 1 ELSE 0 END AS interpretability,
CASE WHEN REGEXP_CONTAINS(LOWER(title_english),"privacy") OR REGEXP_CONTAINS(LOWER(abstract_english), "privacy") THEN 1 ELSE 0 END AS privacy,
CASE WHEN REGEXP_CONTAINS(LOWER(title_english),"safety") OR REGEXP_CONTAINS(LOWER(abstract_english), "safety") THEN 1 ELSE 0 END AS safety,
CASE WHEN REGEXP_CONTAINS(LOWER(title_english),"bias") OR REGEXP_CONTAINS(LOWER(abstract_english), "bias") THEN 1 ELSE 0 END AS bias,
CASE WHEN REGEXP_CONTAINS(LOWER(title_english),"fairness") OR REGEXP_CONTAINS(LOWER(abstract_english), "fairness") THEN 1 ELSE 0 END AS fairness,
CASE WHEN REGEXP_CONTAINS(LOWER(title_english),"accountability") OR REGEXP_CONTAINS(LOWER(abstract_english), "accountability") THEN 1 ELSE 0 END AS accountability,
CASE WHEN REGEXP_CONTAINS(LOWER(title_english),"transparency") OR REGEXP_CONTAINS(LOWER(abstract_english), "transparency") THEN 1 ELSE 0 END AS transparency
FROM trusted_ml_research.trustworthy_ai_papers_0927
WHERE year >= 2010 AND year <=2021),

--get china affiliation for each publication 
chn_label AS(SELECT merged_id, CASE WHEN country = "China" THEN 1 ELSE 0 end as chn_affil FROM trusted_ml_research.trustworthy_ai_papers_0927
INNER JOIN gcp_cset_links_v2.paper_countries_merged USING(merged_id))


SELECT * FROM term_counts
LEFT JOIN chn_label USING(merged_id)
