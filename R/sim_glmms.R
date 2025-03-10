# Replace NAs with 0
od_joined <- od_joined %>% mutate_all(~replace(., is.na(.), 0))

library(glmmTMB)

# Calculate row and column sums
origin_totals <- tapply(od_joined$origin_n_o, od_joined$O, mean, na.rm = TRUE)
destination_totals <- tapply(od_joined$destination_n_d, od_joined$D, mean, na.rm=TRUE)

# Function for plots and model predictions
model_assessment <- function(model, data, index_yvar){
  data$predicted = predict(model,
                                newdata=data, type="response", 
                                allow.new.levels=TRUE)
  # data$predicted = fitted(model)
  #cdatasubmat2 <- dcast(data, O ~ D, sum, value.var = "predicted", margins=c("O", "D"))
  
  plot(data$n_observed, data$predicted)
  r2_p = cor(data$predicted,data[,index_yvar])^2
  
  origin_totals_o <- tapply(data[,index_yvar], data$O, sum, na.rm = TRUE)
  destination_totals_o <- tapply(data[,index_yvar], data$D, sum, na.rm=TRUE)
  
  origin_totals_p <- tapply(data$predicted, data$O, sum, na.rm = TRUE)
  destination_totals_p <- tapply(data$predicted, data$D, sum, na.rm=TRUE)
  
  plot(origin_totals_o, origin_totals_p)
  r2_o = cor(origin_totals_o,origin_totals_p)^2
  
  plot(destination_totals_o, destination_totals_p)
  r2_d = cor(destination_totals_o, destination_totals_p)^2

  cat("r2 predicted is ",r2_p, " r2 origin is ", r2_o, " r2 destination is ", r2_d )
}


# Unconstrained model

## ZINB
nb_model_unconstrained = glmmTMB(n_observed ~ log(origin_n_o) + 
                     log(destination_n_d) + 
                     log(distance_euclidean),
        zi = ~., 
        family=nbinom2,  data=od_joined)

summary(nb_model_unconstrained)
model_assessment(nb_model_unconstrained, od_joined, 7)

## Poisson Model
poisson_model_unconstrained <- glmmTMB(n_observed ~ log(origin_n_o) + 
                           log(destination_n_d) + 
                           log(distance_euclidean),
                         family=poisson,  data=od_joined)

summary(poisson_model_unconstrained)
model_assessment(poisson_model_unconstrained, od_joined,7)

## Poisson Model with random effects
poisson_model_unconstrained_r <- glmmTMB(n_observed ~ log(origin_n_o) + 
                                         log(destination_n_d) + 
                                         log(distance_euclidean)+(1|D),
                                       family=poisson,  data=od_joined)

summary(poisson_model_unconstrained_r)
model_assessment(poisson_model_unconstrained_r, od_joined,7)

## Hurdle Poisson model
hurdle_unconstrained <- glmmTMB(n_observed ~ log(origin_n_o) + 
                                   log(destination_n_d) + 
                                   (distance_euclidean),
                                 zi = ~., 
                                 family=truncated_poisson,  data=od_joined)
summary(hurdle_unconstrained)                         
model_assessment(hurdle_unconstrained, od_joined,7)

## Hurdle Poisson model with random effects
hurdle_unconstrained_r <- glmmTMB(n_observed ~ log(origin_n_o) + 
                                  log(destination_n_d) + 
                                  log(distance_euclidean)+(1|O+D),
                                zi = ~log(origin_n_o) + 
                                  log(destination_n_d) + 
                                  log(distance_euclidean), 
                                family=truncated_poisson,  data=od_joined)
summary(hurdle_unconstrained_r)                         
model_assessment(hurdle_unconstrained_r, od_joined,7)

################## DOUBLY CONSTRAINT #####################
##########################################################

# Add offset terms to the data

od_joined$origin_offset <- (origin_totals[od_joined$O])
od_joined$destination_offset <- (destination_totals[od_joined$D])

# Fit the Poisson model with offsets
poisson_model_constrained = glmmTMB(n_observed ~ 
                                 #log(origin_n_o) + 
                                 #log(destination_n_d) + 
                                 log(distance_euclidean)+
                                 offset(log(origin_offset)) + 
                                 offset(log(destination_offset)),
                   family=poisson,  
                   data=od_joined)
summary(poisson_model_constrained)
model_assessment(poisson_model_constrained, od_joined,7)

# Fit the Poisson model with offsets and random effects
poisson_model_constrained_r = glmmTMB(n_observed ~ 
                                      #log(origin_n_o) + 
                                      #log(destination_n_d) + 
                                      log(distance_euclidean)+
                                      offset(log(origin_offset)) + 
                                      offset(log(destination_offset))+
                                        (log(origin_n_o)|O+D),
                                    family=poisson,  
                                    data=od_joined)
summary(poisson_model_constrained_r)
model_assessment(poisson_model_constrained_r, od_joined,7)


###### YORK ####
###### 
names(od_res)
poisson_model_constrained_r = lme4::lmer(log(trips) ~ 
                                        log(origin_f0_to_15) + 
                                        log(destination_n_pupils) + 
                                        log(distance_euclidean)+
                                        (1|O)+(1|D),
                                      data=od_res)
summary(poisson_model_constrained_r)
exp(predict(poisson_model_constrained_r, od_res))

plot(exp(predict(poisson_model_constrained_r, od_res)), od_res$trips)

model_assessment(poisson_model_constrained_r, od_res,22)

poisson_model_constrained_r = robustlmm::rlmer(log(trips) ~ 
                                           log(origin_f0_to_15) + 
                                           log(destination_n_pupils) + 
                                           log(distance_euclidean)+
                                           (1|O)+(1|D),
                                         data=od_res)
summary(poisson_model_constrained_r)
exp(predict(poisson_model_constrained_r, od_res))

plot(exp(predict(poisson_model_constrained_r, od_res)), od_res$trips)

model_assessment(poisson_model_constrained_r, od_res,22)
