# Dallas-Election-2020

I spent some time volunteering with the [openrecords project](http://openrecords.org) to investigate a number of puzzling observations in the early voting data from the Dallas county, TX. Here I like to share my analysis so that you can reproduce it. If you can find an honest explanation of the observed anomalies, please let me know in the comment section.

## Data Format

Let me first describe the available data. From October 6th to October 30th, the county released early voting records for the residents. These records are cumulative. That means if you voted on October 7th, your name and voting details should continue to appear on each day afterward. Therefore, you expect the files to grow in size, and they do as you can see from the table posted below.

Here are the data files you will find in [my github project](https://github.com/manojsamanta/Dallas-election-2020) and their number of data lines (excluding header). Each line in each file contains the record of a single voter. As you can see, the files have increasing number of lines every day. That is encouraging.

| File                      | Number of lines |
|---------------------------|-----------------|
| raw-data/10_06-roster.csv.gz |   12280     |
| raw-data/10_07-roster.csv.gz |   18460     |
| raw-data/10_08-roster.csv.gz |   19792     |
| raw-data/10_11-roster.csv.gz |   28064     |
| raw-data/10_12-roster.csv.gz |   28525     |
| raw-data/10_14-roster.csv.gz |   152209    |
| raw-data/10_15-roster.csv.gz |   213606    |
| raw-data/10_16-roster.csv.gz |   275607    |
| raw-data/10_17-roster.csv.gz |   315654    |
| raw-data/10_18-roster.csv.gz |   341607    |
| raw-data/10_19-roster.csv.gz |   389793    |
| raw-data/10_20-roster.csv.gz |   444955    |
| raw-data/10_21-roster.csv.gz |   485566    |
| raw-data/10_22-roster.csv.gz |   525057    |
| raw-data/10_23-roster.csv.gz |   559605    |
| raw-data/10_24-roster.csv.gz |   586814    |
| raw-data/10_25-roster.csv.gz |   601332    |
| raw-data/10_26-roster.csv.gz |   632961    |
| raw-data/10_27-roster.csv.gz |   665065    |
| raw-data/10_28-roster.csv.gz |   698959    |
| raw-data/10_29-roster.csv.gz |   741007    |
| raw-data/10_30-roster.csv.gz |   794398    |

The actual voting roster tables from the county had many more columns, but I uploaded only eight columns to stay within the size limits for github. Those reduced tables contain enough information to show the anomalies. The chosen columns are shown in the following example - 

|Precinct|StateIDNumber|Voter Name|P=InPerson M=Mail|Date Ballot Request|Date Ballot Mailed|Date Ballot Returned|Residence Address|
|----|-----|-----|---------|----|-----------|---------|--------------------|
|1000|2129749227|AKEEN - ALEXIUS NGOONG |M|29-AUG-20|29-AUG-20|02-OCT-20|6003 ABRAMS RD #1060 DA 75231 |

Note that these files are machine-generated. Therefore, there is no room for clerical error. In fact, the entire process of early voting is operated by the machines. When a voter request for a ballot, the system notes down the "Date Ballot Request" information for the voter. Then the system mails a ballot and notes down "Date Ballot Mailed". Finally, if the voter returns the ballot, the system creates a unique record in this table with "Date Ballot Request", "Date Ballot Mailed" and "Date Ballot Returned" for the voter.

Finally, the county provides another file that contains the registration information of all voters. This file has over 200 columns, but I picked only two in the github project. Here is a small section from the file "raw-data/voter-record.csv.gz" -

| SOS_VoterID |    birthdate |
|-------------|--------------|
|2132728455   |   1981 |
|1203297816   |   1977 |
|2157683062   |   1991 |

The SOS_VoterID in this table is the same as the StateIDNumber in the early voter tables shown before.



## Disappeared (Purged) Voters

Alright, now that you know all data files, you may be interested in doing some sanity check. I mentioned that the files are cumulative. That means voters should not magically disappear as time passes because that would mean the returned ballot already recorded in the system got purged. That should be a complete no-no in an automated election system.

I ran a quick comparison between Oct 18th and Oct 27th and found 1178 votes to disappear (see below). I am giving you the R code so that you can reproduce the results. It is quite simple. You load early-voting tables from two dates, and then left_join the earlier date with the later date. Since it is left_join, if a vote disappears, the right half of the joined table will be empty and that is what I check for.

Here are the code and the result.

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

As you can see, 1178 voters from Oct 18 disappeared from the roster by Oct 27th.

That got me curious, and I decided to run a pairwise comparison between every consecutive dates with available data. Here are the results.

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

Overall, over 5700 voters did not make it to the end. At the end of the day - "it's not the people who vote that count, it's the people who count the votes."

Once again, as I understand, this entire process is automated. It is unlikely that the records disappeared every day because some human copied the names from one file to another and missed a few here and there.


