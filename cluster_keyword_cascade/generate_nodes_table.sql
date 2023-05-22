
--saved as trusted_ml_research.trust_node_table_040323 

WITH
ai_pubs AS(SELECT cset_id as merged_id, year FROM `article_classification.predictions_2023_01_19` 
--INNER JOIN gcp_cset_links_v2.corpus_merged corpus ON cset_id = merged_id
WHERE ai_filtered is true),

keyword_papers AS(SELECT merged_id, title_english, abstract_english, title_foreign, abstract_foreign, year, doctype, source_title FROM gcp_cset_links_v2.corpus_merged
INNER JOIN ai_pubs USING(merged_id, year)
WHERE year >= 2010 AND year <= 2021 AND (trusted_ml_research.trustworthy_keywords(LOWER(title_english)) OR trusted_ml_research.trustworthy_keywords(LOWER(abstract_english)))),

  papers_to_clusters AS(
  SELECT
    *
  FROM
    keyword_papers
  INNER JOIN
    science_map_v2.dc5_cluster_assignment_stable
  USING
    (merged_id)),
  
  --Select the RCs to plot here by highest concentration of keyword papers 
  select_rcs AS(
  SELECT
    COUNT(DISTINCT rc_table.merged_id) AS total_np,
    cluster_id,
    COUNT(DISTINCT kw_link.merged_id)/COUNT(DISTINCT rc_table.merged_id) AS percent_kw
  FROM
    science_map_v2.dc5_cluster_assignment_stable rc_table
  INNER JOIN
    papers_to_clusters kw_link
  USING
    (cluster_id)
  GROUP BY
    cluster_id
  ORDER BY
    percent_kw DESC
  LIMIT
    18) --change number of RCs to plot here 
SELECT
  COUNT(DISTINCT merged_id) AS np,
  merged_corpus.year,
  cluster_id,
  COUNT(DISTINCT kw.merged_id) AS kw_count,
  COUNT(DISTINCT kw.merged_id)/COUNT(DISTINCT merged_id) AS percent_keyword
FROM
  science_map_v2.dc5_cluster_assignment_stable
INNER JOIN
  gcp_cset_links_v2.corpus_merged merged_corpus
USING
  (merged_id)
INNER JOIN
  select_rcs
USING
  (cluster_id)
LEFT JOIN
  keyword_papers kw
USING
  (merged_id)
WHERE
  merged_corpus.year >= 2001
  AND merged_corpus.year <= 2021
GROUP BY
  cluster_id,
  year
