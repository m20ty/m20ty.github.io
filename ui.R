library(shiny)

shinyUI(fluidPage(
    
    titlePanel('Test your French!'),
    
    sidebarLayout(
        sidebarPanel(
            textInput('translation', 'Translation:', value = ''),
            actionButton('submit', 'Submit'),
            checkboxGroupInput(
                inputId = 'categories',
                label = 'Categories',
                choices = character(0)
            )
        ),
        
        mainPanel(
            h3(textOutput('prompt')),
            h4(htmlOutput('response')),
            actionButton('reveal', 'Reveal'),
            actionButton('nxt', 'Next')
        )
    )
))
