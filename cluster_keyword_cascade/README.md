# Keyword Cascade Plot Instructions:

1. Generate files from BiqQuery for Python input 

  - You will need to run each of these sql scripts and save each file to your local machine. The output file names will correspond to the input files in the Python script. [SQL Scripts](https://github.com/georgetown-cset/research-cluster-visuals/tree/main/keyword_cascade/sql):

    
    1. [Keyword Node Table Ouput](https://github.com/georgetown-cset/research-cluster-visuals/blob/main/keyword_cascade/sql/get_kw_counts_pcts_byyear.sql) ==> [node_table.csv](https://github.com/georgetown-cset/trustworthy-ai-research/blob/main/cluster_keyword_cascade/node_table.csv)
Table Contents:
* **np**: number of papers in the cluster
* **year**: (group by year)
* **cluster_id**: (group by cluster_id)
* **kw_count**: number of keyword publications 
* **percent_keyword**: kw_count / np

These are the fields that you need to plot the nodes. 

    2. [Node Links Table](https://github.com/georgetown-cset/research-cluster-visuals/blob/main/keyword_cascade/sql/get_topic_links_byyear.sql) ==> [links_table.csv](https://github.com/georgetown-cset/trustworthy-ai-research/blob/main/cluster_keyword_cascade/links_table.csv)
    4. [Node Labels](https://github.com/georgetown-cset/research-cluster-visuals/blob/main/keyword_cascade/sql/get_colors_annotation.sql) ==> [rc_annotation.csv](https://github.com/georgetown-cset/trustworthy-ai-research/blob/main/cluster_keyword_cascade/rc_annotation.csv)