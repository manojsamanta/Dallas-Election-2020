x = read_csv("raw-data/10_06-roster.csv.gz")
y = read_csv("raw-data/10_07-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_07-roster.csv.gz")
y = read_csv("raw-data/10_08-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_08-roster.csv.gz")
y = read_csv("raw-data/10_11-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_11-roster.csv.gz")
y = read_csv("raw-data/10_12-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_12-roster.csv.gz")
y = read_csv("raw-data/10_14-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_14-roster.csv.gz")
y = read_csv("raw-data/10_15-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_15-roster.csv.gz")
y = read_csv("raw-data/10_16-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_16-roster.csv.gz")
y = read_csv("raw-data/10_17-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_17-roster.csv.gz")
y = read_csv("raw-data/10_18-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_18-roster.csv.gz")
y = read_csv("raw-data/10_19-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_19-roster.csv.gz")
y = read_csv("raw-data/10_20-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_20-roster.csv.gz")
y = read_csv("raw-data/10_21-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_21-roster.csv.gz")
y = read_csv("raw-data/10_22-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_22-roster.csv.gz")
y = read_csv("raw-data/10_23-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_23-roster.csv.gz")
y = read_csv("raw-data/10_24-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_24-roster.csv.gz")
y = read_csv("raw-data/10_25-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_25-roster.csv.gz")
y = read_csv("raw-data/10_26-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_26-roster.csv.gz")
y = read_csv("raw-data/10_27-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_27-roster.csv.gz")
y = read_csv("raw-data/10_28-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_28-roster.csv.gz")
y = read_csv("raw-data/10_29-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count

x = read_csv("raw-data/10_29-roster.csv.gz")
y = read_csv("raw-data/10_30-roster.csv.gz")
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count


