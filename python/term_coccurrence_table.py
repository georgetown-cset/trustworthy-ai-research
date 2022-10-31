#IMPORT PACKAGES
import pandas as pd


#Parameters
input_file = "/Users/at1120/Documents/trusted_ml/digraph_table_101122.csv"
topic_file = "/Users/at1120/Documents/trusted_ml/term_booleans_101122.csv"
start_df = pd.read_csv(topic_file)
topics = start_df.columns[2:15] #get the list of topics

raw_digraph_df = pd.read_csv(input_file, index_col = 0)


dfMax = raw_digraph_df.max(axis=1) #find the max value row-wise for normalization

digraph_df = raw_digraph_df.divide(dfMax, axis=0) #divide by the max to get percentage of pubs that mention another term


digraph_df = digraph_df.iloc[:-1, :-1]

digraph_df.columns = topics
digraph_df = digraph_df.set_axis(topics)


digraph_df.to_csv("/Users/at1120/Documents/term_graph_table_101122.csv")
