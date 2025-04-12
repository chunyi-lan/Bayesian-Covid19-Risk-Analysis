data {
  int<lower=0> n; // Overall sample size
  int<lower=0> p; // Number of fixed effect parameters, including intercept
  int<lower=0> nID; // Number of viral load
  int<lower=1,upper=nID> ID[n]; // Vector indicating subject ID
  matrix[n, p] x; // Model matrix including intercept
  int<lower=0,upper=1> y[n];
}
parameters {
  vector[p] beta; // Fixed effect parameters
  real<lower=0> tau; // Stdev of random intercept
  vector<lower=0>[nID] etaint;
}
transformed parameters {
  vector[n] mu; // Mean of normal likelihood
  vector<lower=0,upper=1>[n] probs; // Success probabilities
  vector[nID] rint; // Random intercept parameter
  rint = etaint*tau;
  mu = x*beta;  // Starting with fixed effect
  for (i in 1:n) {
    mu[i] = mu[i] +rint[ID[i]]; // Adding on each random effect
  }
  probs = exp(mu)./(1+exp(mu));
}
model {
  // Non-informative priors
  beta ~ normal(0, 1000);
  tau ~ inv_gamma(0.001, 0.001);
  // Normal prior for random intercept
  etaint ~ normal(0, 1);
  // Likelihood
  y ~ bernoulli(probs);
}

