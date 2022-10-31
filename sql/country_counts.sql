--count by country with EU-27 as one entity 
SELECT count(distinct merged_id) as paper_count, 
CASE WHEN country IN ("Austria", "Italy", "Belgium", "Latvia", "Bulgaria", "Lithuania", "Croatia", "Luxembourg", "Cyprus", "Malta", "Czechia", "Netherlands", "Denmark", "Poland", "Estonia", "Portugal", "Finland", "Romania", "France", "Slovakia", "Germany", "Slovenia", "Greece", "Spain", "Hungary", "Sweden", "Ireland") THEN "EU-27" ELSE country end as country --treat EU-27 as one entity
FROM `gcp-cset-projects.trusted_ml_research.trustworthy_ai_papers_0927` 
inner join `gcp_cset_links_v2.paper_countries_merged` using(merged_id)
where year >= 2010 AND year <= 2021
group by country
order by paper_count desc
