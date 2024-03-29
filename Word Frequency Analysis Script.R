#' ---
#' title: "Word Frequency Analysis Notebook"
#' output: 
#'   html_notebook:
#'     theme: cerulean
#'     toc: yes
#'     toc_float: yes
#' ---
#' 
#' # set options {.tabset}
#' 
#' ## disable scientific notation
## ---------------------------------------------------------------------------------------------------------
options(scipen=999)

#' ## show only 2 decimals
## ---------------------------------------------------------------------------------------------------------
options(digits = 2)

#' 
#' # Load packages {.tabset}
#' 
#' ## Tidyverse
#' Tidyverse contains many functions useful to cleaning, tidying, and manipulating data
#' 
#' Documentation can be viewed [here](https://www.tidyverse.org)
#' 
## ---------------------------------------------------------------------------------------------------------
if (!require(tidyverse)){
  install.packages("tidyverse", dependencies = TRUE)
  library(tidyverse)
}

#' ## tidytext
#' tidytext makes it easy to mine text data
#' 
#' Documentation can be viewed [here](https://www.tidytextmining.com)
#' 
## ---------------------------------------------------------------------------------------------------------
if (!require(tidytext)){
  install.packages("tidytext", dependencies = TRUE)
  library(tidytext)
}

#' 
#' # Import data {.tabset}
#' 
#' ## get list of private school documents
#' 
## ---------------------------------------------------------------------------------------------------------
(docs.private <- list.files("Private/"))

#' ## get list of public school documents
#' 
## ---------------------------------------------------------------------------------------------------------
(docs.public <- list.files("Public/"))

#' 
#' ## import private school alerts
## ---------------------------------------------------------------------------------------------------------
for (doc in docs.private)
{
  if(!exists("alerts.private"))
  {
    enframe(read_lines(paste("Private/", doc, sep=""))) %>%
      mutate(name = doc,
             institutionType = "Private") -> alerts.private
  }
  else
  {
    enframe(read_lines(paste("Private/", doc, sep=""))) %>%
      mutate (name = doc,
              institutionType = "Private") %>%
      bind_rows(alerts.private) -> alerts.private
  }
}
alerts.private

#' ## import public school alerts
## ---------------------------------------------------------------------------------------------------------
for (doc in docs.public)
{
  if(!exists("alerts.public"))
  {
    enframe(read_lines(paste("Public/", doc, sep=""))) %>%
      mutate(name = doc,
             institutionType = "Public")-> alerts.public
  }
  else
  {
    enframe(read_lines(paste("Public/", doc, sep=""))) %>%
      mutate(name = doc,
             institutionType = "Public") %>%
      bind_rows(alerts.public) -> alerts.public
  }
}
alerts.public

#' 
#' ## combine private and public alerts
## ---------------------------------------------------------------------------------------------------------
(alerts.private %>%
  bind_rows(alerts.public)-> alerts.all)

#' 
#' # tidy data {.tabset}
#' 
## ---------------------------------------------------------------------------------------------------------
(alerts.all %>%
  mutate(line = row_number()) %>%
  unnest_tokens(word, value) %>%
  filter(!str_detect(word, "[:digit:]")) %>%
  anti_join(stop_words) %>%
  filter(word != "ut")-> alerts.all.tidy)

#' 
#' # Word frequencies {.tabset}
#' 
#' 
#' ## Most frequent words
#' 
## ----echo=FALSE-------------------------------------------------------------------------------------------

num_rows <- nrow(alerts.all.tidy)

alerts.all.tidy %>%
  count(word, sort = TRUE) %>%
  mutate(n_rows = num_rows,
         proportion = n/n_rows) %>%
  top_n(10, wt = n) %>%
  ggplot(aes(x = reorder(word, proportion), label = sprintf("%.1f %%", 100*proportion), y = proportion)) + 
  geom_col(alpha = 0.8, show.legend = FALSE) +
  geom_text(hjust = 0, nudge_y = 0.0005, size = 3) +
  coord_flip() +
  labs(x = "",
       y = "Proportion of times word used across all alerts") + 
  ggtitle("Most frequent words across all crime alerts") +
  theme(panel.background = element_rect(fill = "transparent", color = NA),
        plot.background = element_rect(fill = "transparent", color = NA))

ggsave(filename = "Most Frequent Words Across All Alerts.png",  bg = "white")


#' 
#' ## Frequency of keywords
## ----echo=FALSE-------------------------------------------------------------------------------------------
num_rows <- nrow(alerts.all.tidy)

alerts.all.tidy %>%
  count(word, sort = TRUE) %>%
  mutate(n_rows = num_rows,
         proportion = n/n_rows) %>%
  filter(word == "subject" | word == "student" | word == "suspect" | word == "victim" | word == "male" | word == "criminal" | word == "black" | word == "white" | word == "sexual" | word == "intoxication" | word == "unknown" | word == "crime" | word == "alcohol" | word == "use" | word == "person") %>%
  ggplot(aes(x = reorder(word, proportion), label = sprintf("%.1f %%", 100*proportion), y = proportion)) + 
  geom_col(alpha = 0.8, show.legend = FALSE) +
  geom_text(hjust = 0, nudge_y = 0.0005, size = 3) +
  coord_flip() +
  labs(x = "",
       y = "Proportion of times key words used across all alerts") + 
  ggtitle("Frequency of keywords across all crime alerts") +
  theme(panel.background = element_rect(fill = "transparent", color = NA),
        plot.background = element_rect(fill = "transparent", color = NA))

ggsave(filename = "Frequency of Keywords Across All Alerts.png",  bg = "white")


#' 
#' 
#' 
#' 
#' 
## ---------------------------------------------------------------------------------------------------------
#knitr::purl("Work Frequency Analysis Notebook.Rmd", "Word Frequency Analysis Script", documentation = 2)


