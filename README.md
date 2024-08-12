# music_sentiment_analysis

## Brief Description
This is a project executed by the MSc. Big Data Analysis students of ST Josephs University Bangalore as their first semester project. The aim here was to perform sentiment analysis on music lyrics, classify music into angry, happy and sad.

### HOW TO RUN THIS PROJECT

#### Required Libraries
1. "shiny"
2. "shinydashboard"
3. "fmsb"
4. "bslib"
5. "dplyr"
6. "ggplot2"
7. "shinythemes"
8. "geniusr"
9. "DT"
10. "fmsb"
11. "dplyr"
12. "rlang"
13. "ds4psy"
14. "spacyr"
15. "tm"
16. "parsedate"
17. "caret"

#### Setup
1. Go to <code>RShiny/classification_module/classify.R</code>
2. Copy the absolute path of the file <code>classify.R</code>
3. Go to <code>RShiny/project.R</code>
4. Paste the path copied in step 2 in the line 13: <code>source("classification_module/classify.R")</code>
5. Install the following python packages
   - <code>pip install -U pip setuptools wheel</code>
   - <code>pip install -U spacy</code>
   - <code>python -m spacy download en_core_web_sm</code>

6. Changes to be made in RShiny/classification_module/classify.R
   1. If spacy is installed in a virtual environment, copy that path to that environment and update the virtualenv attribute of <code>spacy_initialize(model = 'en_core_web_sm', virtualenv  = "path/spacyenv/")</code>.
   2. Update the path to all the corpuses; corpuses are found in <code>RShiny/classification_module</code>. Update the following paths;
        - <code>angry_corpus = readRDS("path/angry_corpus.rda")</code>
        - <code>sad_corpus = readRDS("path/sad_corpus.rda")</code>
        - <code>happy_corpus = readRDS("path/happy_corpus.rda")</code>

7. Run the app;
   - <b>Using your terminal:</b> Open your terminal, navigate to the project's root directory <code>RShiny</code> and run <code>R -e "shiny::runApp('project.R')"</code> in your terminal.
   - <b>Using RStudio:</b> Open RStudio, navigate to <code>File > Open File > Go to the project folder and select project.R</code>.
   - Click on <code>Run App</code> in RStudio (top right).

<br>

# Project Report - Music Lyrics Sentiment Classification

## Problem Statement

To build a model using R Programming and R Shiny that can classify music lyrics into one of three sentiment classes, namely: Angry, Sad, and Happy.

## Data Collection

To create a model for classifying lyrics into the aforementioned sentiments, we had to collect music data, focusing on the lyrics. Given that we were settling on building a supervised model, we needed data that was labelled. Manually collecting and labelling music lyrics is a cumbersome process, so, to make things easy, we sought no further than one of the world’s largest music databases, Spotify. Believing that Spotify has a pretty good classification model, we created playlists for each of the above sentiments, thus each song will be labelled based on the playlist it belongs to.

Using the Spotify API, we fetched all the songs in each playlist, labelling them according to their playlist (sentiment). Since Spotify’s API doesn’t give us access to music lyrics, we fetched attributes like artist name and song title that can be used to fetch the lyrics from another platform. Furthermore, using the artist's name and song title, we used Genius API to fetch the lyrics of each song. The collected data is stored in three different CSV files, according to sentiments/playlists.

## Data Cleaning

The collected data, precisely the lyrics, contained a lot of noise (unwanted data) that would not be required for our model. So, we had to strip these noises from our dataset. To do this, we performed the following operations:

- **Converting lyrics to lowercase**: All letters are converted into lowercase to ensure consistency. This step standardizes the text, making it uniform for the model.

- **Removing lyrics divisions**: Lyrics were divided into subsections like chorus, pre-chorus, intro, etc., and some contained timestamps. These were removed as they are not useful for sentiment analysis.

- **Correcting spellings**: Spelling errors were corrected to ensure accuracy in the text data.

- **Removing contractions**: Contractions were decomposed into their full forms to standardize the text.

- **Removing special characters and non-alphabetical characters**: Special characters and numbers that do not contribute to sentiment analysis were removed.

- **Removing extra spaces**: Extra spaces, tabs, and new lines were replaced to clean up the text.

## Feature Extraction

The aim here was to use the cleaned set of lyrics to extract features relevant to our model. We lemmatized our set of lyrics using part of speech tagging. Lemmatization brings words to their root forms, and combining it with part of speech tagging helps in accurately determining the root forms. We also removed stop words, which are irrelevant for sentiment analysis.

## Model Building

Before building our model, we had to convert our dataset into a form that is understandable by our model (Naive Bayes). We used the Document Term Matrix, specifically Term Frequency - Inverse Document Frequency (TF-IDF), to structure the text data. 

- **Document Term Matrix**: A technique for structuring text data where documents are placed in rows and terms in columns, with values representing term presence and weight.

- **Term Frequency - Inverse Document Frequency (TF-IDF)**: Quantifies the importance of a term in a document relative to a collection of documents.

Finally, the processed data was fed into a Naive Bayes classifier to build a model that can classify lyrics into Angry, Sad, or Happy sentiments.

## Model Deployment

After building the model, it was deployed using R Shiny. An interactive user interface was developed allowing users to select an artist and a song. The selected song’s lyrics are then passed to the model, and the probability of the lyrics being in each sentiment class is displayed in a bar chart.
