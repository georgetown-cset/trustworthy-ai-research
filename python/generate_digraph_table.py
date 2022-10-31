#IMPORT PACKAGES
import pandas as pd
import numpy as np



#Parameters
input_file = #term booleans file
output_file = #set output file 


start_df = pd.read_csv(input_file)
topics = start_df.columns[2:16] #get topics and china affil column 

#select only topic columns
topic_df = start_df[topics]

topic_df = topic_df.fillna(0)


end_df = pd.DataFrame(np.zeros((len(topics), len(topics))))

for idx, row in topic_df.iterrows():
    for i in range(len(topics)):
        if row[i] == 1:
            end_df.iloc[i] += row.to_list()
           
            
end_df.to_csv(output_file)   
