library(shiny)
library(plotly)
library(lubridate)


shinyUI(fluidPage(
  
  titlePanel('Correlation between weather and energy consumption'),
  h4('With this app, you can examine the relationships between different weather variables and
     aggregated electricity consumption of samples of London households equipped with "smart"
     electricity meters.'),
  h5('The electricity consumption data was collected during the Low Carbon London (LCL) trial,
     in which ~5000 London homes were fitted with smart meters and their consumption recorded at
     half-hourly intervals for a period of a year, between 2012 and 2013.  Here we use a subset
     of the LCL data, consisting of half-hourly reads from 100 households between the hours of
     7am and midnight on 136 days between January and July 2013.  The weather data for these days
     was obtained from the Weather Underground website.'),
  
  #Note I removed windchill from the radio buttons, because I think it's effectively a measure of
  #how cold the air 'feels', which obviously increases with temperature, so the correlation
  #between kWh and windchill is basically the same as that between kWh and temp.  I think what I'm
  #really interested in is the difference between temp and windchill, but this would be quite
  #tricky to deal with, and it's probably reflected in wspd anyway.
  
  sidebarLayout(
    sidebarPanel(
      h5('Create a plot of aggregate electricity consumption in kWh against your chosen weather
         variable.'),
      radioButtons('variable', 'Select variable', choices = c('Temperature' = 'temp',
                                                              'Humidity' = 'hu',
                                                              'Wind speed' = 'wspd',
                                                              'Pressure' = 'pressure')),
      h5('Use the slider to select a sample size.  When you click the "Create plots" button, a
         new sample will be taken and the electricity consumption will be summed over the
         households in this sample'),
      sliderInput('hholds', 'Number of households', 1, 100, value = 1, step = 1),
      #submitButton('Create plots')
      actionButton('createplot', 'Create plots')
    ),
    
    mainPanel(
      #textOutput('text'),
      h5('The following is a scatterplot of the aggregated electricity consumption for this sample
         against your chosen weather variable, fitted with a linear model.'),
      plotlyOutput('scatterplot'),
      h5('Summary table for this linear model:'),
      tableOutput('summarytable'),
      tags$i(h4(textOutput('conclusion'))),
      h5('The following is a line chart of the aggregated electricity consumption profile for this
         sample on Wednesday 13th February 2013, a cold winter day with an average temperature of
         1 degree Celsius.'),
      plotlyOutput('consumptionprofile')
    )
  )
))
