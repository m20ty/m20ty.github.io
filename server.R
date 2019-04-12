library(shiny)
library(data.table)

source('vocab_test_functions.R')





shinyServer(function(input, output, session) {
    
    
    english_french <- fread('english_french.csv')
    
    
    updateCheckboxGroupInput(
        session = session,
        inputId = 'categories',
        label = 'Categories',
        choices = sort(
            plyr::mapvalues(
                unique(english_french$category),
                '',
                'Uncategorised'
            )
        ),
        selected = sort(
            plyr::mapvalues(
                unique(english_french$category),
                '',
                'Uncategorised'
            )
        )
    )
    
    
    categories_subset <- reactive({
        plyr::mapvalues(
            input$categories,
            'Uncategorised',
            '',
            warn_missing = FALSE # Prevent warning in case Uncategorised is not ticked
        )
    })
    
    # Problem with this:
    
    # This doesn't seem to work so well in choose_word(), because data.table seems to
    # think there's a by argument, for some reason.  I think this is what causes the
    # error which initially flashes up on the screen, before a word is displayed.  I think
    # this comes from choose_word(), and the error is: Warning: Error in [.data.table:
    # 'by' appears to evaluate to column names but isn't c() or key().  Weirdly, this
    # error appears when you select only the 'food & drink' category and press 'Next'.
    
    # UPDATE: I think I fixed the above error by changing some get() calls to eval()
    # calls.  But now I have another error: on startup it says "Error in sample.int:
    # invalid first argument".  I don't know how to fix this.  I also wonder whether
    # stuff is happening in the wrong order: is categories_subset defined in time for
    # chosen_word?
    
    # FURTHER UPDATE: this error appears only momentarily if I remove the isolate()
    # from categories_subset() - it is immediately replaced by a prompt.  So I think
    # the problem is that choose_word() is called at the very beginning, before
    # categories_subset() is defined, then, since categories_subset() is isolated,
    # it doesn't react to the change in categories_subset().  I tried to fix this with
    # an if statement and exists(), so that if categories_subset() is not defined it
    # can take the whole data table.  But this doesn't help, because then it responds
    # to a change in category unless you use isolate(), but then you're back to square
    # one!  It also doesn't help to put input$nxt in the reactive environment defining
    # categories_subset.
    
    
    
    # The following apparently fixed the problem with the stuff after it, wherein an
    # error would come up on startup.  Using eventReactive() seems to allow you to
    # specify exactly what you want it to react to (the first argument in the function
    # call), so it doesn't react to categories_subset() and you don't need to use
    # isolate().  But it also doesn't seem to react to the change of input$nxt from
    # NULL to 0 on startup.
    
    chosen_word <- eventReactive(input$nxt, {
        choose_word(
            english_french[
                category %in% categories_subset()
            ]
        )
    })
    
    # The below reacts to a change in input$nxt, which occurs when the user clicks
    # 'Next'.  (Note this also changes the value of check to 2, but this doesn't
    # directly impact chosen_word - it only stimulates setting the response to the empty
    # string).  A change in input$nxt also occurs on startup - it changes from NULL to 0
    # (see the example in ?actionButton).
    
    # chosen_word <- reactive({
    #     
    #     input$nxt # Putting input$nxt here makes chosen_word react to input$nxt.
    #     
    #     choose_word(
    #         english_french[
    #             category %in% isolate(categories_subset())
    #             # Using isolate() stops chosen_word() and make_response() reacting
    #             # to a change of categories.
    #         ]
    #     )
    #     
    # })
    
    
    # I think the following two steps could be made into one: we could put the call to
    # make_prompt directly into renderText().  Try it!
    
    prompt_text <- reactive({
        make_prompt(
            chosen_word(),
            english_french
        )
    })
    
    
    output$prompt <- renderText(prompt_text())
    
    
    # Making check a reactive value means that other functions can respond to it whenever
    # it changes, i.e. it turns check into a reactive conductor.  Setting check = 2 in
    # the call to reactiveValues simply sets an initial value.
    
    check <- reactiveValues(check = 2)
    
    
    observeEvent(input$submit, {
        
        check$check <- check_translation(
            input$translation,
            chosen_word(),
            english_french
        )
        
        adjust_prob(
            check$check,
            chosen_word(),
            english_french
        )
        
    })
    
    observeEvent(input$reveal, {
        
        check$check <- 3
        
        adjust_prob(
            check$check,
            chosen_word(),
            english_french
        )
        
    })
    
    observeEvent(input$nxt, {
        check$check <- 2
    })
    
    
    response <- reactive({
        make_response(
            check$check,
            chosen_word(),
            english_french
        )
    })
    
    # The following apparently has to be done inside a reactive context.  I'm not sure
    # why, because nothing else responds reactively to it.  Perhaps I could put it inside
    # two of the observeEvent() calls instead (specifically the first two - we don't need
    # it when check$check is assigned the value 2).
    
    # reactive({
    #     adjust_prob(
    #         check$check,
    #         chosen_word(),
    #         english_french
    #     )
    # })
    
    # Note than when check is changed to 2, as it is whenever the user clicks 'Next', the
    # adjust_prob() function shouldn't do anything, i.e. no weights are changed.  They are
    # only changed immediately after 'Submit' or 'Reveal' is clicked.
    
    
    output$response <- renderText(response())
    
    
    # The below writes english_french to file when the user session ends, in order to
    # preserve the probability weights that the user accumulated during the session.
    
    session$onSessionEnded(
        function() {
            fwrite(english_french, 'english_french.csv')
        }
    )
    
    
})
