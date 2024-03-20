#!/usr/bin/env Rscript

#Assuming the required datasets'Homo_sapiens.gene_info.gz' and 'h.all.v2023.1.Hs.symbols.gmt' are in same directory
# Loading library
library(data.table)

##### PART1: Mapping Symbol TO GeneID Combining the genes present in Synonyms column ######

# Reading the data
data <- fread("Homo_sapiens.gene_info.gz", sep = "\t", header = TRUE, stringsAsFactors = FALSE)

# Concatenate original gene names (Symbol) with synonyms
data[, Combined_Symbol := paste(Symbol, Synonyms, sep = "|")]

# Create the mapping (Symbol to GeneID)
symbol_to_geneid <- data[, .(Symbol = Combined_Symbol, GeneID)]

# Remove duplicates (in case original gene name is the same as a synonym)
symbol_to_geneid <- unique(symbol_to_geneid)

# Split the Symbol column by "|" delimiter
split_symbols <- strsplit(symbol_to_geneid$Symbol, "\\|")

# Create a data.table to store the split symbols and corresponding GeneIDs
symbol_to_geneid_split <- data.table(
  Symbol = unlist(split_symbols),
  GeneID = rep(symbol_to_geneid$GeneID, sapply(split_symbols, length))
)

# Remove any empty symbols
symbol_to_geneid_split <- symbol_to_geneid_split[Symbol != ""]

##### PART2: Replacing the gene names with Entrez ID extracted from the first “Homo_sapiens.gene_info.gz” file in the "h.all.v2023.1.Hs.symbols.gmt" file

# Read the GMT file line by line, replace gene symbols with GeneIDs, and write the updated GMT file
lines <- readLines("h.all.v2023.1.Hs.symbols.gmt")
updated_rows <- lapply(lines, function(line) {
    fields <- unlist(strsplit(line, "\t"))
    genes <- fields[-(1:2)]
    # Replace gene symbols with GeneIDs
    updated_genes <- lapply(genes, function(symbol) {
        gene_id <- symbol_to_geneid_split[Symbol == symbol, GeneID]
        if (length(gene_id) > 1) {
            # If multiple GeneIDs found, remove the "c" and choose the first one
            gene_id <- gene_id[1]
        }
        if (length(gene_id) > 0) {
            return(as.character(gene_id))
        } else {
            return(symbol) 
        }
    })
    # Combining the updated data and fields
    paste(c(fields[1:2], updated_genes), collapse = "\t")
})

# Ensure that updated_rows is a character vector
updated_rows <- as.character(updated_rows)

# Write the updated GMT file
writeLines(updated_rows, con = "Modified_h.all.v2023.1.Hs.symbols.gmt")
