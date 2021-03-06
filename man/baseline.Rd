% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/model-baseline.R
\name{baseline_const_c}
\alias{baseline_const_c}
\alias{baseline_const_d}
\alias{baseline_mean_c}
\alias{baseline_mean_d}
\title{Baseline models}
\usage{
baseline_const_c(formula, consr, data = NULL, ...)

baseline_const_d(formula, const, data, ...)

baseline_mean_c(formula, data = NULL, ...)

baseline_mean_d(formula, data = NULL, ...)
}
\arguments{
\item{formula}{A formula, the observed variables, with only a left-hand-side (for example: \code{response ~ .}), note the "\code{~ .}" on the right.}

\item{const}{(optional, \bold{required} in \code{baseline_const_}) A number, the constant value that the model should predict.}
}
\description{
Baseline models are simple stimulus-agnostic models, \code{baseline_const_c(), baseline_const_d()} predict a constant value for continuous and discrete data (resp.), \code{baseline_mean_c(), baseline_mean_d()} predict the mean of the observed values for continuous and discrete response data (resp.).
}
\details{
Baseline models are very simple models that ignore the stimuli. Baseline models are used as sanity checks in cognitive model comparisons. Other cognitive models are usually supposed to beat the baseline model -- if not, the other cognitive models do very likely not describe the observed data well.

Use \bold{\code{baseline_..._d}} for discrete response variables; and use \bold{\code{baseline_..._c}} for continuous response variables.

\bold{\code{baseline_const_}} predicts the numeric value \code{const} for all trials. A common baseline model in binary choice tasks is, for instance, a model predicting \emph{Pr=0.50} for each trial, for which you set \code{const = 0.50}. The model \bold{baseline_mean_} predicts the mean of the observed choices for each trial. This model has at least one free parameter (the mean).
}
\examples{
# Here is some data, let y be the observed data
D <- data.frame(y = c(1,1,0), x = c(1,2,3))

# Baseline model that predicrs Pr = 0.50
M <- baseline_const_c(y ~ ., const = 0.50, data = D)

predict(M)                         # predicts 0.5, 0.5, 0.5
npar(M)                            # 0 parameter
logLik(M)                          # log likelihood (binomial)

M <- baseline_mean_d(y ~ ., D)     # Pr = mean(observed variable)
predict(M)                         # predicts 0.66, 0.66, 0.66
coef(M)                            # mean counts as free parameter
npar(M)                            # 1 free parameter, the mean

}
\concept{Cognitive models}
