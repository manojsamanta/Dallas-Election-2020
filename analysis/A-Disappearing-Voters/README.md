# Comparison of two files

Here is how you can compare between two files - 

~~~~~~
x=read_csv("raw-data/10_18-roster.csv.gz")

# Parsed with column specification:
# cols(
#  Precinct = col_double(),
#  StateIDNumber = col_double(),
#  `Voter Name` = col_character(),
#  `P=InPerson M=Mail` = col_character(),
#  `Date Ballot Request` = col_character(),
#  `Date Ballot Mailed` = col_character(),
#  `Date Ballot Returned` = col_character(),
#  `Residence Address` = col_character()
# )
~~~~~~


~~~~~~
y=read_csv("raw-data/10_27-roster.csv.gz")

# Parsed with column specification:
# cols(
#   Precinct = col_double(),
#   StateIDNumber = col_double(),
#   `Voter Name` = col_character(),
#   `P=InPerson M=Mail` = col_character(),
#   `Date Ballot Request` = col_character(),
#   `Date Ballot Mailed` = col_character(),
#   `Date Ballot Returned` = col_character(),
#   `Residence Address` = col_character()
# )
~~~~~~

~~~~~~
x %>% left_join(y, by="StateIDNumber")  %>% filter(is.na(Precinct.y)) %>% count
# # A tibble: 1 x 1
#       n
#   <int>
# 1  1178
~~~~~~


## Comparison of all consecutive days

This is a summary of "RESULTS.txt".

| Date 1 | Date 2 |
|--------|--------|
| 10_06-roster.csv|10_07-roster.csv|0 |
| 10_07-roster.csv|10_08-roster.csv|0 |
| 10_08-roster.csv|10_11-roster.csv|0 |
| 10_11-roster.csv|10_12-roster.csv|0 |
| 10_12-roster.csv|10_14-roster.csv|0 |
| 10_14-roster.csv|10_15-roster.csv|32 |
| 10_15-roster.csv|10_16-roster.csv|2148 |
| 10_16-roster.csv|10_17-roster.csv|36 |
| 10_17-roster.csv|10_18-roster.csv|37 |
| 10_18-roster.csv|10_19-roster.csv|85 |
| 10_19-roster.csv|10_20-roster.csv|130 |
| 10_20-roster.csv|10_21-roster.csv|229 |
| 10_21-roster.csv|10_22-roster.csv|198 |
| 10_22-roster.csv|10_23-roster.csv|178 |
| 10_23-roster.csv|10_24-roster.csv|173 |
| 10_24-roster.csv|10_25-roster.csv|160 |
| 10_25-roster.csv|10_26-roster.csv|235 |
| 10_26-roster.csv|10_27-roster.csv|139 |
| 10_27-roster.csv|10_28-roster.csv|178 |
| 10_28-roster.csv|10_29-roster.csv|205 |
| 10_29-roster.csv|10_30-roster.csv|1565 |


