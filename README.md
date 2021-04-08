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

| Date 1 | Date 2 | Missing Voter |
|--------|--------|---------------|
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


## Reincarnated Voters

If you thought missing 5,700 voters were bad, we are just getting started. The good folks from openrecords project brought to my attention that many more voters "reincarnated", i.e. their voting records changed as time passed. Here is an example.

|  Date | Precinct|StateIDNumber|Voter Name|P=InPerson M=Mail|Date Ballot Request|Date Ballot Mailed|Date Ballot Returned|Residence Address|
|-------|---------|-------------|----------|-----------------|-------------------|------------------|--------------------|-----------------|
| 10_06-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 29-AUG-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_07-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 29-AUG-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_08-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 29-AUG-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_11-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 29-AUG-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_12-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 29-AUG-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_14-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 29-AUG-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_15-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 29-AUG-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_16-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 29-AUG-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_17-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 29-AUG-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_18-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 29-AUG-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_19-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 29-AUG-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_20-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 23-SEP-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_21-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 23-SEP-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_22-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 23-SEP-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_23-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 23-SEP-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_24-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 23-SEP-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_25-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 23-SEP-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_26-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 23-SEP-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_27-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 23-SEP-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_28-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 23-SEP-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_29-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 23-SEP-20 | 02-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 
| 10_30-roster.csv | 1000 | 2129749227 | AKEEN - ALEXIUS NGOONG  | M | 29-AUG-20 | 23-SEP-20 | 30-OCT-20 | 6003 ABRAMS RD #1060 DA 75231 | 

As you can see, this person returned the ballot on Oct 2nd and all data were entered on the roster on Oct 6th. Then, on Oct 20, the information on "Date Mailed" magically changed from 29-AUG-20 to 23-SEP-20. Finally, on Oct 30, his "Ballot Returned" changed to 30-OCT-20. That is a rather bizzare behavior in an automated system. 

Going through the records, I found over 50,000 such reincarnated voters (6.2%) out of 799958 total records, whose voting records changed from the original. This is a substantial number to change several local and national polls. What is going on?

One explanation is that the software has a glitch, and it randomly alters some of the records. The other possibily is that the original vote submitted by the person got replaced with a new record by some malicious actor. Both possibilities are serious given that we are talking about over 50,000 votes, or over 6% of absentee ballots.

It gets even more puzzling, when we look into the age distribution of those 50,000 voters (see table below). 

| DOB |	Count |
|-----|-------|
| 1915 | 2 |
| 1916 | 1 |
| 1917 | 1 |
| 1918 | 5 |
| 1919 | 6 |
| 1920 | 9 |
| 1921 | 22 |
| 1922 | 22 |
| 1923 | 35 |
| 1924 | 58 |
| 1925 | 89 |
| 1926 | 119 |
| 1927 | 139 |
| 1928 | 169 |
| 1929 | 172 |
| 1930 | 224 |
| 1931 | 258 |
| 1932 | 285 |
| 1933 | 303 |
| 1934 | 339 |
| 1935 | 325 |
| 1936 | 366 |
| 1937 | 376 |
| 1938 | 395 |
| 1939 | 436 |
| 1940 | 441 |
| 1941 | 434 |
| 1942 | 480 |
| 1943 | 479 |
| 1944 | 422 |
| 1945 | 385 |
| 1946 | 470 |
| 1947 | 501 |
| 1948 | 434 |
| 1949 | 386 |
| 1950 | 349 |
| 1951 | 322 |
| 1952 | 355 |
| 1953 | 298 |
| 1954 | 299 |
| 1955 | 187 |
| 1956 | 45 |
| 1957 | 23 |
| 1958 | 16 |
| 1959 | 17 |
| 1960 | 24 |
| 1961 | 17 |
| 1962 | 12 |
| 1963 | 17 |
| 1964 | 23 |
| 1965 | 13 |
| 1966 | 12 |
| 1967 | 8 |
| 1968 | 13 |
| 1969 | 9 |
| 1970 | 6 |
| 1971 | 6 |
| 1972 | 9 |
| 1973 | 4 |
| 1974 | 7 |
| 1975 | 9 |
| 1976 | 2 |
| 1977 | 8 |
| 1978 | 3 |
| 1979 | 5 |
| 1980 | 4 |
| 1981 | 6 |
| 1982 | 6 |
| 1983 | 8 |
| 1984 | 11 |
| 1985 | 10 |
| 1986 | 5 |
| 1987 | 4 |
| 1988 | 9 |

You can see this data in chart form [here](http://openrecords.org/stories/hackerstargetseniors.html). As you can see, this "glitch" affects only those voters older than 65 years, and you can see both from the table and the figure that the jump between below and above 65 year old is really sharp. It is as if someone intentionally programmed to modify the votes based on an age cutoff.Based on this observation, I am leaning more toward foul play than software glitch, although glitch would be serious enough.

This Dallas observation is unlike many other claims of election tampering, because here you have the data of real votes being tampered and not a probabilistic model. We know exactly who those voters are, where they live, their age and so on. Moreover, the number is substantial to swing local and national elections. Finally, this raises the question that what else happened that did not get caught? If there was foul play, did it manipulate fake votes undetected by this analysis? 

All credits for originally finding these patterns go to the other volunteers of the openrecords project, whereas my role is in just confirming them independently. Moreover, they interviewed actual voters, whose votes got purged or manipulated and [confirmed that they did not vote twice](http://openrecords.org/stories/purgedpeople.html).  If you like to see those details, please check [their website](http://openrecords.org).


