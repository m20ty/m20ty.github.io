library(shiny)
library(plotly)
library(lubridate)


#consumption_n <- fread('consumption_n.csv')
#consumption_n$GMT <- ymd_hms(consumption_n$GMT)
#consumption_n <- consumption_n[year(consumption_n$GMT) == 2013,]
#cc <- complete.cases(consumption_n[1:(nrow(consumption_n)/2), 170:270])
#consumption_n_2013cc <- consumption_n[1:(nrow(consumption_n)/2), c(1, 170:270)]
#consumption_n_2013cc <- consumption_n_2013cc[cc,]


df <- read.csv('kWh_weather.csv')
df$interval <- ymd_hms(df$interval)


shinyServer(function(input, output) {

  #vars <- reactive({
  #  c(input$temp, input$ws)
  #})
  
  #vrble <- isolate(input$variable)
  #hhlds <- isolate(input$hholds)
  
  smple <- reactive({
    input$createplot
    hhlds <- isolate(input$hholds)
    sample(names(df)[-(1:6)], hhlds)
    #isolate({
    #  sample(names(df)[-(1:6)], input$hholds)
    #})
  })
  
  tempdf <- reactive({
    vrble <- isolate(input$variable)
    hhlds <- isolate(input$hholds)
    #if(input$hholds == 1){
    if(hhlds == 1){
      cbind(df[, 'interval', drop = FALSE], df[, vrble, drop = FALSE], kWh = df[, smple()])
      #cbind(df[, input$variable, drop = FALSE], kWh = df[, smple()])
    } else {
      cbind(df[, 'interval', drop = FALSE], df[, vrble, drop = FALSE], kWh = rowSums(df[, smple()]))
      #cbind(df[, input$variable, drop = FALSE], kWh = rowMeans(df[, smple()]))
    }
  })
  
  #In the following, the condition on vrble being > -999 was only for windchill, which took some
  #values at -999, but since I've got rid of windchill I don't need this condition any more.
  
  tempmod <- reactive({
    vrble <- isolate(input$variable)
    lm(kWh ~ get(vrble), tempdf())
    #lm(kWh ~ get(vrble), tempdf()[tempdf()[, vrble] > -999, ])
  })
  
  tempplot <- reactive({
    vrble <- isolate(input$variable)
    #plot_ly(tempdf()[tempdf()[, vrble] > -999, ], x = ~get(vrble), y = ~kWh,
    #        type = 'scatter', mode = 'markers')
    plot_ly(tempdf(), x = ~get(vrble), y = ~kWh, type = 'scatter', mode = 'markers') %>%
      layout(xaxis = list(title = vrble))
    #plot_ly(tempdf(), x = ~get(input$variable), y = ~kWh, type = 'scatter')
  })
  
  #tempdf <- reactive({
  #  if(input$hholds == 1){
  #    cbind(df[, 1 + which(vars()), drop = FALSE], kWh = df[, smple()])
  #  } else {
  #    cbind(df[, 1 + which(vars()), drop = FALSE], kWh = rowMeans(df[, smple()]))
  #  }
  #})
  
  #output$text <- renderText({input$variable})
  
  output$scatterplot <- renderPlotly({
    #plot_ly(tempdf(), x = ~get(input$variable), y = ~kWh)
    vrble <- isolate(input$variable)
    tempplot()
    add_lines(tempplot(), x = ~get(vrble), y ~ fitted(tempmod()))
    #add_lines(tempplot(), x = ~get(input$variable), y ~ fitted(tempmod()))
  })
  
  output$summarytable <- renderTable({
    vrble <- isolate(input$variable)
    as.data.frame(summary(tempmod())$coefficients,
              row.names = c('Intercept', paste('Coefficient of', vrble)),
              col.names = c('Estimate', 'Std. Error', 't value', 'Pr(>|t|)'))
  }, rownames = TRUE, digits = -1)
  
  output$conclusion <- renderText({
    vrble <- isolate(input$variable)
    if(summary(tempmod())$coefficients[2,4] < 0.05) {
      paste('p = ', signif(summary(tempmod())$coefficients[2,4], 2), ', so there is a statistically 
            significant correlation between ', vrble, ' and kWh in this sample.', sep = '')
    } else {
      paste('p = ', signif(summary(tempmod())$coefficients[2,4], 2), ', so there is no correlation 
            between ', vrble, ' and kWh in this sample.', sep = '')
    }
  })
  
  tempdf_13Feb <- reactive({
    tempdf()[as.character(as.Date(tempdf()$interval)) == '2013-02-13', ]
  })
  
  output$consumptionprofile <- renderPlotly({
    plot_ly(tempdf_13Feb(), x = ~interval, y = ~kWh, type = 'scatter', mode = 'lines')
  })

  #output$plot <- reactive({
  #  if(FALSE %in% vars()) {
  #    renderPlot({
  #      plot_ly(tempdf(), x = ~df[, which(vars())], y = ~kWh)
  #    })
  #  } else {
  #    renderPlot({
  #      plot_ly(tempdf(), x = ~temp, y = ~wspd, z = ~kWh)
  #    })
  #  }
  #})
  
  #if(FALSE %in% vars()) {
  #  output$plot <- renderPlot({
  #    plot_ly(tempdf(), x = ~tempdf()[, which(vars())], y = ~kWh)
  #  })
  #} else {
  #  output$plot <- renderPlot({
  #    plot_ly(tempdf(), x = ~temp, y = ~ws, z = ~kWh)
  #  })
  #}

  
})