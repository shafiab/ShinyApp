library(shiny)
library(UsingR)

d <- read.csv("annual_all_2013.csv")
sub <- subset(d, Parameter.Name %in% c("PM2.5 - Local Conditions", "Ozone")
              & Pullutant.Standard %in% c("Ozone 8-Hour 2008", "PM25 Annual 2006"),
              c(Longitude, Latitude, Parameter.Name, Arithmetic.Mean))

pollavg <- aggregate(sub[, "Arithmetic.Mean"],
                     sub[, c("Longitude", "Latitude", "Parameter.Name")],
                     mean, na.rm = TRUE)
pollavg$Parameter.Name <- factor(pollavg$Parameter.Name, labels = c("ozone", "pm25"))
names(pollavg)[4] <- "level"

## Remove unneeded objects
rm(d, sub)

## Write function
monitors <- data.matrix(pollavg[, c("Longitude", "Latitude")])

ZIP = read.csv("zipcode.csv")


library(fields)


shinyServer(
  
  function(input, output) {
    
    output$city<-renderText({
      zipcode<-input$zipcode
      cityName<-"City : "
      city<-toString(ZIP$city[ZIP$zip==zipcode])
      if (length(city)==0)
      {
        city<-c(cityName)
      }
      city<-c(cityName,city)
    })
    
    output$state<-renderText({
      zipcode<-input$zipcode
      stateName<-"State : "
      
      state<-toString(ZIP$state[ZIP$zip==zipcode])
      if (length(state)==0)
      {
        state<-c(stateName)
      }
      state<-c(stateName, state)
    })
    
    output$radius<-renderText({
      textName<- c("within a radius of ",input$radius," mile, the pollutant level is as follows:")
      textName
    })
    
    
    output$result<-renderTable({
      zipcode<-input$zipcode
      city<-ZIP$city[ZIP$zip==zipcode]
      radius<-input$radius
      
      result<-data.frame("Ozone" =0, "PM25" = 0)

      
      if (length(city)!=0)      
      {
        latitude<-ZIP$latitude[ZIP$zip==zipcode]
        longitude<-ZIP$longitude[ZIP$zip==zipcode]
        res<-pollutant(data.frame(lat=latitude, lon = longitude, radius=radius))
        result<-data.frame("Ozone" =res$ozone, "PM25" = res$pm25)
      }
      result    
    })
      
  }
)

pollutant <- function(df) {
  x <- data.matrix(df[, c("lon", "lat")])
  r <- df$radius
  plot(1:r)
  d <- rdist.earth(monitors, x)
  use <- lapply(seq_len(ncol(d)), function(i) {
    which(d[, i] < r[i])
  })
  levels <- sapply(use, function(idx) {
    with(pollavg[idx, ], tapply(level, Parameter.Name, mean))
  })
  dlevel <- as.data.frame(t(levels))
  data.frame(df, dlevel)
  
}

