library(covidHubUtils)
timezeros_novjan <- seq(from = as.Date("2020-11-01") , to = as.Date("2021-2-01"), by="days") 

truth_data_novjan <- load_truth(truth_source = "JHU", 
                                target_variable = "inc case",
                                truth_end_date = "2020-12-31", 
                                locations = c("12", "48", "25", "36", "06", "26"))

forecasts_data_novjan <- load_forecasts(models = c("COVIDhub-baseline", "CU-select", 
                                                   "OliverWyman-Navigator", "LANL-GrowthRate",
                                                   "IowaStateLW-STEM", "JHU_IDD-CovidSP", "UVA-Ensemble", "JHUAPL-Bucky"), 
                                        forecast_dates = timezeros_novjan,
                                        locations = c("12", "48", "25", "36", "06", "26"), 
                                        targets = paste(1:4, "wk ahead inc case"), 
                                        hub = "US")

scored_forecasts_novjan <- score_forecasts(forecasts = forecasts_data_novjan, 
                                           truth=truth_data_novjan, 
                                           return_format = "wide")

forecasts_data_unique_novjan <-  forecasts_data_novjan %>%
  mutate(sat_fcast_week = as.Date(calc_target_week_end_date(forecast_date, horizon = 0))) %>%
  group_by(model, location, sat_fcast_week, horizon, quantile) %>%
  mutate(forecast_in_wk = row_number(), 
         last_forecast_in_wk = forecast_in_wk == max(forecast_in_wk)) %>% 
  filter(last_forecast_in_wk) %>%
  ungroup()
