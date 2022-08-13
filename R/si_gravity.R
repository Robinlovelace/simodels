si_gravity <- function(O_i, D_j, C_ij, flows, data,
                       mu = 1, alpha = 1, beta = -1){
  
  data = data %>% 
    dplyr::mutate(
      # Sum all flows from Origins to Destinations
      total_flows = sum({{flows}}),
      
      # Influence of scaling parameters on model variables
      Oi_mu = {{O_i}}^mu,
      Dj_alpha = {{D_j}}^alpha,
      Cij_beta = {{C_ij}}^beta,
      
      # Calculate unscaled flows Tij
      T_ij = Oi_mu * Dj_alpha * Cij_beta,
      
      # Calculate constrain parameter k
      k = total_flows / sum(T_ij),
      
      # Calculate flows based on total unconstrained model
      T_ij = T_ij * k)
  
  return(data %>% dplyr::select(-c(Oi_mu, Dj_alpha, Cij_beta, k, total_flows)))
  
  
  
}