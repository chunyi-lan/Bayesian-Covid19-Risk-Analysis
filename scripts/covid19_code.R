# Initialization
library(ipumsr)
library(tibble)
library(rstan)
library(dplyr)
library(tidyverse)
library(tidyr)
library(MASS)
library(pROC)

ddi <- read_ipums_ddi("nhis_00005.xml")
covid <- read_ipums_micro(ddi)

# EDA

# Covid-19 Vaccination Status
label_barplot_CVDSHT <- c("No", "Yes")
group_CVDSHT <- data.frame(table(covid$CVDSHT))
text(
  x = barplot(table(covid$CVDSHT), xlab = "Covid-19 Vaccination Status",
              names.arg = label_barplot_CVDSHT,
              ylab = "Frequency", col = "steelblue",
              cex.main = 1.5, cex.lab = 1.2, cex.axis = 1.1,
              ylim = c(0, max(group_CVDSHT[,2]) * 1.3)),
  y = group_CVDSHT[,2] + 1, labels = group_CVDSHT[,2], pos = 3, cex = 1.2, col = "black"
)

# Number of Covid-19 Vaccinations
label_barplot_CVDSHTNUM <- c(0:3, ">3")
group_CVDSHTNUM <- data.frame(table(covid$CVDSHTNUM))
text(
  x = barplot(table(covid$CVDSHTNUM),
              xlab = "Number of Covid-19 Vaccinations",
              names.arg = label_barplot_CVDSHTNUM,
              ylab = "Frequency", col = "steelblue",
              cex.main = 1.5, cex.lab = 1.2, cex.axis = 1.1,
              ylim = c(0, max(group_CVDSHTNUM[,2]) * 1.3)),
  y = group_CVDSHTNUM[,2] + 1, labels = group_CVDSHTNUM[,2], pos = 3, cex = 1.2,
  col = "black"
)

# Covid Test Result
label_barplot_CVDTESTRSLT <- c("Negative", "Positive")
group_CVDTESTRSLT <- data.frame(table(covid$CVDTESTRSLT))
text(
  x = barplot(table(covid$CVDTESTRSLT),
              xlab = "Covid-19 Test Results",
              names.arg = label_barplot_CVDTESTRSLT,
              ylab = "Frequency", col = "steelblue",
              cex.main = 1.5, cex.lab = 1.2, cex.axis = 1.1,
              ylim = c(0, max(group_CVDTESTRSLT[,2]) * 1.3)),
  y = group_CVDTESTRSLT[,2] + 1, labels = group_CVDTESTRSLT[,2], pos = 3, cex = 1.2,
  col = "black"
)

# Data Cleaning
# Remove No Test Results
# Change Positive 2 -> 1, Negative 1 -> 0

covid <- covid[!is.na(covid$CVDTESTRSLT),]
covid <- covid[!is.na(covid$CVDSHT),]
covid <- covid[!is.na(covid$CVDSYMP),]

covid <- covid[-which(covid$CVDTESTRSLT == 0), ]
covid <- covid[-which(covid$CVDTESTRSLT > 2), ]
covid$CVDTESTRSLT <- covid$CVDTESTRSLT - 1

covid <- covid[-which(covid$CVDSHT == 0), ]
covid <- covid[-which(covid$CVDSHT > 2), ]
covid$CVDSHT <- covid$CVDSHT - 1

# Dummy Variables for serverity symptoms
# Reference: no symptoms
covid <- covid[-which(covid$CVDSYMP == 0), ]
covid <- covid[-which(covid$CVDSYMP > 4), ]
covid$CVDSYMP <- ifelse(covid$CVDSYMP == 1, 0, 1)

covid <- covid[-which(covid$SMOKEV == 0), ]
covid <- covid[-which(covid$SMOKEV > 2), ]
covid$SMOKEV <- covid$SMOKEV - 1

# Dummy Variables for HEALTH
# Reference: Excellent
covid$health_vgood <- ifelse(covid$HEALTH == 2, 1, 0)
covid$health_good <- ifelse(covid$HEALTH == 3, 1, 0)
covid$health_fair <- ifelse(covid$HEALTH == 4, 1, 0)
covid$health_poor <- ifelse(covid$HEALTH == 5, 1, 0)

