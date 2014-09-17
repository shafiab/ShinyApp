library(shiny)
shinyUI(pageWithSidebar(
  headerPanel("EPA National Ambient Air Quality Data for 2013"),  
  sidebarPanel(
    textInput("zipcode", label = h3("Enter Zipcode"), 
              value = "95054"),
    sliderInput('radius', 'Radius',value = 40, min = 1, max = 100, step = 1,)
  ),
  mainPanel(
    h2("Pollutant Level"),
    verbatimTextOutput("city"),verbatimTextOutput("state"),
    verbatimTextOutput("radius"),
    tableOutput('result'),
    h5("Ozone is ppm, and PM2.5 in ug/m3"),
    p(em("Documentation:",a("Help Guide",href="documentation.html")))
    
  )
  
)
)