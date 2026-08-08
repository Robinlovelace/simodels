# Furness balancing functions

#' Furness Balance a matrix
#'
#' Furness balancing fills a matrix when only the row and column sums are known. 
#'
#' @param mat matrix of numeric values e.g. `matrix(rep(1, 6), nrow = 3)`
#' @param rsum vector of desired row sums without NAs
#' @param csum vector of desired column sums without NAs
#' @param n number of iterations of balancing
#' @param check logical (default TRUE) check if output is valid
#' @param int_only logical (default FALSE) only return whole numbers
#' @param quiet logical if FALSE extra messages
#' @return A vector of rounded numeric
#' @export
#' @example 
#' mat = matrix(rep(1, 6), nrow = 3) 
#' rownames(mat) = c("car","bike","other") 
#' colnames(mat) = c("company","private") 
#' rsum = c(32,15,10) 
#' csum = c(4, 53) 
#' furness_partial(mat, rsum, csum)
furness_balance <- function(mat, rsum, csum, n = 100, check = TRUE, int_only = FALSE, quiet = TRUE){
  
  rname <- rownames(mat)
  cname <- colnames(mat)
  
  # Get scale about right
  mat <- mat / (sum(mat, na.rm = TRUE) / sum(rsum))
  #mat_orig = mat
  
  for(i in seq_len(n)){
    mat <- bal_func(mat, rsum = rsum, csum = csum, int_only = int_only)
    if(i == 1 & quiet){
      message("First pass")
      print(summary(rowSums(mat, na.rm = TRUE) - rsum))
    }
    if(i == n & quiet){
      message("Last pass")
      print(summary(rowSums(mat, na.rm = TRUE) - rsum))
    }
  }
  
  
  rownames(mat) <- rname
  colnames(mat) <- cname
  
  # Check
  if(check){
    if(!all(rowSums(mat_fin) == rsum)){
      print("\n")
      print(mat)
      print(rsum)
      print(csum)
      stop("Rows don't match ",i)
    }
    if(!all(colSums(mat_fin) == csum)){
      print("\n")
      print(mat)
      print(rsum)
      print(csum)
      stop("Cols don't match ",i)
    }
  }
  
  return(mat)
}




#' Furness Balance a partial matrix
#'
#' Furness balance a matrix  when some values are missing, a version of a
#' version of Furness balancing when the matrix values are partially known 
#'
#' @param mat matrix of numeric values can contain NAs
#' @param rsum vector of row sums without NAs
#' @param csum vector of column sums without NAs
#' @param n number of iterations of balancing
#' @param check logical (default TRUE) check if output is valid
#' @param int_only logical (default TRUE) only return whole numbers
#' @return A vector of rounded numeric
#' @export
#' @example 
#' mat = matrix(c(NA,0,NA,32,NA,NA), nrow = 3) 
#' rownames(mat) = c("car","bike","other") 
#' colnames(mat) = c("company","private") 
#' rsum = c(32,15,10) 
#' csum = c(4, 53) 
#' furness_partial(mat, rsum, csum)
furness_partial <- function(mat, rsum, csum, n = 100, check = TRUE, int_only = TRUE){

  rname <- rownames(mat)
  cname <- colnames(mat)

  mat_change <- is.na(mat)
  mat_change <- ifelse(mat_change, 1, NA)

  rsum_change = rsum - rowSums(mat, na.rm = TRUE)
  csum_change = csum - colSums(mat, na.rm = TRUE)

  # Get scale about right
  mat_change <- mat_change / (sum(mat_change, na.rm = TRUE) / sum(rsum_change))
  mat_change_orig <- mat_change
  i <- 1
  while(i < n){
    i <- i + 1
    mat_old <- mat_change
    mat_change <- bal_func(mat2 = mat_change,
                           rsum2 = rsum_change,
                           csum2 = csum_change,
                           int_only = int_only)
    # Are we stuck in a loop?
    if(identical(mat_old, mat_change)){
      mat_change <- bal_func(mat2 = mat_change_orig,
                             rsum2 = rsum_change,
                             csum2 = csum_change,
                             int_only = int_only)
      #message("Stuck in loop")
    }
    #print(mat_change)

    # Check
    if(all(rowSums(mat_change, na.rm = TRUE) == rsum_change)){
      if(all(colSums(mat_change, na.rm = TRUE) == csum_change)){
        break
      }
    }

  }
  mat_change <- round(mat_change)

  mat_fin = ifelse(is.na(mat), mat_change, mat)


  # Check
  if(check){
    if(!all(rowSums(mat_fin) == rsum)){
      print("\n")
      print(mat)
      print(rsum)
      print(csum)
      stop("Rows don't match ",i)
    }
    if(!all(colSums(mat_fin) == csum)){
      print("\n")
      print(mat)
      print(rsum)
      print(csum)
      stop("Cols don't match ",i)
    }
  }


  return(mat_fin)
}





