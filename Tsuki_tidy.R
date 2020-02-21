library(tidyverse)
library(utf8)
library(stringi)

files <- list.files("Tsuki-Data")

read <- function(f){
  channel_name <- str_replace(f, ".csv",'')
  df <- read_csv(paste("Tsuki-Data",f,sep = "\\")) %>%
    mutate(channel = channel_name,
           id = as.character(id)) %>%
    distinct_all()
  return (df)
}

message_df <- map(files, read) %>%
  bind_rows()


emoji_df <- message_df %>%
  separate(name, into = c("name", "name_id"), sep = "#") %>%
  mutate(#content = stri_enc_toascii(content),
         tsuki_emoji = str_extract_all(content, pattern = "<.?:[a-zA-Z]+:[0-9]+>"),
         unicode_emoji = str_extract_all(content, pattern = "\\[0-9]+"))

language_tag <- read_csv("language_tag.csv")
language_df <- language_tag %>%
  separate(name, into = c("name", "name_id"), sep = "#") %>%
  drop_na() %>%
  filter(nchar(name_id) <= 4) %>%
  select(-name)
  

message_lang_df <- inner_join(language_df, emoji_df)

message_all_df <- left_join(emoji_df, language_df)
stri_enc_toascii(emoji_df[263,]$content)
