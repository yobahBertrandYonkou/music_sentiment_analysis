options(warn = -1)
library('stringr')
library('hunspell')
library('ds4psy')
library('glue')
library('spacyr')
library('tm')
library('dplyr',  warn.conflicts = FALSE)
library('parsedate')
library("tokenizers", warn.conflicts = FALSE)

# replacing contractions with full forms
library('textclean')
library('caret')
library("e1071")

# initializing spacyr
spacy_initialize(model = 'en_core_web_sm', virtualenv  = "/Users/yobahbertrandyonkou/spacyenv/")

# importing model
msa_model = readRDS("/Users/yobahbertrandyonkou/Downloads/D and D/classification_module/msa_model_81_lyrics_and_sentiments_only.rda")

# loading corpus
angry_corpus = readRDS("/Users/yobahbertrandyonkou/Downloads/D and D/classification_module/angry_corpus.rda")
sad_corpus = readRDS("/Users/yobahbertrandyonkou/Downloads/D and D/classification_module/sad_corpus.rda")
happy_corpus = readRDS("/Users/yobahbertrandyonkou/Downloads/D and D/classification_module/happy_corpus.rda")

classify_lyrics = function(test_lyrics){
    # replacing ’ with '
    lyrics = str_replace_all(test_lyrics, "’", "\'")

    # converting lyrics to lower case
    lyrics = tolower(lyrics)

    # removing lyrics divisions
    lyrics = str_replace_all(
            string=lyrics, 
            pattern=r"(\[(.*?)\])", 
            replacement = " "
        )

    # typo correction
    bad.words = hunspell(lyrics)

    # splitting bad words to a list of words
    bad.words = text_to_words(bad.words[1])

    # removing duplicates
    bad.words = unique(bad.words)

    # getting suggestions
    suggested.words = unlist(lapply(hunspell_suggest(unique(unlist(bad.words))), function(words) words[1]))

    # replacing bad words with suggestions
    new_lyrics = ""
    for (index in 1:length(bad.words)){
        new_lyrics = str_replace_all(
            string = lyrics, 
            pattern = glue(r"(\b{bad.words[index]}\b)"), 
            replacement = suggested.words[index]
        )
        lyrics = new_lyrics
    }
    lyrics = tolower(lyrics)

    # replacing all contractions with their full forms
    lyrics = replace_contraction(lyrics)

    lyrics = replace_internet_slang(lyrics)
    lyrics = str_replace_all(lyrics, r"(\_?\-)", " ")
    lyrics = str_replace_all(lyrics, r"(\d)", " ")
    lyrics = str_replace_all(
            string=lyrics, 
            pattern=r"(\s+)", 
            replacement = " "
        )

    # pos tagging, lematization
    # Not using transform here because it combines every thing into one long string
    important = c()
    lemmatized_lyrics = c()
    features = filter(
        spacy_parse(lyrics, tag=TRUE, pos=TRUE), 
        !(pos %in% important) & (entity == "")
    )

    lemmatized_lyrics = append(
        lemmatized_lyrics, 
        paste(features$lemma, collapse = ' ')
    )
    lyrics = lemmatized_lyrics

    # fetching english stopwords
    stopwords.list = stopwords(kind = "en")

    # removing contractions from stop words because lyrics does not have stop words
    stopwords.cleaned = tolower(replace_contraction(stopwords.list))

    for (stopword in stopwords.cleaned){
        lyrics = str_remove_all(tolower(lyrics), glue(r"(\b\s?{stopword}\b)"))
    }

    lyrics = tolower(removePunctuation(lyrics))

    lyrics = str_replace_all(
            string=lyrics, 
            pattern=r"(\s+)", 
            replacement = " "
        )

    lyrics_corpus = Corpus(VectorSource(lyrics))

    # creating a document term matrix from lyrics corpus
    get_lyrics_document_term_matrix = function(lyrics_corpus){
        return (
            removeSparseTerms(
                DocumentTermMatrix(lyrics_corpus, control = list(
                    weighting=function(x) weightTfIdf(x, normalize = TRUE)
                )), 0.95
            )
        )
    }

    lyric_with_angry_corpus = Corpus(VectorSource(c(lyrics_corpus$content, angry_corpus$content)))
    dtm_with_angry = get_lyrics_document_term_matrix(lyric_with_angry_corpus)
    lyric_with_happy_corpus = Corpus(VectorSource(c(lyrics_corpus$content, happy_corpus$content)))
    dtm_with_happy = get_lyrics_document_term_matrix(lyric_with_happy_corpus)
    lyric_with_sad_corpus = Corpus(VectorSource(c(lyrics_corpus$content, sad_corpus$content)))
    dtm_with_sad = get_lyrics_document_term_matrix(lyric_with_sad_corpus)

    # converting dtm to matrix
    get_lyrics_dtm_matrix = function(lyrics_document_term_matrix) as.matrix(lyrics_document_term_matrix[1 , ])

    with_happy = get_lyrics_dtm_matrix(dtm_with_happy)
    with_sad = get_lyrics_dtm_matrix(dtm_with_sad)
    with_angry = get_lyrics_dtm_matrix(dtm_with_angry)

    # predictions
    pred_for_happy = predict(msa_model, data.frame(with_happy), type = "raw")
    pred_for_angry = predict(msa_model, data.frame(with_angry), type = "raw")
    pred_for_sad = predict(msa_model, data.frame(with_sad), type = "raw")

    result = array(pred_for_angry + pred_for_happy + pred_for_sad)
    labels = array(names(data.frame(pred_for_angry + pred_for_happy + pred_for_sad)))
    max = 1
    index = 1
    for (value in pred_for_happy + pred_for_sad + pred_for_angry){
        if(value > result[max]){
            max = index
        }
        index = index + 1
    }
#     print(probs)
    return (c(labels, max, pred_for_happy + pred_for_sad + pred_for_angry))
}