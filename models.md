# Bayesian Data Analysis: Covid-19 Infection Risks

This document provides a detailed overview of the project, including the data, methods, models, results, and limitations.

---

## 1. Introduction to Data

The dataset used in this study was retrieved from the **IPUMS National Health Interview Survey (2022)**. It consists of 35,115 observations. After data cleaning (removal of missing values), we are left with **12,591 observations**.

### Key Variables:
- **Response Variable**:
  - `Test Results`: Positive (1) or Negative (0)
- **Independent Variables**:
  - `Household ID`: Unique for each household
  - `Sex`: Male (1) or Female (0)
  - `Age`: Continuous variable
  - `Health Status`: Categorical (Excellent, Very Good, Good, Fair, Poor)
  - `Smoke`: Ever smoked 100 cigarettes in life (Yes = 1, No = 0)
  - `Severity of Covid-19 Symptoms`: With Symptoms (1) or Without Symptoms (0)
  - `Covid-19 Shot`: Got vaccinated (Yes = 1, No = 0)
  - `Number of Covid-19 Vaccinations`: Numeric
- **Dummy Variables**:
  - For categorical variables, dummy variables were created. For example:
    - `HealthVeryGood = 1` for "Very Good" health status; reference is "Excellent".

### Data Splitting:
- The dataset was split into **75% training data** and **25% testing data**, with random sampling to ensure validity.

---

## 2. Models

### Model 1: Logistic Regression with Fixed Effects

#### Model Definition
```
y_i | β, x_i ∼ Bernoulli(π_i)
```
where
```
π_i = P(y_i = 1 | β, x_i)
```

#### Link Function
The expected value of a Bernoulli random variable is `π_i`, and since `π_i ∈ (0,1)`, we use the **logit link function** to map `π_i` to the real line:
```
g(μ) = logit(μ) = log(μ / (1 - μ))
```
```
logit(π_i) = x_i^T β
```
```
π_i = exp(x_i^T β) / (1 + exp(x_i^T β)) = expit(x_i^T β)
```

#### Priors
The parameter `β` is the assigned **non-informative priors**:
```
β ∼ N(0, 1000)
```

---

### Model 2: Logistic Regression with Random Intercepts

#### Model Definition
```
y_ij | β, x_ij, τ, u_j ∼ Bernoulli(π_ij)
```
where
```
π_ij = exp(x_ij^T β + u_j) / (1 + exp(x_ij^T β + u_j))
```

#### Random Effects
The random effect for each household `j` is modeled as:
```
u_j | τ^2 ∼ N(0, τ^2)
```

#### Priors
The parameters `β` and `τ` are assigned **non-informative priors**:
```
β ∼ N(0, 1000)
τ ∼ InvGamma(0.001, 0.001)
```

---

## 3. Results

### Model 1: Logistic Regression with Fixed Effects
- **Significant Factors**:
  - Smoking increases the odds of infection by 36.45%.
  - Poor health status significantly increases the risk of infection compared to excellent health status.
  - Vaccination reduces the odds of infection.
- **Insignificant Factors**:
  - Age does not significantly affect infection risk.
  - The difference in infection risk between males and females is small.
- **Performance**:
  - AUC = **0.941**, indicating a good model fit.
  - Optimal threshold `t = 0.495` achieved specificity = **0.985** and sensitivity = **0.901**.

### Model 2: Logistic Regression with Fixed Effects and Random Intercept
- **Interpretation**:
  - Findings are similar to Model 1:
    - Smoking, poor health, and vaccination status are significant.
    - Age remains insignificant.
  - The random intercept accounts for within-household correlation.
- **Challenges**:
  - The model was unreliable due to limited data from multiple observations within the same household.

---

## 4. Limitations

### Data Limitations:
1. **Household Observations**:
   - Only a few households had multiple observations, limiting the reliability of Model 2.
2. **Missing Data**:
   - Several variables had missing values, reducing the effective sample size.
   - For instance, many smoking-related observations lacked COVID-19 test results and vice versa.
3. **Imbalanced Data**:
   - Certain categories (e.g., severe symptoms) had very few observations, requiring grouping into broader categories.

### Modeling Limitations:
1. **Fixed Effects Model (Model 1)**:
   - Does not account for within-household correlation, which could bias the results.
2. **Random Intercept Model (Model 2)**:
   - Limited household data led to wide credible intervals and unreliable estimates.

---

## 5. Conclusion

This study highlights the importance of health behaviors (e.g., smoking, vaccination) and health status in predicting COVID-19 infection risk. While fixed-effects models showed strong predictive performance, the lack of sufficient household data limited the effectiveness of random-effects modeling.

### Significance:
- Policymakers can use these insights to promote vaccination and target high-risk groups (e.g., smokers, individuals with poor health).
- The methodology can be adapted for future pandemic-related studies.

---

## References
1. IPUMS National Health Interview Survey: [https://nhis.ipums.org](https://nhis.ipums.org)
2. Statistics Canada: [https://www150.statcan.gc.ca](https://www150.statcan.gc.ca/n1/daily-quotidien/231208/dq231208a-eng.htm)
