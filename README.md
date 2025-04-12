# Bayesian Data Analysis: Covid-19 Infection Risks

This repository contains the code and analysis for the project **"Bayesian Data Analysis: Covid-19 Infection Risks"**, completed as part of **MATH 6635 Introduction to Bayesian Statistics** at York University.

## Overview

The study aims to predict COVID-19 infection status and understand the factors influencing infection risk using Bayesian logistic regression models. Two models are compared:
1. Logistic regression with fixed effects.
2. Logistic regression with fixed effects and a random intercept.

The analysis leverages data from the IPUMS National Health Interview Survey (2022), with 12,591 observations after data cleaning.

## Contents

- **Data Preprocessing:** Handling missing values, creating dummy variables, and splitting data into training and testing sets.
- **Exploratory Data Analysis (EDA):** Visualization of variables such as vaccination status, number of vaccinations, and test results.
- **Modeling:** Bayesian logistic regression with:
  - Fixed effects (Model 1)
  - Fixed effects and random intercept (Model 2)
- **Results:** Interpretation of coefficients, odds ratios, and model testing.
- **Limitations:** Discussion of data limitations and challenges in modeling.
- **Significance:** Policy implications and future applications.

## Key Findings

1. COVID-19 vaccinations significantly reduce the odds of infection.
2. Smoking and poor health status increase infection risk.
3. Age does not significantly impact infection status.

## Repository Structure

- `data/`: Data files used in the analysis.
- `scripts/`: R scripts for data cleaning, EDA, and modeling.
- `models/`: Stan scripts for Bayesian models.
- `results/`: Output files, tables, and visualizations.
- `README.md`: Project documentation.

## Requirements

The analysis was conducted using:
- **R**: For data preprocessing, EDA, and visualization.
- **Stan**: For Bayesian modeling.
- **Libraries**:
  - `ipumsr`
  - `tidyverse`
  - `rstan`
  - `pROC`

To reproduce the analysis, ensure the above tools and libraries are installed.

## References
- IPUMS National Health Interview Survey, https://nhis.ipums.org
