#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 16 13:48:01 2023

@author: at1120
"""


#IMPORT PACKAGES
import networkx as nx
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import argparse
import numpy as np

#DEFINE FUNCTIONS

def parse_arguments(parser):
    parser.add_argument('--node_table', type=str, required=True)
    parser.add_argument('--links_table', type=str, required=True)
    parser.add_argument('--rc_annotation', type=str, required=True)
    parser.add_argument('--output_filepath', type=str, required=True)
    parser.add_argument('--scale_factor', default=1000)
    parser.add_argument('--use_dash_marker', action='store_true')
    return parser

def sort_clusters(node_df):
    sorted_df = node_df.groupby(['cluster_id'])["kw_count"].sum().reset_index()
    sorted_df = sorted_df.sort_values(by = 'kw_count', ascending=True)
    return sorted_df



def map_xy_axis(node_df, year_cutoff):
    years = list(node_df['year'].unique())

    years = [y for y in years if y >= year_cutoff]
    years = list(sorted(years))

    x_dict = dict()
    y_dict = dict()

    for idx, y in enumerate(years):
        x_dict[idx] = y

    sorted_rc = sort_clusters(node_df)
    sorted_rc_ids = list(sorted_rc['cluster_id'])


    #map cluster_id to numeric value for plotting
    for idx, i in enumerate(sorted_rc_ids):
        y_dict[idx] = i


    return x_dict, y_dict


def get_year_idx(year_dict, year_val):
    for key, value in year_dict.items():
        if year_val == value:
            return key

def generate_graph(node_df, links_df, year_dict, cluster_dict):
    G = nx.DiGraph()

    #Plot all RC nodes by year
    for cluster_keys, cluster_vals in cluster_dict.items():
        cluster_df = node_df[node_df['cluster_id']==cluster_vals]


        #print(cluster_keys, cluster_vals)
        for year_keys, year_vals in year_dict.items():
            if year_vals in list(cluster_df.year):
                G.add_node((year_keys, cluster_vals),
                           pos=(year_keys,cluster_keys),
                           size = int(cluster_df[cluster_df['year']==year_vals]['np'].iloc[0]),
                           color = float(cluster_df[cluster_df['year']==year_vals]['percent_keyword'].iloc[0]))

    for idx, row in links_df.iterrows():
        n1_year_idx = get_year_idx(year_dict, row['n1_year'])
        n2_year_idx = get_year_idx(year_dict, row['n2_year'])


        n1 = (n1_year_idx, row['n1'])
        n2 = (n2_year_idx, row['n2'])
        w = int(row['ref_count'])

        if n1 in G and n2 in G:
            G.add_edge(n1, n2, weight = w, color = "gray", connectionstyle ='arc3,rad=0.4')


    return G



def main(args):
    #SET OUTPUT FILE
    output_file = args.output_filepath


    #LOAD DATA

    node_df = pd.read_csv(args.node_table, header = 0)
    links_df = pd.read_csv(args.links_table, header = 0)
    links_df = links_df[links_df['n2'] != links_df['n1']] #remove links within clusters
    color_df = pd.read_csv(args.rc_annotation, header = 0)



    xs, ys = map_xy_axis(node_df, year_cutoff=2010)

    G = generate_graph(node_df, links_df, xs, ys)

    plt.figure(figsize=(20,18))

    pos=nx.get_node_attributes(G,'pos')

    #Node size normalized by the max in the dataset
    node_sizes = nx.get_node_attributes(G, 'size')
    max_node_size = max(node_sizes.values())
    scale_factor = args.scale_factor
    node_sizes = {k:v*scale_factor/max_node_size for k,v in node_sizes.items()}

    node_colors = nx.get_node_attributes(G, 'color')

    #node_labels = nx.get_node_attributes(G, 'label')
    widths = nx.get_edge_attributes(G, 'weight')
    widths = {k:v/7 for k,v in widths.items()}

    edge_colors = nx.get_edge_attributes(G, 'color')
    edge_colors = {k:v for k,v in edge_colors.items()}

    #Custom CSET Color Colormap
    cmap_choice = mcolors.LinearSegmentedColormap.from_list("", ["#BBBCBC","#839DC5","#003DA6", "#0B1F41"])



    node_size_increments = [np.round(x, -1) for x in np.linspace(50,max_node_size, 6, dtype=int)]

    node_size = list(node_sizes.values())


    #Draw nodes
    nodes = nx.draw_networkx_nodes(G, pos,
                                   cmap = cmap_choice,
                                   node_size = node_size,
                                   node_color= list(node_colors.values()))

    #Draw edges
    edges = nx.draw_networkx_edges(
        G,
        pos,
        arrowstyle="-",
        edge_color=list(edge_colors.values()),
        alpha=0.4,
        edgelist = widths.keys(),
        width=list(widths.values()),
        connectionstyle ='arc3,rad=0.05'
    )


    #add colorbar

    color_legend = plt.colorbar(nodes,
                                shrink=0.5,
                                orientation="horizontal",
                                pad = 0.1,
                                ticks=[0, 0.25, 0.5, 0.75, 1])
    color_legend.ax.set_xticklabels(['0%', '25%', '50%', '75%', '100%'],fontsize = 15)
    color_legend.set_label("Percentage of Publications with Keywords", fontsize = 15, fontweight = 'bold')


    #add size legend

    # Make legend for node size
    k = np.sqrt(1/(node_size_increments[-1]*scale_factor/max_node_size)) #scaling lengend nodes since separate from networkx plot
    for n in node_size_increments:
        plt.plot([], [], 'bo', markersize = k*(n*scale_factor/max_node_size), label = f"{n}", color = "grey")

    l = plt.legend(labelspacing = 2,
               loc='center left',
               bbox_to_anchor=(0.22, 0.0001),
               frameon = False,
               title = "Number of Publications",
               ncol = len(node_size_increments),
               fontsize = 15)

    plt.setp(l.get_title(),fontsize=15)



    #Add Year annotation

    year_ys = [len(ys)-0.1] * len(xs)
    year_xs = list(xs.keys())

    plt.plot(year_xs,year_ys,'w')

    # zip joins x and y coordinates in pairs
    for x,y in zip(year_xs,year_ys):

        label = "{:.2f}".format(y)

        plt.annotate(xs[x], # this is the text
                     (x,y), # these are the coordinates to position the label
                     textcoords="offset points", # how to position the text
                     xytext=(0,0), # distance from text to points (x,y)
                     ha='center', fontsize = 15) # horizontal alignment can be left, right or center



    # Add RC annotation

    cluster_xs = [len(xs)+0.1] * len(ys)
    cluster_ys = list(ys.keys())
    name_dict = colors_dict = dict(zip(color_df.cluster_id, color_df.name))


    plt.plot(cluster_xs,cluster_ys,'w')

    # zip joins x and y coordinates in pairs
    for x,y in zip(cluster_xs,cluster_ys):


        label = "{:.2f}".format(y)
        rc_id = ys[y]
        name = name_dict[rc_id]
        txt = "{}: {}".format(str(rc_id), name)

        plt.annotate(txt, # this is the text
                     (x,y), # these are the coordinates to position the label
                     textcoords="offset points", # how to position the text
                     xytext=(0,0), # distance from text to points (x,y)
                     va='center', ha='left', fontsize = 15, weight='bold') # horizontal alignment can be left, right or center



    rc_title_y = len(cluster_ys) + 0.2
    rc_title_x = len(xs) + 0.1
    plt.annotate("Research Clusters \n ID: Description", # this is the text
                     (rc_title_x,rc_title_y), # these are the coordinates to position the label
                     textcoords="offset points", # how to position the text
                     xytext=(0,0), # distance from text to points (x,y)
                     va='center', ha='left', fontsize = 15, weight='bold')



    # Add RC colors -- you can decide if you want the colored dots or just a gray line below

    cluster_dot_xs = [len(xs)] * len(ys)
    cluster_dot_ys = list(ys.keys())
    colors_dict = dict(zip(color_df.cluster_id, color_df.color))

    colors = [colors_dict[id] for id in ys.values()]



    if args.use_dash_marker:
        #This plots a thin gray line to denote RC label
        plt.scatter(cluster_dot_xs, cluster_dot_ys, marker='_', linewidths=1, color = "gray")
    else:
        #This plots a dot with the broad area of research color (from the map of science)
        plt.scatter(cluster_dot_xs, cluster_dot_ys, s = 150, c = colors)


    plt.axis('off')

    plt.savefig(output_file, bbox_inches = "tight")


if __name__ == "__main__":
    parse = argparse.ArgumentParser()
    parser = parse_arguments(parse)
    args = parser.parse_args()
    main(args)
