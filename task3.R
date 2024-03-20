#!/usr/bin/env Rscript

#loading libraries
library(data.table)
library(ggplot2)
library(dplyr)

##Assuming the required file "Homo_sapiens.gene_info.gz" is in the same directory
#reading the data
data <- fread("Homo_sapiens.gene_info.gz", sep = "\t", header = TRUE, stringsAsFactors = FALSE)
head(data)

##Calculating Gene Count Per Chromosome using dplyr
gene_count_per_chr <- data %>%
  group_by(chromosome) %>%
  summarise(gene_count = n())

#Filtering Gene Count of values with '|' and '-'
filtered_gene_count_data <- gene_count_per_chr %>% 
  filter(!grepl("-|\\|", chromosome))
print(filtered_gene_count_data)

#Rearranging the chromosome column 
#sorted_gene_count <- filtered_gene_count_data %>% arrange(as.numeric(chromosome)) #kept X,Y chr at the end
  
# Another approach defining the order of chromosome levels
chromosome_levels <- c(1:22, "X", "Y", "MT", "Un")

# Convert 'chromosome' column to factor with specified levels and order
filtered_gene_count_data$chromosome <- factor(filtered_gene_count_data$chromosome, levels = chromosome_levels)

# Sort the dataframe by the 'chromosome' column
sort_gene_count_data <- filtered_gene_count_data %>%
  arrange(chromosome)

print(sort_gene_count_data)

# Plotting the Sorted Number of Genes per Chromosome, with ordered chromosomes

Number_Of_Genes_per_Chrom <- ggplot(data = sort_gene_count_data, aes(x = chromosome, y = gene_count)) +
  labs(title = "Number of genes in each chromosome", x = "Chromosome", y = "Gene Count") +
  geom_bar(stat = "identity") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5), 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.line = element_line(color = "black"),  
        axis.ticks = element_line(color = "black"))

ggsave("Number_Of_Genes_per_Chrom.pdf")
