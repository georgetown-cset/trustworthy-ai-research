
WITH
ai_pubs AS(SELECT cset_id as merged_id, year FROM `article_classification.predictions_2023_01_19` 
WHERE ai_filtered is true),

keyword_papers AS(SELECT merged_id as topic_id, title_english, abstract_english, title_foreign, abstract_foreign, year as topic_year, doctype, source_title FROM gcp_cset_links_v2.corpus_merged
INNER JOIN ai_pubs USING(merged_id, year)
WHERE year >= 2010 AND year <= 2021 AND (trusted_ml_research.trustworthy_keywords(LOWER(title_english)) OR trusted_ml_research.trustworthy_keywords(LOWER(abstract_english)))),

papers_to_clusters AS(SELECT * FROM keyword_papers
  INNER JOIN science_map_v2.dc5_cluster_assignment_stable ON merged_id = topic_id),

  --select the top 20 research clusters with the highest percentage of keywords
  --top 20 is somewhat arbitrary so adjust this for how many distinct clusters you want to display
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
    18),
  --get the top 18
  --get the keyword publications from node 1 (n1) and link them to their references
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
    topic_id = dc5.merged_id),

restricted_ids AS(SELECT n2_id FROM keyword_references 
INNER JOIN science_map_v2.dc5_cluster_assignment_stable ON n2_id = merged_id
WHERE cluster_id IN(SELECT n1 FROM keyword_references) AND cluster_id NOT IN(SELECT cluster_id FROM select_rcs)),

  --link the keyword references to their research cluster id
  refs_to_clusters AS(
  SELECT
    COUNT(DISTINCT topic_id) AS ref_count,
    merged_id
  FROM
    keyword_references
  INNER JOIN
    science_map_v2.dc5_cluster_assignment_stable
  ON
    n2_id = merged_id
  GROUP BY
  merged_id)
  --limit the years and number of references that constitute links
SELECT
  COUNT(DISTINCT n2_id) as ref_count, topic_id, n1, title_english, abstract_english
FROM
  keyword_references
  INNER JOIN `gcp_cset_links_v2.corpus_merged` ON topic_id = merged_id
  WHERE n2_id NOT IN(SELECT n2_id FROM restricted_ids) AND n1 IN(SELECT cluster_id FROM select_rcs)
  GROUP BY topic_id, n1,title_english, abstract_english
ORDER BY ref_count DESC
LIMIT 50
