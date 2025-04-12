data {
  int<lower=0> n; // Overall sample size
  int<lower=0> ntest;
  int<lower=0> p; // Number of fixed effect parameters, including intercept
  matrix[n, p] x; // Model matrix including intercept
  matrix[ntest, p] xtest; // Covariates for test data
  int<lower=0,upper=1> y[n];
}
parameters {
  vector[p] beta; // Fixed effect parameters
}
transformed parameters {
  vector<lower=0,upper=1>[n] probs; // Success probabilities
  probs = inv_logit(x*beta);
}
model {
  // Non-informative priors
  beta ~ normal(0, 1000);
  y ~ bernoulli(probs);
}
generated quantities {
  vector[ntest] ptest; // Probabilities for test set
  ptest = inv_logit(xtest*beta); // same as expit()
}