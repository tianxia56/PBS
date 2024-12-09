import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# Define the shapes to be used for different populations
shapes = ['o', 's', 'v', '^', 'd', '>', '<']

# Ask user for the sup-pop input
sup_pop = input("Enter the sup-pop: ")

# Ask user for the color series input
color_series = input("Enter the color series (e.g., YlOrBr, Reds, Greens, Blues, Purples): ")

# Ask user for the file name containing genes to tag
genes_file = input("Enter the file name containing genes to tag: ")

# Ask user for the y limit value
y_limit = float(input("Enter the y limit value: "))

# Read genes to tag from the file
with open(genes_file, 'r') as file:
    genes_to_tag = [line.strip() for line in file]

# Define the folder path
folder_path = f'PBS.{sup_pop}'

# Initialize a dictionary to store data for plotting
plot_data = {'GENE': [], 'Row_Count': [], 'Max_PBS_norm': [], 'POP': [], 'Shape': [], 'Color': []}

# Initialize a counter for shapes and colors
shape_counter = 0

# Define the color palette based on user input
colors = sns.color_palette(color_series, len(shapes))

# Iterate over files in the folder
for file_name in os.listdir(folder_path):
    if file_name.endswith('.combined.PBS.normed_exon.txt'):
        # Extract population code from file name
        pop = file_name[:3]
        
        # Read the file into a DataFrame
        file_path = os.path.join(folder_path, file_name)
        df = pd.read_csv(file_path, sep='\t')
        
        # Convert PBS_norm column to numeric, forcing errors to NaN
        df['PBS_norm'] = pd.to_numeric(df['PBS_norm'], errors='coerce')
        
        # Drop rows with NaN values in PBS_norm column and keep only PBS_norm > 0
        df = df.dropna(subset=['PBS_norm'])
        df = df[df['PBS_norm'] > 0]
        
        # Group by GENE and calculate the maximum PBS_norm and row count for each gene
        grouped = df.groupby('GENE').agg({'PBS_norm': 'max', 'GENE': 'count'}).rename(columns={'GENE': 'Row_Count'}).reset_index()
        
        # Append data to plot_data dictionary
        plot_data['GENE'].extend(grouped['GENE'])
        plot_data['Row_Count'].extend(grouped['Row_Count'])
        plot_data['Max_PBS_norm'].extend(grouped['PBS_norm'])
        plot_data['POP'].extend([pop] * len(grouped))
        plot_data['Shape'].extend([shapes[shape_counter]] * len(grouped))
        plot_data['Color'].extend([colors[shape_counter]] * len(grouped))
        
        # Update shape counter
        shape_counter = (shape_counter + 1) % len(shapes)

# Create a DataFrame from plot_data dictionary
plot_df = pd.DataFrame(plot_data)

# Rescale the x-axis so that 0-1 is twice as long as 1-2, 2-3 is half of 1-2, and so on.
def rescale_x(x):
    return np.log2(x + 1)

plot_df['Rescaled_Row_Count'] = plot_df['Row_Count'].apply(rescale_x)

# Create a scatter plot using matplotlib directly to control colors and shapes
plt.figure(figsize=(12, 12))  # Change the ratio of plot to 1:1 by setting figsize to (12, 12)
for shape, color, pop in zip(shapes, colors, plot_df['POP'].unique()):
    subset_df = plot_df[plot_df['POP'] == pop]
    plt.scatter(subset_df['Rescaled_Row_Count'], subset_df['Max_PBS_norm'], label=pop, marker=shape, color=color, s=300)  # Triple the dot size

# Set plot labels and title with unified font size of 20
plt.xlabel('Number of SNPs in Gene', fontsize=20)
plt.ylabel('Maximum Normalized PBS', fontsize=20)
plt.title(f'{sup_pop} GRCh37', fontsize=20)

# Adjust the x-axis ticks to reflect the custom scaling and only show 1, 10, 100 with unified font size of 20
plt.xticks([0, np.log2(10), np.log2(100)], ['1', '10', '100'], fontsize=20)
plt.yticks(fontsize=20)

# Set y limit value
plt.ylim(0, y_limit)

# Annotate specified genes only once on the highest PBS_norm with unified font size of 20
for gene in genes_to_tag:
    gene_subset = plot_df[plot_df['GENE'] == gene]
    if not gene_subset.empty:
        highest_pbs_row = gene_subset.loc[gene_subset['Max_PBS_norm'].idxmax()]
        plt.text(highest_pbs_row['Rescaled_Row_Count'], highest_pbs_row['Max_PBS_norm'], gene, fontsize=20)

# Adjust the legend to show each shape with its own color and accompany with one pop, place it inside the plot frame on the upper-right corner with unified font size of 20
plt.legend(title=None, loc='upper right', fontsize=20)

# Save the plot to a PNG file named after sup-pop
plt.tight_layout()
plt.savefig(f'{sup_pop}_scatter_plot_grch37.png')

print(f"The scatter plot has been saved as {sup_pop}_scatter_plot_grch37.png")
