--get AI papers
WITH ai_counts AS(SELECT COUNT(DISTINCT merged_id) as ai_paper_count, year FROM `gcp_cset_links_v2.corpus_merged`
                  WHERE (REGEXP_CONTAINS(LOWER(title_english), r"(?i)((artificial intelligence)|(machine learning))") 
                  OR REGEXP_CONTAINS(LOWER(abstract_english), r"(?i)((artificial intelligence)|(machine learning))")) AND year >= 2010 AND year <= 2021
                  GROUP BY year),
--get Trustworthy AI papers 
trusted_counts AS(SELECT COUNT(DISTINCT merged_id) as trusted_count, year FROM `gcp-cset-projects.trusted_ml_research.trustworthy_ai_papers_0927`
                  WHERE year >= 2010 AND year <= 2021
                  GROUP BY year )

SELECT * from ai_counts
JOIN trusted_counts USING(year)
