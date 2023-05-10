#!/bin/sh

python3 keyword_cascade_plot.py \
    --node_table="node_table.csv" \
    --links_table="links_table.csv" \
    --rc_annotation="rc_annotation.csv" \
    --use_dash_marker \
    --output_filepath="trustworthy_cascade_example.png" \
