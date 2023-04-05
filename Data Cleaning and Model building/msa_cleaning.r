# install.packages("openNLP")
# install.packages("wordcloud")
# install.packages('stringr')
# install.packages('hunspell')
# install.packages('ds4psy')
# install.packages("glue")
# install.packages('textclean')
# install.packages("tm")
# install.packages("tokenizers")
# install.packages('parsedate')

library('stringr')
library('hunspell')
library('ds4psy')
library('glue')
library('tm')
library('dplyr',  warn.conflicts = FALSE)
library('parsedate')
library("tokenizers", warn.conflicts = FALSE)


# replacing contractions with full forms
library('textclean')

# Cleaning dataset for further usage
# msa = Music Sentiment Analysis

# reading dataset
msa_dataset <- read.csv('./msa_dataset.csv')

# saving unprocessed lyrics
msa_dataset['unprocessed_lyrics'] = msa_dataset['lyrics']

# displaying dataset
head(msa_dataset[c('id', 'title', 'all_artists','popularity','release_date','danceability','energy','key','loudness','mode','acousticness','instrumentalness','liveness','valence','tempo','duration_ms','time_signature','sentiment')], 5)

# dataset columns
column_names = colnames(msa_dataset)
column_names

# removing X column
msa_dataset = msa_dataset[column_names[2:length(column_names)]]
names(msa_dataset)

# first 2 lyrics and sentments
head(msa_dataset[c('lyrics', 'sentiment')], 2)

sum(is.na(msa_dataset))

msa_dataset = transform(msa_dataset, release_date=unlist(str_split(parsedate::parse_date(release_date), " ")[1]))

# replacing ’ with '
msa_dataset = transform(msa_dataset, lyrics=str_replace_all(lyrics, "’", "\'"))

msa_dataset = transform(msa_dataset, lyrics=tolower(lyrics))
head(msa_dataset[c('lyrics', 'sentiment')], 2)

msa_dataset = transform(
    msa_dataset, 
    lyrics=str_replace_all(
        string=lyrics, 
        pattern=r"(\[(.*?)\])", 
        replacement = " "
    )
)
head(msa_dataset[c('lyrics', 'sentiment')], 2)

correct_spellings = function(lyrics){
    print("correcting spellings")
    # checking spelling mistakes
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
        print(glue(r"(\b{bad.words[index]}\b)"))
        new_lyrics = str_replace_all(
            string = lyrics, 
            pattern = glue(r"(\b{bad.words[index]}\b)"), 
            replacement = suggested.words[index]
        )
    }
    return (new_lyrics)
}

# applying correct_spellings to all lyrics
msa_dataset = transform(msa_dataset, lyrics=correct_spellings(lyrics))
head(msa_dataset[c('lyrics', 'sentiment')], 2)



# replacing all contractions with their full forms
msa_dataset = transform(msa_dataset, lyrics=replace_contraction(lyrics))
head(msa_dataset[c('lyrics', 'sentiment')], 2)

# replacing any internet slags that might have slipped in to the lyrics
msa_dataset = transform(msa_dataset, lyrics=replace_internet_slang(lyrics))
head(msa_dataset[c('lyrics', 'sentiment')], 2)

# removing all punctuations
msa_dataset = transform(msa_dataset, lyrics=tolower(removePunctuation(lyrics)))
head(msa_dataset[c('lyrics', 'sentiment')], 2)

# removing all numbers
msa_dataset = transform(msa_dataset, lyrics=str_replace_all(lyrics, r"(\d)", " "))
head(msa_dataset[c('lyrics', 'sentiment')], 2)

# replacing all whitespace characters with one space
msa_dataset = transform(
    msa_dataset, 
    lyrics=str_replace_all(
        string=lyrics, 
        pattern=r"(\s+)", 
        replacement = " "
    )
)
head(msa_dataset[c('lyrics', 'sentiment')], 2)

# holds sentiments of each lyric
sentiments.classes = msa_dataset$sentiment
table(sentiments.classes)

# a list of vectors in which each vector is a tokenized lyrics
# converting lyrics in batches of 100
lyrics.tokenized = list()
print(lyrics.tokenized)
index = 1
while (index <= length(msa_dataset$lyrics)){
    lyrics.tokenized = append(
        lyrics.tokenized, 
        tokenize_words(
            msa_dataset$lyrics[index]
        )
    )
    index = index + 1
}
    

lyrics.tokenized[1]

length(sentiments.classes)

length(lyrics.tokenized)

# Tokenization of the lyrics for each class
angry.tokenized = tokenize_words(split(msa_dataset, msa_dataset$sentiment)$angry$lyrics)
happy.tokenized = tokenize_words(split(msa_dataset, msa_dataset$sentiment)$happy$lyrics)
sad.tokenized = tokenize_words(split(msa_dataset, msa_dataset$sentiment)$sad$lyrics)
relaxed.tokenized = tokenize_words(split(msa_dataset, msa_dataset$sentiment)$relaxed$lyrics)
length(angry.tokenized)
length(happy.tokenized)
length(sad.tokenized)
length(relaxed.tokenized)



write.csv(msa_dataset, "cleaned_dataset.csv")


