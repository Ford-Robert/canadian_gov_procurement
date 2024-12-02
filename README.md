# Starter folder

## Overview

This repo provides students with a foundation for their own projects associated with *Telling Stories with Data*. You do not need every aspect for every paper and you should delete aspects that you do not need.


## File Structure

The repo is structured as:

-   `data/raw_data` contains the raw data as obtained from X.
-   `data/analysis_data` contains the cleaned dataset that was constructed.
-   `model` contains fitted models. 
-   `other` contains relevant literature, details about LLM chat interactions, and sketches.
-   `paper` contains the files used to generate the paper, including the Quarto document and reference bibliography file, as well as the PDF of the paper. 
-   `scripts` contains the R scripts used to simulate, download and clean data.


## Statement on LLM usage

Code usage:

Every file in `scripts` was written with the help of ChatGPT-4o. The code for most of the graphs and tables in `paper.qmd` and `EDA.qmd` was written with ChatGPT-4o.

Paper usage:

The Introduction, Limitations sub-section of Methods, Results and Discussion sections were written with the assistance of ChatGTP-4o. I began by writing a detailed outline containing all of the main points. Then GPT filled in the outline by writing paragraphs for each point. Then I would rewrite each paragraph, keeping bits I liked and changing the wording of bits that I didn't. Most importantly removing all of the bland or repetitive sentences that GPT loves generating.

All chat logs used in the creation of this rproj can be found `other/llm`

## Some checks

- [ ] Change the rproj file name so that it's not starter_folder.Rproj
- [ ] Change the README title so that it's not Starter folder
- [ ] Remove files that you're not using
- [ ] Update comments in R scripts
- [ ] Remove this checklist