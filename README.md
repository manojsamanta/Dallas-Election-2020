# Dallas-Election-2020

I spent some time volunteering with the [openrecords project](http://openrecords.org) to investigate a number of puzzling observations in the early voting data from the Dallas county, TX. Here I like to share my analysis so that you can reproduce it. If you can find an honest explanation of the observed anomalies, please let me know in the comment section.

## Brief Introduction to Computerized Election Control

Before getting into the electronic technology and databases, let us start with the traditional centuries-old election system that everyone understands.

![Testing image](https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Election_presidentielle_2007_Lausanne_MG_2761.jpg/1024px-Election_presidentielle_2007_Lausanne_MG_2761.jpg)

A voter goes to a polling center during the election. The person in charge of the polling center checks ID and finds the name of the voter in a polling roster (paper document). This is to ensure that (i) the voter is eligible to vote at the location and (ii) he did not vote already. Then he gives the voter a fresh ballot paper and asks him to use a covered booth to fill it up. The voter fills up the ballot with his choices, and then drops it in a centrally placed box.

Electronic technologies replicate this process in the following way. The voter registration roster with the names of all eligible voters is a computer file. This file does not get updated during the polling season.  The names of everyone who voted is a separate computer file that gets incremented with the information of every new voter. We will call it the "vote roster" in the following discussion.

Let us introduce mail-in voting to this picture. This time, if an absentee voter requests mail-in ballot, the automated system makes sure the person is eligible to vote (based on the voter registration roster) and sends him a ballot by mail.  Later, when an envelope with a filled ballot comes from the absentee voter, the automated system again makes sure the voter is legitimate and did not vote already. Then it opens the envelope, takes out the paper ballot and places inside a locked box with other ballots. At the same time, the system creates a new record in the "vote register" to show that the person already voted. 

Once this process is completed, the ballot gets anonymyzed and mixed with other ballots, and it is not possible to connect the ballot with the voter. To ensure security and integrity of the system, the records once created in the vote register file should not be updated in the future. 


## Data Format

Let me now describe the available data.

### Voter Registration File

Among the files in this github repo, you will find one ("raw-data/voter-record.csv.gz") with registration information of all voters ("voter registration file"). This file has over 200 columns, but I picked only two in the github project. Here is a small section from "raw-data/voter-record.csv.gz" -

| SOS_VoterID |    birthdate |
|-------------|--------------|
|2132728455   |   1981 |
|1203297816   |   1977 |
|2157683062   |   1991 |


The openrecords project downloaded the original file 10/13/2020 from the Dallas county. Please keep the [relevant Texas law](https://statutes.capitol.texas.gov/Docs/EL/htm/EL.13.htm#13.143) in mind, which states that a person must register at least 30 days prior to the election.

~~~~~~~~~
Sec. 13.143.  EFFECTIVE DATE OF REGISTRATION;  PERIOD OF EFFECTIVENESS.  (a)  Except as provided by Subsections (b) and (e), if an applicant's registration application is approved, the registration becomes effective on the 30th day after the date the application is submitted to the registrar or on the date the applicant becomes 18 years of age, whichever is later.

(b)  A registration is effective for purposes of early voting if it will be effective on election day.

(c)  A registration is effective until canceled under this code.

(d)  For purposes of determining the effective date of a registration, an application submitted by:

(1)  mail is considered to be submitted to the registrar on the date it is placed with postage prepaid and properly addressed in the United States mail; or

(2)  telephonic facsimile machine is considered to be submitted to the registrar on the date the transmission is received by the registrar, subject to Subsection (d-2).

(d-1)  The date indicated by the post office cancellation mark is considered to be the date the application was placed in the mail unless proven otherwise.

(d-2)  For a registration application submitted by telephonic facsimile machine to be effective, a copy of the registration application must be submitted by mail and be received by the registrar not later than the fourth business day after the transmission by telephonic facsimile machine is received.

(e)  If the 30th day before the date of an election is a Saturday, Sunday, or legal state or national holiday, an application is considered to be timely if it is submitted to the registrar on or before the next regular business day.
~~~~~~~~~



### Early Voting Records ("voting records")

The SOS_VoterID in this table is the same as the StateIDNumber in the early voter tables shown before.

Next we will describe the "voting records" data. From October 6th to October 30th, the county released early voting records for the residents.  The released files are cumulative. That means if you voted on October 7th, your name and voting details should continue to appear on each day afterward. Therefore, you expect the files to grow in size, and they do as you can see from the table posted below.

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

The StateIDNumber in this table is the same as the SOS_VoterID in the voter registration table shown before.

Note that these files are machine-generated. Therefore, there is no room for clerical error. In fact, the entire process of early voting is operated by the machines. When a voter request for a ballot, the system notes down the "Date Ballot Request" information for the voter. Then the system mails a ballot and notes down "Date Ballot Mailed". Finally, if the voter returns the ballot, the system creates a unique record in this table with "Date Ballot Request", "Date Ballot Mailed" and "Date Ballot Returned" for the voter.



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
| 1911 | 1 |
| 1912 | 1 |
| 1914 | 1 |
| 1915 | 4 |
| 1916 | 3 |
| 1917 | 3 |
| 1918 | 6 |
| 1919 | 18 |
| 1920 | 19 |
| 1921 | 52 |
| 1922 | 65 |
| 1923 | 79 |
| 1924 | 137 |
| 1925 | 212 |
| 1926 | 248 |
| 1927 | 339 |
| 1928 | 416 |
| 1929 | 461 |
| 1930 | 574 |
| 1931 | 623 |
| 1932 | 753 |
| 1933 | 852 |
| 1934 | 1007 |
| 1935 | 974 |
| 1936 | 1132 |
| 1937 | 1154 |
| 1938 | 1342 |
| 1939 | 1414 |
| 1940 | 1574 |
| 1941 | 1689 |
| 1942 | 1829 |
| 1943 | 1991 |
| 1944 | 1967 |
| 1945 | 1979 |
| 1946 | 2336 |
| 1947 | 2556 |
| 1948 | 2467 |
| 1949 | 2387 |
| 1950 | 2351 |
| 1951 | 2276 |
| 1952 | 2389 |
| 1953 | 2141 |
| 1954 | 2063 |
| 1955 | 1426 |
| 1956 | 258 |
| 1957 | 185 |
| 1958 | 162 |
| 1959 | 157 |
| 1960 | 154 |
| 1961 | 112 |
| 1962 | 121 |
| 1963 | 85 |
| 1964 | 101 |
| 1965 | 91 |
| 1966 | 69 |
| 1967 | 53 |
| 1968 | 64 |
| 1969 | 53 |
| 1970 | 57 |
| 1971 | 47 |
| 1972 | 42 |
| 1973 | 44 |
| 1974 | 34 |
| 1975 | 59 |
| 1976 | 30 |
| 1977 | 40 |
| 1978 | 31 |
| 1979 | 35 |
| 1980 | 41 |
| 1981 | 33 |
| 1982 | 33 |
| 1983 | 42 |
| 1984 | 41 |
| 1985 | 43 |
| 1986 | 40 |
| 1987 | 48 |
| 1988 | 42 |
| 1989 | 33 |
| 1990 | 54 |
| 1991 | 45 |
| 1992 | 48 |
| 1993 | 48 |
| 1994 | 55 |
| 1995 | 50 |
| 1996 | 72 |
| 1997 | 57 |
| 1998 | 70 |
| 1999 | 98 |
| 2000 | 112 |
| 2001 | 97 |
| 2002 | 45 |

![Age Distribution](http://openrecords.org/index_files/DallasPurgedVotersbyAge.jpg)

You can see this data in chart form [here](http://openrecords.org/stories/hackerstargetseniors.html). As you can see, this "glitch" affects only those voters older than 65 years, and you can see both from the table and the figure that the jump between below and above 65 year old is really sharp. It is as if someone intentionally programmed to modify the votes based on an age cutoff.Based on this observation, I am leaning more toward foul play than software glitch, although glitch would be serious enough.

This Dallas observation is unlike many other claims of election tampering, because here you have the data of real votes being tampered and not a probabilistic model. We know exactly who those voters are, where they live, their age and so on. Moreover, the number is substantial to swing local and national elections. Finally, this raises the question that what else happened that did not get caught? If there was foul play, did it manipulate fake votes undetected by this analysis? 

All credits for originally finding these patterns go to the other volunteers of the openrecords project, whereas my role is in just confirming them independently. Moreover, they interviewed actual voters, whose votes got purged or manipulated and [confirmed that they did not vote twice](http://openrecords.org/stories/purgedpeople.html).  If you like to see those details, please check [their website](http://openrecords.org).


