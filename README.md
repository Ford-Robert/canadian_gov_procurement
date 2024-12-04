# Canadian Government Procurements

## Overview
This Repo contains all the code used to generate the "Procurements of The Canadian Government, Runaway Military Contracts". This repo also contains all of the code used to download and explore the "Investigative Journalism Foundation" data on Canadian Federal Awards that my paper is based on.

## File Structure

The repo is structured as:

-   `data/raw_data` contains the raw data as obtained from the IJF.
-   `data/analysis_data` contains the cleaned dataset that was constructed, and a selected group of top suppliers.
-   `model` contains fitted models. 
-   `other` contains a EDA which includes drafted graphs and calculations, details about LLM chat interactions, and sketches.
-   `paper` contains the files used to generate the paper, including the Quarto document and reference bibliography file, as well as the PDF of the paper.
-   `scripts` contains the R scripts used to simulate, download and clean data.


## Statement on LLM usage

Code usage:

Every file in `scripts` and `models` was written with the help of ChatGPT-4o. The code for most of the graphs and tables in `paper.qmd` and `EDA.qmd` was written with ChatGPT-4o.

Paper usage:

The Introduction, Limitations sub-section of Methods, Results and Discussion sections and the Survey Section in the appendix were written with the assistance of ChatGTP-4o.

All chat logs used in the creation of this rproj can be found `other/llm`