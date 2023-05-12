--get trustworthy ai clusters
with clusters as(SELECT cluster_id FROM `gcp-cset-projects.trusted_ml_research.top25_clusters_040323`
order by percent_related desc
limit 18)

--get total paper count by cluster by year  
select count(distinct merged_id) as paper_count, year, cluster_id from clusters 
inner join `science_map_v2.dc5_cluster_assignment_stable` using(cluster_id)
inner join gcp_cset_links_v2.corpus_merged using(merged_id)
where year >= 2010 and year <= 2021
group by year, cluster_id 
order by year
