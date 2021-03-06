% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/model-bayes.R
\name{bayes}
\alias{bayes}
\alias{bayes_beta}
\alias{bayes_dirichlet}
\title{Bayesian Inference Cognitive Model}
\usage{
bayes(
  formula,
  data = data.frame(),
  fix = list(),
  format = c("raw", "count", "cumulative"),
  type = NULL,
  discount = 0L,
  options = list(),
  ...
)

bayes_beta(formula, data = data.frame(), fix = NULL, format = NULL, ...)

bayes_dirichlet(formula, data, fix = NULL, format = NULL, ...)
}
\arguments{
\item{formula}{A formula, the reported beliefs ~ event + event ... (e.g., \code{y ~ coin_heads + coin_tails}).}

\item{format}{A string (default \code{"raw"}) with the data format. Can be \code{"raw"}, \code{"cummulative"}, \code{"count"}, where \code{"raw"} means data are occurrence indicators (1=event, 0=no event); \code{"cumulative"} means data are cumulative event frequencies (1,2,2,...), and code{"count"} means data are non-ordered event frequencies (10,2,5,...).}

\item{type}{(optional) A string, the type of inference, \code{"beta-binomial"} or \code{"dirichlet-multinomial"}. Can be abbreviated. Will be inferred, if missing.}

\item{...}{other arguments from other functions, currently ignored.}
}
\value{
An model object (similar to lm-objects) of class "bayes". It can be viewed with \code{summary(mod)}, where \code{mod} is the name of the model object.
}
\description{
\code{bayes()} fits a Bayesian cognitive model, updating beliefs about discrete-event probabilities from event frequencies, \code{bayes_beta()} is for binomial events, \code{bayes_dirichlet()} is for categorical/multinomial events.
}
\details{
Given the formula \code{y ~ a} the model predicts beliefs about event "a" occurring, but given \code{y ~ a + b} it predicts beliefs about events "a" and "b" occurring. If "a" and "b" are complementary the predictions will be complements, the difference is that
\itemize{
\item{For \code{y~a} predictions have 1 column, \code{pred_a}}
\item{For \code{y~a+b} predictions have 2 columns, \code{pred_a, pred_b} (with \code{pred_a} = 1 - \code{pred_b})}
\item{For \code{y~a+b+c} predictions have 3 columns, \code{pred_a, pred_b, pred_c}}
\item{etc.}
}

\emph{Note}, during parameter fitting the model treats the response variable \code{y} as beliefs about the \emph{first} event. In other words, \code{y} represents observed beliefs about \code{a} for the formula \code{y ~ a + b} (not \code{b}).

\code{bayes_beta()} calls \link{bayes} with \code{type = "beta-binomial"}.

\code{bayes_dirichlet()} calls \link{bayes} with \code{type = "dirichlet-multinomial"}.
}
\section{Parameter Space}{

\tabular{lrcllr}{\verb{   }\strong{Name} \tab \verb{    }\strong{LB} \tab  \strong{-} \tab \strong{UB}\verb{    } \tab \strong{Description} \tab \strong{Start Value}\cr
\verb{   }\code{delta} \tab  0 \tab  - \tab  10 \tab  Weight of observation during learning, < 1 yields conservatism, > 1 yields liberal learning, 1 is optimal Bayesian \tab  1\cr
\verb{   }\code{priorpar} \tab  0.001 \tab  - \tab   n events \tab  Hyperparameter of the prior belief distribution before trial 1, sum to n events. Note: parameter names will be the RHS of the \code{formula} \tab  1}
}

\examples{
D <- data.frame(
  a = c(0,0,1,1,1),              # event A, e.g. coin toss "heads"
  b = c(1,1,0,0,0),              # event B, complementary to A
  y = c(0.5,0.6,0.6,0.6,0.5))    # participants' reported beliefs

M <- bayes(y ~ a + b, D, fix="start")          # fixed par. to start values
predict(M)                                     # predict posterior means
anova(M)                                       # anova-like table
MSE(M)                                         # mean-squared error   

### Different predictions
# ---------------------------------------
predict(M, type = "mean")                      # predict posterior mean
predict(M, type = "max")                       #  --"--  maximum posterior
predict(M, type = "sd")                        #  --"--  posterior SD
predict(M, type = "posteriorpar")              #  --"--  posterior hyper-par.
predict(M, type = "draws", ndraws = 3)         #  --"--  3 draws from posterior      

### Ways to formulate the model parameter
# ---------------------------------------
bayes(~a+b, D, list(delta=1, priorpar=c(1, 1)))  # delta=1, uniform prior
bayes(~a,   D, list(delta=1, priorpar=c(1, 1)))  # -- (same) --
bayes(~a+b, D, list(delta=1, a=1, b=1))          # -- (same) --
bayes(~a+b, D, fix = "start")                    # fix par. to start values
bayes(~a,   D, fix = "start")                    # -- (same) --


### Parameter fitting
# ---------------------------------------
# Use a response variable, y, to which we fit parameter
bayes(y ~ a + b, D, fix = "start")              # "start" fixes all par., fit none 
bayes(y ~ a + b, D, fix = list(delta=1))         # fix delta, fit priors 
bayes(y ~ a + b, D, fix = list(a=1, b=1))        # fix priors, fit delta 
bayes(y ~ a + b, D, fix = list(delta=1, a=1))    # fix delta & prior on "a"
bayes(y ~ a + b, D, list(delta=1, b=1))          # fix delta & prior on "b"


### Parameter meanings
# ---------------------------------------
# delta parameter
bayes(y ~ a, D, c(delta = 0))                    # delta=0 -> no learning
bayes(y ~ a, D, c(delta = 0.1))                  # 0.1 -> slow learning
bayes(y ~ a, D, c(delta = 9))                    # 9   -> fast learning

# prior parameter
bayes(y ~ a + b, D, c(a=1.5, b=0.5))             # prior belief: "a" more likely
bayes(y ~ a + b, D, list(priorpar=c(1.5, 0.5)))  # -- (same) --
bayes(y ~ a + b, D, c(a = 0.1, b=1.9))           # prior belief: "b" more likely
bayes(y ~ a + b, D, list(priorpar = c(0.1, 1.9)))   # -- (same) --

}
\references{
{Griffiths, T. L., & Yuille, A. (2008). Technical Introduction: A primer on probabilistic inference. In N. Chater & M. Oaksford (Eds.), \emph{The Probabilistic Mind: Prospects for Bayesian Cognitive Science (pp. 1 - 2)}. Oxford University Press. \url{https://doi.org/10.1093/acprof:oso/9780199216093.003.0002}}

{Tauber, S., Navarro, D. J., Perfors, A., & Steyvers, M. (2017). Bayesian models of cognition revisited: Setting optimality aside and letting data drive psychological theory. \emph{Psychological Review, 124(4)}, 410 - 441. \url{http://dx.doi.org/10.1037/rev0000052}}
}
\author{
Jana B. Jarecki, Markus Steiner
}
