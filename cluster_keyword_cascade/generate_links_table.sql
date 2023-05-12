
WITH
ai_pubs AS(SELECT cset_id as merged_id, year FROM `article_classification.predictions_2023_01_19` 
--INNER JOIN gcp_cset_links_v2.corpus_merged corpus ON cset_id = merged_id
WHERE ai_filtered is true),

keyword_papers AS(SELECT merged_id as topic_id, title_english, abstract_english, title_foreign, abstract_foreign, year as topic_year, doctype, source_title FROM gcp_cset_links_v2.corpus_merged
INNER JOIN ai_pubs USING(merged_id, year)
WHERE year >= 2010 AND year <= 2021 AND ( trusted_ml_research.trustworthy_keywords(LOWER(title_english)) OR trusted_ml_research.trustworthy_keywords(LOWER(abstract_english)))),

  papers_to_clusters AS(
  SELECT
    *
  FROM
    keyword_papers
  INNER JOIN
    science_map_v2.dc5_cluster_assignment_stable
  ON
    merged_id = topic_id),

select_rcs AS(
  SELECT
    COUNT(DISTINCT rc_table.merged_id) AS total_np,
    cluster_id,
    COUNT(DISTINCT keyword_link.merged_id)/COUNT(DISTINCT rc_table.merged_id) AS percent_keyword
  FROM
    science_map_v2.dc5_cluster_assignment_stable rc_table
  INNER JOIN
    papers_to_clusters keyword_link
  USING
    (cluster_id)
  GROUP BY
    cluster_id
  ORDER BY
    percent_keyword DESC
  LIMIT
    20),

  keyword_references AS(
  SELECT
    refs.merged_id AS n2_id,
    year AS n2_year,
    topic_year AS n1_year,
    topic_id,
    cluster_id AS n1
  FROM
    `gcp_cset_links_v2.paper_references_merged` refs
  INNER JOIN
    gcp_cset_links_v2.corpus_merged corpus
  ON
    refs.merged_id = corpus.merged_id
  RIGHT JOIN
    keyword_papers
  ON
    topic_id = refs.ref_id
  INNER JOIN
    science_map_v2.dc5_cluster_assignment_stable dc5
  ON
    topic_id = dc5.merged_id
    WHERE refs.merged_id IN(SELECT topic_id FROM keyword_papers)),
  --link the keyword references to their research cluster id
  refs_to_clusters AS(
  SELECT
    COUNT(DISTINCT topic_id) AS ref_count,
    n2_year,
    cluster_id AS n2,
    n1,
    n1_year
  FROM
    keyword_references
  INNER JOIN
    science_map_v2.dc5_cluster_assignment_stable
  ON
    n2_id = merged_id
  GROUP BY
    n2,
    n2_year,
    n1,
    n1_year)
  --limit the years and number of references that constitute links
SELECT
  *
FROM
  refs_to_clusters
WHERE
  n1_year >= 2001
  AND n2_year >= 2001
  AND n1_year <= 2021
  AND n2_year <= 2021
  AND ref_count >=5
ORDER BY
  n2,
  n2_year
