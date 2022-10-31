--get AI papers 
WITH ai_papers AS(SELECT merged_id FROM gcp_cset_links_v2.corpus_merged
WHERE
    REGEXP_CONTAINS(FORMAT('%t',(LOWER(title_english),
          LOWER(abstract_english))),r"(?i)((Artificial Intelligence)|(Machine Learning))")
AND year >=2010 AND year<=2021)


--count by country with EU-27 as one entity 
SELECT COUNT(DISTINCT merged_id) AS paper_count, 
CASE WHEN country IN ("Austria", "Italy", "Belgium", "Latvia", "Bulgaria", "Lithuania", "Croatia", "Luxembourg", "Cyprus", "Malta", "Czechia", "Netherlands", "Denmark", "Poland", "Estonia", "Portugal", "Finland", "Romania", "France", "Slovakia", "Germany", "Slovenia", "Greece", "Spain", "Hungary", "Sweden", "Ireland") THEN "EU-27" ELSE country end as country --treat EU-27 as one entity
FROM `gcp_cset_links_v2.paper_countries_merged`
INNER JOIN ai_papers USING(merged_id)
GROUP BY country
ORDER BY paper_count DESC
