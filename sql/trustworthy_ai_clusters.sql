WITH ai_pubs AS(SELECT cset_id as merged_id, year FROM `article_classification.predictions_2023_01_19` 
WHERE ai_filtered is true),

trustworthy_pubs AS(SELECT merged_id, title_english, abstract_english, title_foreign, abstract_foreign, year, doctype, source_title FROM gcp_cset_links_v2.corpus_merged
INNER JOIN ai_pubs USING(merged_id, year)
WHERE trusted_ml_research.trustworthy_keywords(LOWER(title_english)) OR trusted_ml_research.trustworthy_keywords(LOWER(abstract_english))),

  clusters AS(
  SELECT
    cluster_id,
    COUNT(DISTINCT merged_id) AS related_count
  FROM
    science_map_v2.dc5_cluster_assignment_stable
  INNER JOIN
    trustworthy_pubs
  USING
    (merged_id)
  GROUP BY
    cluster_id)
 
 
 --select fields for RCs of interest (select * for all fields or adjust fields here based on what you want)
SELECT
  cluster_id,
  link,
  class_art,
  level0_mag,
  level1_mag,
  top_country,
  US_rank,
  ai_pred,
  cset_extracted_phrase,
  NP_last_5_years,
  NP_all_years,
  growth_3yr,
  growth_1yr,
  avg_citations,
  related_count,
  related_count/NP_all_years AS percent_related --computes the percentage of papers in the RC that are "papers of interest"
FROM
  science_map_v2.dc5_cluster_description_stable
INNER JOIN
  clusters
USING
  (cluster_id)
  ORDER BY percent_related DESC
  LIMIT 50
