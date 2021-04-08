x=read_csv("raw-data/10_18-roster.csv.gz")
y=read_csv("raw-data/10_27-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count
