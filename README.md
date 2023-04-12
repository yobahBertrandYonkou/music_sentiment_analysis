# music_sentiment_analysis

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
1. Go to RShiny/classification_module/classify.R
2. Copy the absolute path of the file <b>classify.R</b>
3. Go to RShiny/project.R
4. Paste the path copied in step 2 in the line 13: <code>source("classification_module/classify.R")</code>
5. Install the following python packages
   - '<code>pip install -U pip setuptools wheel</code>
   - '<code>pip install -U spacy</code>
   - '<code>python -m spacy download en_core_web_sm</code>

6. Changes to be made in RShiny/classification_module/classify.R
   1. If spacy is installed in a virtual environment, copy that path to that environment and update the virtualenv attribute of <code>spacy_initialize(model = 'en_core_web_sm', virtualenv  = "path/spacyenv/")</code>.
   2. Update the path to all the corpuses; corpuses are found in <code>RShiny/classification_module</code>. Update the following paths;
        - <code>angry_corpus = readRDS("path/angry_corpus.rda")</code>
        - <code>sad_corpus = readRDS("path/sad_corpus.rda")</code>
        - <code>happy_corpus = readRDS("path/happy_corpus.rda")</code>

7. Run the app;
   - <b>Using your terminal:</b> Open your terminal, navigate to the project's root directory <code>RShiny</code> and run <code>R -e "shiny::runApp('project.R')"</code> in your terminal.
   - <b>Using RStudio:</b> Open RStudio, navigate to <code>File > Open File > Go to the project folder and select project.R</code>