# Dummy Variables for Sex
covid$sex_male <- ifelse(covid$SEX == 1, 1, 0)
12
covid <- covid[-which(covid$SEX > 2), ]

# Unique Household
unique_houshold_id <- unique(covid$NHISHID)

# Convert NHISHID from string to integers
out <- strsplit(covid$NHISHID,split = 'H')
HID <- do.call(cbind, out)
covid$NHISHID <- as.numeric(HID[2,])

# Train Test Splitting
train.size <- floor(0.75*NROW(covid))
ss <- sample(1:NROW(covid), train.size)
covid_train <- covid[ss,]
covid_test <- covid[-ss,]

# Model matrix
X_1 <- model.matrix(~AGE+sex_male+SMOKEV+health_vgood+health_good+health_fair
                    +health_poor+CVDSYMP+CVDSHT+CVDSHTNUM, data=covid_train)
X_1_test <- model.matrix(~AGE+sex_male+SMOKEV+health_vgood+health_good+health_fair
                         +health_poor+CVDSYMP+CVDSHT+CVDSHTNUM, data=covid_test)

Y_1 <- covid_train$CVDTESTRSLT
Y_1_test <- covid_test$CVDTESTRSLT

# Stan Model 1: without Random Intercept
sdata_1 <- list(n=NROW(covid_train), ntest=NROW(X_1_test), p=NCOL(X_1),
                x=X_1, xtest=X_1_test, y=Y_1)
sfile_1 <- "model_1.stan"
fit_1 <- stan(sfile_1, data=sdata_1, iter=2000, warmup=1000, cores=8)

# Stan Model 2: with Random Intercept
sdata_2 <- list(n=NROW(covid_train), p=NCOL(X_1), ID=max(covid_train$NHISHID),
                ID=covid_train$NHISHID, x=X_1, y=Y_1)
sfile_2 <- "model_2.stan"
fit_2 <- stan(sfile_2, data=sdata_2, iter=2000, warmup=1000, cores=8)

# Extract Betas, and Odds
beta_fit1 <- summary(fit_1)$summary[,"mean"][1:11]
beta_fit1
exp(beta_fit1)
beta_fit2 <- summary(fit_2)$summary[,"mean"][1:11]
beta_fit2
exp(beta_fit2)

summary_1 <- summary(fit_1, pars=c("beta"))$summary
summary_1
13

summary_2 <- summary(fit_2, pars=c("beta","tau"))$summary
summary_2

# Traceplot
tplot_1 <- traceplot(fit_1, pars=c("beta"), inc_warmup=TRUE)
tplot_1
tplot_2 <- traceplot(fit_2, pars=c("beta"), inc_warmup=TRUE)
tplot_2

# Testing for fit_1

Y_1_test[1]
covid_test[1,] #0002022H00000710
stan_hist_1 <- stan_hist(fit_1, pars="ptest[1]")
print(stan_hist_1 + labs(x="Histogram for Predicted Values
(Person ID: 0002022H00000710)"))

Y_1_test[60]
covid_test[60,] #0002022H00114310
stan_hist_60 <- stan_hist(fit_1, pars="ptest[60]")
print(stan_hist_60 + labs(x="Histogram for Predicted Values
(Person ID: 0002022H00114310)"))

Y_1_test[117]
covid_test[117,] #0002021H00233110
stan_hist_117 <- stan_hist(fit_1, pars="ptest[117]")
print(stan_hist_117 + labs(x="Histogram for Predicted Values
(Person ID: 0002022H00233110)"))

# Extracting mcmc samples for predicted probabilities
# Taking posterior mean as prediction for probability of covid infection status

mcmc.ptest <- rstan::extract(fit_1, pars="ptest")$ptest

ptest <- colMeans(mcmc.ptest)
hist(ptest, breaks=100, main='', xlab = 'Predicted Values', col="lightblue")

auc(Y_1_test, ptest, plot=TRUE, print.thres="best", auc.polygon=TRUE,
    auc.polygon.col="lightblue", asp=FALSE, print.auc=TRUE)
