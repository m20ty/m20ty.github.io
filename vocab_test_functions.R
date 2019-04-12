languages = c('english', 'french')

# To do:

# Add functionality to replace any empty strings in the weight column with '1's.

# When the user gets the correct translation, perhaps we also want to display the
# alternative correct translations.

# Maybe we also want to make the sampling done from all words apart from the word that
# was previously chosen, so we don't get the same word twice in a row.





choose_word <- function(dt) {
    
    # Choose a language to translate from:
    
    from_lang <- sample(languages, 1)
    
    # Before we start, make sure that each unique word/phrase in our chosen language
    # has a unique probability weight associated with it.
    
    if(
        dt[
            ,
            .(unique_weights = length(unique(weight))),
            by = eval(from_lang)
        ][
            unique_weights > 1,
            .N
        ] > 0
    ) {
        dt[
            ,
            weight := max(weight),
            by = eval(from_lang)
        ]
    }
    
    # Choose a word by sampling with probability weights:
    
    word <- dt[
        ,
        .(weight = unique(weight)),
        by = eval(from_lang) # If we use get() instead of eval(), data.table makes the
        # column name "get" - not sure why, and I think it might cause an error.
    ][
        ,
        sample(
            get(from_lang), # keep getting error 'invalid first argument'.
            1,
            prob = weight
        )
    ]
    
    list(word = word, from_lang = from_lang)
    
}





make_prompt <- function(chosen_word, dt) {
    
    # Create the string to be presented to the user.
    
    paste0(
        chosen_word$word,
        '\n[',
        paste(
            dt[
                get(chosen_word$from_lang) == chosen_word$word,
                unique(type)
            ],
            collapse = '/'
        ),
        ']'
    )
    
}





check_translation <- function(user_response, chosen_word, dt) {
    
    if(
        user_response == ''
    ) {
        2
    } else if(
        user_response %in% dt[
            get(chosen_word$from_lang) == chosen_word$word,
            get(languages[languages != chosen_word$from_lang])
        ]
    ) {
        1
    } else {
        0
    }
    
}





make_response <- function(check, chosen_word, dt) {
    
    if(check == 2) {
        ''
    } else if(check == 3) {
        c(
            'The correct translations are:<br>',
            paste(
                dt[
                    get(chosen_word$from_lang) == chosen_word$word,
                    get(languages[languages != chosen_word$from_lang])
                ],
                collapse = ', '
            )
        )
    } else if(check == 1) {
        'Correct!'
    } else {
        c(
            'Sorry, that is not a correct translation.  The correct translations are:<br>',
            paste(
                dt[
                    get(chosen_word$from_lang) == chosen_word$word,
                    get(languages[languages != chosen_word$from_lang])
                ],
                collapse = ',\n'
            ),
            '</br>'
        )
    }
    
}





adjust_prob <- function(check, chosen_word, dt) {
    
    if(check %in% c(0, 3)) {
        dt[
            get(languages[languages != chosen_word$from_lang]) %in%
                dt[
                    get(chosen_word$from_lang) == chosen_word$word,
                    get(languages[languages != chosen_word$from_lang])
                ],
            weight := weight*2L # Adding'L' stops a warning about column being stored
            # more efficiently as integer...  Can't reproduce this warning with small
            # data table.
        ]
    } else if(check == 1){
        dt[
            get(languages[languages != chosen_word$from_lang]) %in%
                dt[
                    get(chosen_word$from_lang) == chosen_word$word,
                    get(languages[languages != chosen_word$from_lang])
                ] &
                weight > 1L,
            weight := weight/2L # Warning doesn't appear here when running the app, but
            # does if you run the code in the console...  But not with a small data
            # table...  So I don't really understand its origin.
        ]
    }
    
}