#' Fill an incomplete matrix when some totals are unknown
#'
#' Fill a matrix from row and column totals with some missing values. Sometimes
#' you can have a matrix with some missing values (e.g. small values suppressed
#' for privacy), this function will infill missing NA values in a matrix based
#' on row and column sums that can also contain NA values and a total value that
#' can't be NA.
#'
#'
#' @param mat matrix of numeric values with some NAs
#' @param rsum vector of row sums (can contain NAs)
#' @param csum vector of column sums (can contain NAs)
#' @param tt desired sum of matrix
#' @return A filled in matrix
#' @export
#' @example 
#' mat = matrix(c(0,0,NA,32,15,6), nrow = 3) 
#' rownames(mat) = c("car","bike","other") 
#' colnames(mat) = c("company","private") 
#' rsum = c(32,15,10) 
#' csum = c(NA, 53) 
#' tt = 57 
#' matrix_fill_incomplete(mat, rsum,csum, 57)

matrix_fill_incomplete <- function(mat, rsum, csum, tt){

  rname <- rownames(mat)
  cname <- colnames(mat)

  # Generate combinations of number that sum to total
  n_gaps = sum(is.na(mat))
  combinations = generate_combinations(tt - sum(mat, na.rm = TRUE), n_gaps)

  combinations_mat <- list()
  na_indices <- which(is.na(mat))
  for(i in seq(1, length(combinations))){
    mat_sub <- mat
    mat_sub[na_indices] <- combinations[[i]]

    rsum_mat <- rowSums(mat_sub)
    csum_mat <- colSums(mat_sub)

    if(!all(rsum_mat == rsum, na.rm = TRUE)){
      mat_sub <- NULL
    }
    if(!all(csum_mat == csum, na.rm = TRUE)){
      mat_sub <- NULL
    }
    combinations_mat[[i]] <- mat_sub
  }

  combinations_mat <- combinations_mat[lengths(combinations_mat) > 0]
  mat_fin <- combinations_mat[[sample(seq_along(combinations_mat), 1)]]

  return(mat_fin)
}

#' Generate combinations of number that sum to totals
#'
#' Internal function that returns rounded numbers sometimes rounded up sometimes
#' rounded down
#'
#' @param t numbers to split
#' @param n numeric of number of splits required
#' @param prefix numeric()
#' @return list of combinations 
#' @examples 
#' generate_combinations(5,3)
#' @noRd
generate_combinations <- function(t, n, prefix = numeric()) {
  result <- list()
  if (n == 1) {
    if (t > 0) {
      result <- list(c(prefix, t))
    }
  } else {
    if (n < 1 || t <= 0) return(list())
    for (i in t:1) {
      temp <- generate_combinations(t - i, n - 1, c(prefix, i))
      result <- c(result, temp)
    }
  }
  return(result)
}





#' Round numbers randomly up or down
#'
#' Internal function that returns rounded numbers sometimes rounded up sometimes
#' rounded down
#'
#' @param x Vector of numeric
#' @return A vector of rounded numeric 
#' @noRd

round_half_random <- function(x) {
  tweaks <- runif(length(x), min = -0.5, max = 0.5)
  # Never tweak to 0
  tweaks <- ifelse(x < 1, 0, tweaks)
  round(x + tweaks)
}

#' Internal balancing function
#'
#' 
#'
#' @param mat2 matrix of numeric
#' @param rsum2 vector of row sums
#' @param csum2 vector of column sums
#' @param int_only logical (default FALSE) only return whole numbers
#' 
#' @return a matrix
#' @noRd
bal_func <- function(mat2, rsum2, csum2, int_only = FALSE){
  # Find ratio of rows
  mat_rsum <- rowSums(mat2, na.rm = TRUE)
  mat_rratio <- rsum2 / mat_rsum
  mat_rratio[is.nan(mat_rratio)] <- 0
  
  mat2 <- mat2 * mat_rratio
  
  if(int_only){
    mat2 <- round_half_random(mat2)
  }
  
  # Find ratio of columns
  mat_csum <- colSums(mat2, na.rm = TRUE)
  mat_cratio <- csum2 / mat_csum
  mat_cratio[is.nan(mat_cratio)] <- 0
  
  mat2 <- sweep(mat2, MARGIN=2, mat_cratio, `*`)
  mat2[is.nan(mat2)] <- 0
  
  if(int_only){
    mat2 <- round_half_random(mat2)
  }
  
  return(mat2)
}
