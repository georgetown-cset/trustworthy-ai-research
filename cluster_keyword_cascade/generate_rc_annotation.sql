SELECT DISTINCT cluster_id, 
CASE class_art
    WHEN 'humanities' THEN '#99CC66'
    WHEN 'social science' THEN '#FFCC66'
    WHEN 'biology' THEN '#666633'
    WHEN 'earth science' THEN '#993333'
    WHEN 'medicine' THEN '#FF3333'
    WHEN 'chemistry' THEN '#3399FF'
    WHEN 'physics' THEN '#9900CC'
    WHEN 'materials science' THEN '#3300CC'
    WHEN 'mathematics' THEN '#FF0099'
    WHEN 'computer science' THEN '#CC99FF'
    WHEN 'engineering' THEN '#33FFFF'
  END as color, 
  link, 
  regexp_extract(cset_extracted_phrase, r'^[^,]*') as name
 FROM `trusted_ml_research.trust_node_table_040323`
INNER JOIN `science_map_v2.dc5_cluster_description_stable` USING(cluster_id)
