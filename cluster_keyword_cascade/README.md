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
        
        Table Contents:
        * **ref_count**: number of papers being cited (links)
        * **n2_year**: node 2 year
        * **n2**: node 2
        * **n1**: node 1
        * **n1_year**: node 1 year
        These are the fields you need to plot the links.

    3. [Node Labels](https://github.com/georgetown-cset/research-cluster-visuals/blob/main/keyword_cascade/sql/get_colors_annotation.sql) ==> [rc_annotation.csv](https://github.com/georgetown-cset/trustworthy-ai-research/blob/main/cluster_keyword_cascade/rc_annotation.csv)
        
        Table Contents:
        * **cluster_id**: cluster ID 
        * **color**: cluster color in the map of science
        * **link**: hyperlink to the UI
        * **name**: top descriptive phrase
        These are the fields you need for the annotation of the nodes (colors & descriptions).
        
 2. Generate the plot 

  ```
  $ ./generate_kw_plot.sh
  ```
  
  You will need to configure all paths to the files generated above in [generate_kw_plot.sh](cluster_keyword_cascade/generate_kw_plot.sh).
  Additionally, there is the option to change the marker (use_dash_marker), remove that line if you would like to have the cluster color as the cluster marker, exmaples provided below.  
  
 using the colored dots your graph will look like this:

![plot](https://github.com/georgetown-cset/trustworthy-ai-research/blob/main/cluster_keyword_cascade/trustworthy_cascade_rccolor.png)


using the dash marker your graph will look like this:

![plot](https://github.com/georgetown-cset/trustworthy-ai-research/blob/main/cluster_keyword_cascade/trustworthy_cascade_dashlines.png)
