# ==========================================================================
# Package: Cognitivemodels
# File: model-utility.R
# Author: Jana B. Jarecki
# ==========================================================================

# ==========================================================================
# Cognitive Model
# ==========================================================================


#' Utility Function Models
#' 
#' @rdname utility
#' 
#' @description
#' \code{utility()} fits utility models.
#' 
#' * \code{utility_pow_c()} fits a power utility for continuous responses.
#' * \code{utility_pow_d()} fits a power utility for discrete respoonses.
#' 
#' @param formula A formula specifying responses ~ values (e.g, \code{y ~ x1 | x2}).
#' @param type (optional) A string, which utility function to use; currently available is only \code{"power"} for power utility.
#' @inheritParams Cm
#' @return A model object of class "utility", which can be viewed with `summary(.)` or `anova(.)`; predictions can be made with `predict(.)`.
#' @section Parameter Space:
#' \tabular{lcrcllr}{\verb{   } \tab \strong{Name} \tab \verb{    }\strong{LB} \tab  \strong{-} \tab \strong{UB}\verb{    } \tab \strong{Description} \tab \strong{Start Value}\cr
#' 
#' \verb{   } Power \tab \code{rp} \tab  \eqn{-}20* \tab  - \tab  20 \tab  Exponent for positive \eqn{x \ge 0}. Values < 0 yield concavity, 0 logarithm, > 0 convexity \tab  1\cr
#' 
#' \verb{   } \tab \code{rn} \tab  \eqn{-}20* \tab  - \tab 20 \tab  Exponent for negative \eqn{x < 0;}\tab  1
#' }
#' \verb{   }*\emph{Note}, the lower bound is 0.001 if \eqn{x} contains positive \emph{and} negative values (see Wakker, 2008).
#' @details  
#' _Power Utility_ **`utility_pow_.()`**. The utility \eqn{U(x)} for positive outcomes, \eqn{x > 0}, is \eqn{x^r if r > 0}, and is \eqn{log(x) if r = 0}, and is \eqn{-x^r if r < 0}. The utility for negative outcomes \eqn{x} equals \eqn{-U(-x)} with a separate exponent r (Wakker, 2008). The exponent is called `rp` and `rn` for positive and negative outcomes, respectively. To fit the model with only one exponent parameter, which is not recommended for mixed outcomes, set `fix = list(rp = "rn")`. 
#' 
#' @references {Wakker, P. P. (2008). Explaining the characteristics of the power (CRRA) utility family. \emph{Health Economics, 17(12)}, 1329-1344. doi:[10.1002/hec.1331](htrps://doi.org/10.1002/hec.1331)}
#' 
#' {Tversky, A. (1967). Utility theory and additivity analysis of risky choices. \emph{Journal of Experimental Psychology, 75(1)}, 27-36. doi:[10.1037/h0024915](htrp://dx.doi.org/10.1037/h0024915)}
#' 
#' @examples 
#' #  No examples yet
#' 
#' @export
utility_pow_d <- function(formula, data, fix = list(), choicerule, discount = 0, options = list(), ...) {
  .args <- as.list(rlang::call_standardise(match.call())[-1])
  .args[["type"]] <- "power"
  .args[["mode"]] <- "discrete"
  return(do.call(what = Utility$new, args = .args, envir = parent.frame()))
}

#' Utility Function Models
#' @rdname utility 
#' @export
utility_pow_c <- function(formula, data, fix = list(), discount = 0, options = list(), ...) {
  .args <- as.list(rlang::call_standardise(match.call())[-1])
  .args[["type"]] <- "power"
  .args[["mode"]] <- "continuous"
  return(do.call(what = Utility$new, args = .args, envir = parent.frame()))
}



#' Utility Models
#' 
#' @noRd
utility_exp <- function(formula, data, fix = list(), choicerule = NULL, mode = NULL, discount = 0, options = list(), ...) {
  .args <- as.list(rlang::call_standardise(match.call())[-1])
  .args[["type"]] <- "exponential"
  return(do.call(what = Utility$new, args = .args, envir = parent.frame()))
}

# This is the back-end class for the utility models
Utility <- R6Class("utility",
  inherit = Cm,
  public = list(
    type = NULL,
    initialize = function(formula, data = data.frame(), type = c("power", "exponential"), fix = list(), choicerule = "none", mode = c("continuous", "discrete"), discount = 0, options = list(), ...) {
      self$type <- match.arg(type)
      super$initialize(
        formula = formula,
        data = data,
        title = paste(self$type, "utility"),
        parspace = self$make_parspace(formula, data),
        choicerule = choicerule,
        mode = match.arg(mode),      
        fix = fix,
        discount = discount,
        options = options,
        ...)
    },
    make_parspace = function(formula, data = NULL, type = self$type) {
      if (type == "power") {
        lb <- -20
        if (length(data)) {
          i <- super$get_input(formula, data)
          lb <- if (min(i) < 0L & max(i) > 0L) { 0.0001 } else { -20 }
        }
        return(make_parspace(rp = c(lb, 20, 1, 1),
                             rn = c(lb, 20, 1, 1)))
      } else if (type == "exponential") {
        return(make_parspace(r = c(0.001, 20, 1, 1)))
      }
    },
    make_prediction = function(response = c("response"), input, ...) {
      par <- self$get_par()
      type <- self$type
      if (type == "power") {
        rp <- par["rp"]
        rn <- par["rn"]
        # Utility:
        # -------------------------------------
        #                   x^rp      if rp > 0
        # u(x | x >= 0) =  log(x)     if rp = 0
        #                   -x^rp     if rp < 0
        #
        #                   -x^rp     if rn > 0
        # u(x | x <  0) =  log(x)     if rn = 0
        #                   x^rp      if rn < 0
        #
        # Note: we're using the fact that x^0  = 1 below
        # Note: use sign(r) because  -x^r returns NA for very small r < 0
        res <- replace(
            x = (sign(rp) * input^rp)^(rp != 0L) * (log(input)^(rp == 0L)),
            list = (input < 0),
            values = -((-1)^(rn < 0L) * ((-1L*input[input < 0L])^rn)^(rn != 0L) * log(input)^(rn == 0L))
            )
      } else if (type == "exponential") {
        r <- par["r"]
        # Utility:
        # -------------------------------------
        #                   1 - exp(-rx)  if r > 0
        # u(x | x >= 0) =   x             if = 0 
        #                   exp(-rx)      if r < 0
        # Note: we're using the fact that x^0  = 1 below
        # Note: use sign(rp) because  -x^a returns NA for very small a < 0
        res <-  (sign(rp) + sign(rp) * -exp(-r * input))^(rp != 0L) * input^(rp==0L)
      }
      return(replace(res, res == -Inf, min(res[res>-Inf])-1))
    }
    ),

  private = list(
    init_fix = function(fix = list()) {
      # Switches off the rp parameter if all input is > 0
      # Switches off the rn parameter if all input is < 0
      if (!length(self$input)) { super$init_fix(fix = fix); return() }
      if (min(self$input) > 0L) {
        fix[["rn"]] <- NA
      } else if (max(self$input) < 0L) {
        fix[["rp"]] <- NA
      }
      super$init_fix(fix = fix)
    },
    make_prednames = function() {
      return(self$stimnames)
    }
  )
)
