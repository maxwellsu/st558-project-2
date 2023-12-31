CFBD API Vignette
================
Maxwell Su

## Prerequisite Packages

For this vignette I will use the following packages:

- `httr`
- `jsonlite`
- `tidyverse`
- `maps`

Where `httr` and `jsonlite` are used for accessing the API, and
`tidyverse` is used for processing and presenting the data pulled.
`maps` is used to aid in plotting coordinates.

## Functions to Pull from API

The first function to write simply takes in the user’s API key and
processes it in a way that the API can use.

``` r
getAPIKey <- function(apiKey){
  output <- paste("Bearer", apiKey)
  return(output)
}
```

`teams`

The first real function provides details on each team that the database
has information on. The optional argument `conference` when specified
returns only teams in that conference. Conferences must be provided in
abbreviated form (such as `ACC`, `PAC`, or `SEC`).

The last parameter is the API key, required to access the data.

This function, as well as the remaining functions, pulls data from the
database by starting with a base URL to query and adding additional
parameters to the URL. The resulting data is then processed into a
presentable data format.

``` r
teams <- function(conference = "", apiKey){
  string <- "https://api.collegefootballdata.com/teams"
  if(conference != ""){
    string <- paste(string, "?conference=", conference, sep = "")
  }
  output <- GET(string, add_headers(Authorization = apiKey, Accept = "application/json"))
  output <- rawToChar(output$content)
  output <- fromJSON(output, flatten = TRUE)
  return(output)
}
```

`games`

The next function queries the games in the database. The size of this
data means that a `year` must be specified, and even then an additional
condition is suggested in order to reduce the overhead. Of the remaining
filters, the ones I have chosen are `week` and `team`.

The games are split into regular season and postseason games, with the
season type needing to be specified. By default, the output will be of
regular season games.

``` r
games <- function(year, week = "", seasonType = "regular", team = "", apiKey){
  string <- paste("https://api.collegefootballdata.com/games?year=", year, sep = "")
  if(week != ""){
    string <- paste(string, "&week=", week, sep = "")
  }
  string <- paste(string, "&seasonType=", seasonType, sep = "")
  if(team != ""){
    team <- gsub(" ", "%20", team)
    string <- paste(string, "&team=", team, sep = "")
  }
  output <- GET(string, add_headers(Authorization = apiKey, Accept = "application/json"))
  output <- rawToChar(output$content)
  output <- fromJSON(output, flatten = TRUE)
  return(output)
}
```

`records`

This function returns win-loss data for teams. The API requires that at
least one of `year` and `team` is specified. The optional parameter
`conference` can be used to output conference standings for a year.

``` r
records <- function(year = "", team = "", conference = "", apiKey){
  string <- paste("https://api.collegefootballdata.com/records?")
  if(year != ""){
    string <- paste(string, "year=", year, "&", sep = "")
  }
  if(team != ""){
    team <- gsub(" ", "%20", team)
    string <- paste(string, "team=", team, "&", sep = "")
  }
  if(conference != ""){
    string <- paste(string, "conference=", conference, "&",sep = "")
  }
  string <- str_sub(string, end = -2)
  output <- GET(string, add_headers(Authorization = apiKey, Accept = "application/json"))
  output <- rawToChar(output$content)
  output <- fromJSON(output, flatten = TRUE)
  return(output)
}
```

`venues`

This function returns data on the stadiums where college football games
have been played. There are no optional arguments.

``` r
venues <-  function(apiKey){
  string <- paste("https://api.collegefootballdata.com/venues")
  output <- GET(string, add_headers(Authorization = apiKey, Accept = "application/json"))
  output <- rawToChar(output$content)
  output <- fromJSON(output, flatten = TRUE)
  return(output)
}
```

`roster`

This function returns roster data for teams. Optional arguments for
`team` and `year` can be specified. Roster data exists going back to the
year 2004, however, the earlier the data requested is, the more likely
it is to be incomplete.

``` r
roster <- function(year = "", team = "", apiKey){
  string <- paste("https://api.collegefootballdata.com/roster?")
  if(team != ""){
    team <- gsub(" ", "%20", team)
    string <- paste(string, "team=", team, "&", sep = "")
  }
  if(year != ""){
    string <- paste(string, "year=", year, "&", sep = "")
  }
  string <- str_sub(string, end = -2)
  output <- GET(string, add_headers(Authorization = apiKey, Accept = "application/json"))
  output <- rawToChar(output$content)
  output <- fromJSON(output, flatten = TRUE)
  return(output)
}
```

`talent`

This function returns the 247Sports talent composite for each team. The
optional parameter `year` can be specified to subset the data. The
talent composite is a value calculated to summarize the a team’s overall
quality dependent on both the composite ranking of a team’s recruits, as
well as the number of recruits that team has.

``` r
talent <- function(year = "", apiKey){
  string <- paste("https://api.collegefootballdata.com/talent")
  if(year != ""){
    string <- paste(string, "?year=", year, sep = "")
  }
  output <- GET(string, add_headers(Authorization = apiKey, Accept = "application/json"))
  output <- rawToChar(output$content)
  output <- fromJSON(output, flatten = TRUE)
  return(output)
}
```

## Exploratory Data Analysis

with the functions defined, it is time to use them to explore the data a
bit, and perhaps shed a little light onto the odd quirks and footnotes
of college football.

But first, to get the API key. I’ve hidden mine as `apiKey`.

``` r
cfbd_api_key <- getAPIKey(apiKey)
```

Let’s take a look at the Big Ten.

``` r
bigTenTeams <- teams(conference = "B1G", cfbd_api_key)
bigTenTeams <- bigTenTeams %>% 
  select(school, mascot, abbreviation, conference, 
         venue = location.name, city = location.city, state = location.state)
bigTenTeams
```

    ## # A tibble: 14 × 7
    ##    school         mascot          abbreviation conference venue                city            state
    ##    <chr>          <chr>           <chr>        <chr>      <chr>                <chr>           <chr>
    ##  1 Illinois       Fighting Illini ILL          Big Ten    Memorial Stadium     Champaign       IL   
    ##  2 Indiana        Hoosiers        IND          Big Ten    Memorial Stadium     Bloomington     IN   
    ##  3 Iowa           Hawkeyes        IOWA         Big Ten    Kinnick Stadium      Iowa City       IA   
    ##  4 Maryland       Terrapins       MD           Big Ten    Maryland Stadium     College Park    MD   
    ##  5 Michigan       Wolverines      MICH         Big Ten    Michigan Stadium     Ann Arbor       MI   
    ##  6 Michigan State Spartans        MSU          Big Ten    Spartan Stadium      East Lansing    MI   
    ##  7 Minnesota      Golden Gophers  MINN         Big Ten    TCF Bank Stadium     Minneapolis     MN   
    ##  8 Nebraska       Cornhuskers     NEB          Big Ten    Memorial Stadium     Lincoln         NE   
    ##  9 Northwestern   Wildcats        NW           Big Ten    Ryan Field           Evanston        IL   
    ## 10 Ohio State     Buckeyes        OSU          Big Ten    Ohio Stadium         Columbus        OH   
    ## 11 Penn State     Nittany Lions   PSU          Big Ten    Beaver Stadium       University Park PA   
    ## 12 Purdue         Boilermakers    PUR          Big Ten    Ross-Ade Stadium     West Lafayette  IN   
    ## 13 Rutgers        Scarlet Knights RUTG         Big Ten    SHI Stadium          Piscataway      NJ   
    ## 14 Wisconsin      Badgers         WIS          Big Ten    Camp Randall Stadium Madison         WI

It’s interesting how the Big Ten actually has 14 teams. The last time
the number was accurate was in 1989, prior to Penn State joining the
conference. With Oregon, UCLA, USC, and Washington the conference in
2024, we’re closer to the Big Twenty than we are to the Big Ten.

Perhaps the Big 12 will be less misleading.

``` r
big12Teams <- teams(conference = "B12", cfbd_api_key)
big12Teams <- big12Teams %>% 
  select(school, mascot, abbreviation, conference, 
         venue = location.name, city = location.city, state = location.state)
big12Teams
```

    ## # A tibble: 14 × 7
    ##    school         mascot       abbreviation conference venue                                     city       state
    ##    <chr>          <chr>        <chr>        <chr>      <chr>                                     <chr>      <chr>
    ##  1 Baylor         Bears        BAY          Big 12     McLane Stadium                            Waco       TX   
    ##  2 BYU            Cougars      BYU          Big 12     LaVell Edwards Stadium                    Provo      UT   
    ##  3 Cincinnati     Bearcats     CIN          Big 12     Nippert Stadium                           Cincinnati OH   
    ##  4 Houston        Cougars      HOU          Big 12     John O'Quinn Field at TDECU Stadium       Houston    TX   
    ##  5 Iowa State     Cyclones     ISU          Big 12     Jack Trice Stadium                        Ames       IA   
    ##  6 Kansas         Jayhawks     KU           Big 12     Memorial Stadium                          Lawrence   KS   
    ##  7 Kansas State   Wildcats     KSU          Big 12     Bill Snyder Family Football Stadium       Manhattan  KS   
    ##  8 Oklahoma       Sooners      OKLA         Big 12     Gaylord Family Oklahoma Memorial Stadium  Norman     OK   
    ##  9 Oklahoma State Cowboys      OKST         Big 12     Boone Pickens Stadium                     Stillwater OK   
    ## 10 TCU            Horned Frogs TCU          Big 12     Amon G. Carter Stadium                    Fort Worth TX   
    ## 11 Texas          Longhorns    TEX          Big 12     Darrell K Royal-Texas Memorial Stadium    Austin     TX   
    ## 12 Texas Tech     Red Raiders  TTU          Big 12     Jones AT&T Stadium                        Lubbock    TX   
    ## 13 UCF            Knights      UCF          Big 12     Bright House Networks Stadium             Orlando    FL   
    ## 14 West Virginia  Mountaineers WVU          Big 12     Mountaineer Field at Milan Puskar Stadium Morgantown WV

It seems that the Big 12 is also an inaccurate moniker, though with
Oklahoma and Texas on their way out in 2024, the name will once again be
true. It should be said that 4 of the current teams (BYU, Cincinnati,
Houston, and UCF) just recently joined in 2023, and during the 2012 and
2013 seasons, the Big Ten had 12 teams, and the Big 12 had 10 teams.
They did not (and will not) change their names, however, because the
only number that the Big 12 does not own the “Big X” naming rights to is
the number 10.

College football is weird.

One of the teams that switched between these two conferences is
Nebraska. Being one of college football’s blue bloods and one of the
greatest teams of the 90s, Nebraska left the conference they helped
found in 2011 for the Big Ten, citing increased stability and greater
revenue in their next destination.

While I cannot disagree with the increased revenue, the last decade of
Nebraska football has been nothing but unstable. I wanted to look at
Nebraska’s season records before and after their conference move, and
especially their ability to achieve bowl eligibility. The rules for bowl
eligibility have changed throughout the year, but generally is achieved
with as many wins as losses in a season, and while Nebraska fans
certainly hope for more, reaching a bowl game is at least the sign of a
redeemable season.

I created a contingency table for Nebraska seasons before and after
realignment, and whether they involved a bowl game.

``` r
nebraskaSeasons <- records(team = "Nebraska", apiKey = cfbd_api_key)
nebraskaSeasons <- nebraskaSeasons %>% select(year, team, conference, total.wins, total.losses) %>%
  filter(year >= 1928, year <= 2022) %>% 
  mutate(reallignment = case_when(conference == "Big Ten" ~ "After Realignment",
                                  TRUE ~ "Before Realignment"),
         bowl = (case_when(total.wins >= total.losses ~ "Bowl Eligible",
                           TRUE ~ "Bowl Ineligible")))
table(nebraskaSeasons$reallignment, nebraskaSeasons$bowl)
```

    ##                     
    ##                      Bowl Eligible Bowl Ineligible
    ##   After Realignment              5               7
    ##   Before Realignment            62              21

While the post-realignment sample size is much smaller, it does seem
that Nebraska’s winning ways have not come with them into their new
conference. While I’m sure the University of Nebraska has put that
additional money to good use, it doesn’t seem that it has gone to
playing winning football.

Changing gears to some more successful teams, in 2018 the idea of
“joyless murderball” arose to describe the Alabama Crimson Tide’s
commitment to playing unexciting, suffocating, dominating football.
While there may be some truth to the idea that these games are less
enjoyable, I’m sure both the fans and coaches alike don’t mind not
having to worry about their teams.

This begs the question, of the 8 national championship winning teams in
the CFP era (between 2014 Ohio State and 2022 Georgia), which was the
best at the game of joyless murderball? The college football database
has a metric known as the “Excitement Index”, that measures swings in
win-probability throughout each game, and returns a value that is higher
when there are more extreme swings in the game.

I calculated the average Excitement index for each regular season game
that the teams played.

``` r
OSU2014 <- games(year = 2014, team = "Ohio State", apiKey = cfbd_api_key)
OSU2014 <- OSU2014 %>% mutate(team = "2014 OSU", excitement_index = as.numeric(excitement_index)) %>%
  select(team, excitement_index)

BAMA2015 <- games(year = 2015, team = "Alabama", apiKey = cfbd_api_key)
BAMA2015 <- BAMA2015 %>% mutate(team = "2015 BAMA", excitement_index = as.numeric(excitement_index)) %>%
  select(team, excitement_index)

CLEM2016 <- games(year = 2016, team = "Clemson", apiKey = cfbd_api_key)
CLEM2016 <- CLEM2016 %>% mutate(team = "2016 CLEM", excitement_index = as.numeric(excitement_index)) %>%
  select(team, excitement_index)

BAMA2017 <- games(year = 2017, team = "Alabama", apiKey = cfbd_api_key)
BAMA2017 <- BAMA2017 %>% mutate(team = "2017 BAMA", excitement_index = as.numeric(excitement_index)) %>%
  select(team, excitement_index)

CLEM2018 <- games(year = 2018, team = "Clemson", apiKey = cfbd_api_key)
CLEM2018 <- CLEM2018 %>% mutate(team = "2018 CLEM", excitement_index = as.numeric(excitement_index)) %>%
  select(team, excitement_index)

LSU2019 <- games(year = 2019, team = "LSU", apiKey = cfbd_api_key)
LSU2019 <- LSU2019 %>% mutate(team = "2019 LSU", excitement_index = as.numeric(excitement_index)) %>%
  select(team, excitement_index)

BAMA2020 <- games(year = 2020, team = "Alabama", apiKey = cfbd_api_key)
BAMA2020 <- BAMA2020 %>% mutate(team = "2020 BAMA", excitement_index = as.numeric(excitement_index)) %>%
  select(team, excitement_index)

UGA2021 <- games(year = 2021, team = "Georgia", apiKey = cfbd_api_key)
UGA2021 <- UGA2021 %>% mutate(team = "2021 UGA", excitement_index = as.numeric(excitement_index)) %>%
  select(team, excitement_index)

UGA2022 <- games(year = 2022, team = "Georgia", apiKey = cfbd_api_key)
UGA2022 <- UGA2022 %>% mutate(team = "2022 UGA", excitement_index = as.numeric(excitement_index)) %>%
  select(team, excitement_index)

cfpExcitement <- rbind(OSU2014, BAMA2015, CLEM2016, BAMA2017, CLEM2018, LSU2019, BAMA2020, UGA2021, UGA2022)
cfpExcitement <- cfpExcitement %>% group_by(team) %>% summarise(mean = mean(excitement_index))
cfpExcitement
```

    ## # A tibble: 9 × 2
    ##   team       mean
    ##   <chr>     <dbl>
    ## 1 2014 OSU   2.94
    ## 2 2015 BAMA  3.11
    ## 3 2016 CLEM  3.74
    ## 4 2017 BAMA  1.72
    ## 5 2018 CLEM  1.85
    ## 6 2019 LSU   2.21
    ## 7 2020 BAMA  2.07
    ## 8 2021 UGA   2.04
    ## 9 2022 UGA   2.21

``` r
ggplot(data = cfpExcitement, aes(x = team, y = mean)) + 
  geom_bar(stat = "identity", aes(x = reorder(team, mean), fill = team)) + 
  labs(title = "Mean Excitement Index of Regular Season Games, CFP Winning Teams", x = "Team", y = "Excitement Index") +
  theme(legend.position = "none")
```

![](README_files/figure-gfm/unnamed-chunk-13-1.png)<!-- -->

The 2017 Crimson Tide were the best at playing joyless murderball, while
the 2016 Clemson Tigers played the most exciting games of any of the
College Football Playoff winners.

``` r
FSU2014 <- games(year = 2014, team = "Florida State", apiKey = cfbd_api_key)
mean(as.numeric(FSU2014$excitement_index))
```

    ## [1] 4.789804

For comparison, 2014 Florida State, a team known for being on the right
side of numerous close games on their way to a perfect regular season,
recorded an average excitement index of 4.789804.

The 2017 FBS season does warrant a closer look. It was a season that
featured a lot, from Georgia’s first taste at being among college
football’s elite in the playoff era, the last hurrah of Stanford’s time
in the spotlight, and the first time the College Football Playoff format
was challenged, with 12-0 UCF not being selected for the playoffs and
claiming a national championship via the Colley Matrix.

In such a chaotic season, It would be interesting to see which teams
were least affected by it. I pulled the records of every FBS team in the
2017 season, and calculated the difference between their actual wins and
expected wins.

``` r
records2017 <- records(year = 2017, apiKey = cfbd_api_key)
records2017 <- records2017 %>% mutate(win.difference = total.wins - expectedWins)
```

The 5 teams that most overperformed their expected wins in 2017 included
the PAC-12 champions USC, Sun Belt co-champions Troy, and your Colley
Matrix National Champions UCF.

``` r
records2017 %>% select(team, total.wins, expectedWins, win.difference) %>% 
  arrange(desc(win.difference), desc(total.wins)) %>% head(5)
```

    ## # A tibble: 5 × 4
    ##   team         total.wins expectedWins win.difference
    ##   <chr>             <int>        <dbl>          <dbl>
    ## 1 UCF                  13         11.1            1.9
    ## 2 Akron                 7          5.3            1.7
    ## 3 Troy                 11          9.3            1.7
    ## 4 USC                  11          9.4            1.6
    ## 5 Kansas State          8          6.4            1.6

The team that most underperformed their expected win total in 2017 was
Arkansas State. The top 5 includes a 1-11 Baylor team that was reeling
from the fallout of their football scandal.

``` r
records2017 %>% select(team, total.wins, expectedWins, win.difference) %>% 
  arrange(win.difference, desc(total.wins)) %>% head(5)
```

    ## # A tibble: 5 × 4
    ##   team           total.wins expectedWins win.difference
    ##   <chr>               <int>        <dbl>          <dbl>
    ## 1 Arkansas State          7          9.4           -2.4
    ## 2 Miami (OH)              5          7.1           -2.1
    ## 3 Idaho                   4          6             -2  
    ## 4 Baylor                  1          3             -2  
    ## 5 New Mexico              3          4.7           -1.7

Five teams won just as many games as they were expected to in 2017, the
most noteworthy being the Wisconsin Badgers. The team finished 12-0,
before losing the Big Ten Championship to Ohio State in the time-honored
tradition of the Big Ten West team losing to the Big Ten East team in
the championship (The Big Ten West team has never won the conference
since the current divisions were adopted in 2014) before rebounding with
a win over Miami (FL) in the Orange Bowl.

``` r
records2017 %>% select(team, total.wins, expectedWins, win.difference) %>% 
  arrange(abs(win.difference), desc(total.wins)) %>% head(5)
```

    ## # A tibble: 5 × 4
    ##   team              total.wins expectedWins win.difference
    ##   <chr>                  <int>        <dbl>          <dbl>
    ## 1 Wisconsin                 13           13              0
    ## 2 Michigan                   8            8              0
    ## 3 Northern Illinois          8            8              0
    ## 4 Cincinnati                 4            4              0
    ## 5 San José State             2            2              0

Credit to Wisconsin, however, as their 27-21 loss in the conference
championship was a much better showing compared to their previous
matchup in 2014:

![](Pictures/Screenshot.png)

At least they won the coin toss.

``` r
ggplot(data = records2017, aes(x = win.difference)) + 
  geom_histogram(bins = 7, fill = "#FF7777") +
  labs(title = "Difference between Expected wins and Actual wins for FBS Teams in 2017",
       x = "Actual wins - Expected Wins", y = "Count")
```

![](README_files/figure-gfm/unnamed-chunk-19-1.png)<!-- -->

Plotting a histogram of all of the difference values returns a rather
bell-shaped distribution. This makes sense, as there is only a limited
number of wins to be had, so for a team to overachieve, another team
must underachieve.

Going back to the discussion on the national champions, The LSU Tiger’s
2019 team is generally regarded as one of the greatest college football
teams of all time. I’ve always maintained that LSU has one of the
greatest advantages in college football, being the only power 5 school
in the state of Louisiana, a fairly significant recruiting hotbed. Other
national championship winning teams such as Alabama, Georgia, and
Clemson have to contend with other power 5 schools in their states
(Auburn, Georgia Tech, and South Carolina respectively).

To see if my theory holds any water, I compared the number of in-state
athletes in LSU’s title winning team to the other CFP winning teams, to
see if the ratio of any team is significantly higher.

``` r
OSU2014Roster <- roster(year = 2014, team = "Ohio State", apiKey = cfbd_api_key)
OSU2014Roster <- OSU2014Roster %>% 
  mutate(team = "2014 Ohio State", team_state = "OH") %>% 
  select(team, home_state, team_state) %>% replace_na(list(home_state = ""))

BAMA2015Roster <- roster(year = 2015, team = "Alabama", apiKey = cfbd_api_key)
BAMA2015Roster <- BAMA2015Roster %>% 
  mutate(team = "2015 Alabama", team_state = "AL") %>% 
  select(team, home_state, team_state) %>% replace_na(list(home_state = ""))

CLEM2016Roster <- roster(year = 2016, team = "Clemson", apiKey = cfbd_api_key)
CLEM2016Roster <- CLEM2016Roster %>% 
  mutate(team = "2016 Clemson", team_state = "SC") %>% 
  select(team, home_state, team_state) %>% replace_na(list(home_state = ""))

BAMA2017Roster <- roster(year = 2017, team = "Alabama", apiKey = cfbd_api_key)
BAMA2017Roster <- BAMA2017Roster %>% 
  mutate(team = "2017 Alabama", team_state = "AL") %>% 
  select(team, home_state, team_state) %>% replace_na(list(home_state = ""))

CLEM2018Roster <- roster(year = 2018, team = "Clemson", apiKey = cfbd_api_key)
CLEM2018Roster <- CLEM2018Roster %>% 
  mutate(team = "2018 Clemson", team_state = "SC") %>% 
  select(team, home_state, team_state) %>% replace_na(list(home_state = ""))

LSU2019Roster <- roster(year = 2019, team = "LSU", apiKey = cfbd_api_key)
LSU2019Roster <- LSU2019Roster %>% 
  mutate(team = "2019 LSU", team_state = "LA") %>% 
  select(team, home_state, team_state) %>% replace_na(list(home_state = ""))

BAMA2020Roster <- roster(year = 2020, team = "Alabama", apiKey = cfbd_api_key)
BAMA2020Roster <- BAMA2020Roster %>% 
  mutate(team = "2020 Alabama", team_state = "AL") %>% 
  select(team, home_state, team_state) %>% replace_na(list(home_state = ""))

UGA2021Roster <- roster(year = 2021, team = "Georgia", apiKey = cfbd_api_key)
UGA2021Roster <- UGA2021Roster %>% 
  mutate(team = "2021 Georgia", team_state = "GA") %>% 
  select(team, home_state, team_state) %>% replace_na(list(home_state = ""))

UGA2022Roster <- roster(year = 2022, team = "Georgia", apiKey = cfbd_api_key)
UGA2022Roster <- UGA2022Roster %>% 
  mutate(team = "2022 Georgia", team_state = "GA") %>% 
  select(team, home_state, team_state) %>% replace_na(list(home_state = ""))

cfpRosters <- rbind(OSU2014Roster, BAMA2015Roster, CLEM2016Roster, BAMA2017Roster, 
                    CLEM2018Roster, LSU2019Roster, BAMA2020Roster, UGA2021Roster, UGA2022Roster)

cfpRosters <- cfpRosters %>% group_by(team) %>% mutate(team_state = (team_state == home_state)) %>%
  summarise(ratio = sum(team_state) / n())

cfpRosters
```

    ## # A tibble: 9 × 2
    ##   team            ratio
    ##   <chr>           <dbl>
    ## 1 2014 Ohio State 0.485
    ## 2 2015 Alabama    0.254
    ## 3 2016 Clemson    0.381
    ## 4 2017 Alabama    0.337
    ## 5 2018 Clemson    0.429
    ## 6 2019 LSU        0.554
    ## 7 2020 Alabama    0.363
    ## 8 2021 Georgia    0.595
    ## 9 2022 Georgia    0.6

``` r
ggplot(data = cfpRosters, aes(x = team, y = ratio)) + 
  geom_bar(stat = "identity", aes(x = reorder(team, ratio), fill = team)) + 
  coord_flip() + 
  labs(title = "Proportion of Roster that was In-State for CFP Winning Teams", x = "Team", y = "Ratio") +
  theme(legend.position = "none")
```

![](README_files/figure-gfm/unnamed-chunk-20-1.png)<!-- -->

I suppose my theory is somewhat reinforced by Ohio State and LSU having
higher ratios of in-state athletes than Alabama and Clemson, however I
was a bit surprised at Georgia’s national championship winning teams
having at or around 60% of their athletes come from in-state.

I may have been a bit generous when I referred to Georgia Tech as a
Power 5 school.

Talent is important to the success of a football team. However, just
because a team has talent, doesn’t mean they will find success. The 2021
season was noteworthy for many teams starting the season ranked and
finishing the season rather poorly. To see which teams overachieved and
underachieved considering their rosters in 2021, I tried to plot the
winning percentage of each team given their 247Sports talent composite.

``` r
winPercentage2021 <- records(year = 2021, apiKey = cfbd_api_key)
winPercentage2021 <- winPercentage2021 %>% 
  select(team, conference, total.games, total.wins) %>% mutate(win.percentage = total.wins / total.games)
talent2021  <- talent(year = 2021, apiKey = cfbd_api_key)
talent2021$talent <- as.numeric(talent2021$talent)
winPercentage2021 <- inner_join(winPercentage2021, talent2021, by = join_by(team == school))

ggplot(data = winPercentage2021, aes(x = talent, y = win.percentage)) + 
  geom_point(aes(color = conference)) + 
  labs(title = "247Sports Talent Composite vs. Win percentage, 2021 FBS Season",
       x = "247Sports Talent Composite", y = "Win Percentage", color = "Conference")
```

![](README_files/figure-gfm/unnamed-chunk-21-1.png)<!-- -->

It should not come as too large a surprise that the two teams that
competed in the national championship game were those with the highest
talent composites - Georgia(SEC) and Alabama(SEC). The two teams with
the lowest talent composite, Air Force(MW) and Army(Ind), heavily
overperformed their talent, a testament to the triple option, although
the remaining service academy, Navy(AAC), with the 4th lowest talent
composite, was not as fortunate. Playoff team Cincinnati(AAC) finished
12-1 with a middle-of-the-road roster, while the team that perhaps
performed the worst with high-end talent was USC(PAC), whose 10th best
team talent-wise only yielded a 4-8 record.

I’ll now briefly go through some of the more interesting quirks of
recent college football history.

``` r
bigTenRecords2016 <- records(year = 2016, conference = "B1G", apiKey = cfbd_api_key)
bigTenRecords2016 %>% select(team, conference, division, total.wins, total.losses) %>%
  arrange(desc(total.wins), total.losses)
```

    ## # A tibble: 14 × 5
    ##    team           conference division total.wins total.losses
    ##    <chr>          <chr>      <chr>         <int>        <int>
    ##  1 Ohio State     Big Ten    East             11            2
    ##  2 Penn State     Big Ten    East             11            3
    ##  3 Wisconsin      Big Ten    West             11            3
    ##  4 Michigan       Big Ten    East             10            3
    ##  5 Minnesota      Big Ten    West              9            4
    ##  6 Nebraska       Big Ten    West              9            4
    ##  7 Iowa           Big Ten    West              8            5
    ##  8 Northwestern   Big Ten    West              7            6
    ##  9 Indiana        Big Ten    East              6            7
    ## 10 Maryland       Big Ten    East              6            7
    ## 11 Michigan State Big Ten    East              3            9
    ## 12 Illinois       Big Ten    West              3            9
    ## 13 Purdue         Big Ten    West              3            9
    ## 14 Rutgers        Big Ten    East              2           10

In 2016, Penn State finished the regular season 11-2 as the Big Ten
champions. Ohio State finished 11-1, with their only loss coming against
Penn State to deny them their Big Ten Championship Game berth. Come
playoff selection time, Ohio State was selected over Penn State, which
only goes to show that college football is one of the few sports where
losses matter more than wins.

``` r
big12Records2008 <- records(year = 2008, conference = "B12", apiKey = cfbd_api_key)
big12Records2008 %>% select(team, conference, division, total.wins, total.losses) %>%
  arrange(desc(total.wins), total.losses)
```

    ## # A tibble: 12 × 5
    ##    team           conference division total.wins total.losses
    ##    <chr>          <chr>      <chr>         <int>        <int>
    ##  1 Texas          Big 12     South            12            1
    ##  2 Oklahoma       Big 12     South            12            2
    ##  3 Texas Tech     Big 12     South            11            2
    ##  4 Missouri       Big 12     North            10            4
    ##  5 Nebraska       Big 12     North             9            4
    ##  6 Oklahoma State Big 12     South             9            4
    ##  7 Kansas         Big 12     North             8            5
    ##  8 Colorado       Big 12     North             5            7
    ##  9 Kansas State   Big 12     North             5            7
    ## 10 Baylor         Big 12     South             4            8
    ## 11 Texas A&M      Big 12     South             4            8
    ## 12 Iowa State     Big 12     North             2           10

In 2008, the Big 12 South was caught up in a three-way tie, with Texas,
Oklahoma, and Texas Tech each finishing with an 11-1 record. Texas won
over Oklahoma, Texas Tech beat Texas, and Oklahoma beat Texas Tech.
Owing to their records, whoever was chosen to represent the Big 12 South
in the conference championship game would likely win and play in the BCS
National Championship game. The tiebreaker would ultimately be the BCS
rankings, and Oklahoma ended up with a National Championship Game berth,
meaning that the BCS had effectively influenced its own rankings.

College football is weird.

The last thing I’d like to do is look at the stadiums in which college
football games are played.

``` r
cfbVenues <- venues(apiKey = cfbd_api_key)
cfbVenues <- cfbVenues %>% select(name, capacity, city, state, location.x, location.y)
cfbVenues %>% select(name, city, state, capacity) %>% arrange(desc(capacity)) %>% head(10)
```

    ## # A tibble: 10 × 4
    ##    name                                   city            state capacity
    ##    <chr>                                  <chr>           <chr>    <int>
    ##  1 Bristol Motor Speedway                 Briston         TN      162000
    ##  2 Michigan Stadium                       Ann Arbor       MI      107601
    ##  3 Beaver Stadium                         University Park PA      106572
    ##  4 Ohio Stadium                           Columbus        OH      102780
    ##  5 Kyle Field                             College Station TX      102733
    ##  6 Neyland Stadium                        Knoxville       TN      102455
    ##  7 Tiger Stadium                          Baton Rouge     LA      102321
    ##  8 Bryant Denny Stadium                   Tuscaloosa      AL      101821
    ##  9 Darrell K Royal-Texas Memorial Stadium Austin          TX      100119
    ## 10 AT&T Stadium                           Arlington       TX      100000

The largest stadium by capacity to ever host a college football game is
Bristol Motor Speedway (featuring a rather egregious typo in the city).
In 2016, it hosted Tennessee’s 45-24 win over Virginia Tech, as well as
East Tennessee’s 34-31 win over Western Carolina, a testament to the
stadium’s ability to host both good racing and good football.

The remaining stadiums in the top ten include three Big Ten stadiums
(Michigan, Beaver and Ohio stadiums being Michigan, Penn State and Ohio
State’s home stadiums respectively), 4 SEC stadiums (Kyle Field,
Neyland, Tiger and Bryant Denny stadiums being Texas A&M, Tennessee, LSU
and Alabama’s home stadiums respectively), one Big 12 stadium (Darrell K
Royal-Texas Memorial Stadium being the SEC-bound Texas’s home stadium),
and another neutral site, with Jerry World (AT&T Stadium) being the
sight of the Red River Shootout between Texas and Oklahoma.

I wanted to plot the locations of each stadium to host a college
football game in the continental US:

``` r
cfbVenues <- cfbVenues %>% filter(!(state %in% c("", "HI", "NSW")))
us <- map_data(map = "usa")
ggplot() + 
  geom_map(data = us, map = us, aes(long, lat, map_id = region), color = "black", fill = "white") +
  geom_point(data = cfbVenues, aes(location.y, location.x, 
                                   size = cut(capacity, c(-1, 40000, 80000, 120000, Inf)), 
                                   color = cut(capacity, c(-1, 40000, 80000, 120000, Inf)))) +
  labs(title = "College Football Stadiums in the Lower 48", 
       x = "Lattitude", y = "Longitude", color = "Capacity", size = "Capacity") +
  scale_color_manual(labels = c("0-40000", "40001-80000", "80001-120000", "120000+"), 
                    values = c("#33AAAA", "#FF99AA", "#66CC66", "#FF9933")) +
  scale_size_manual(labels = c("0-40000", "40001-80000", "80001-120000", "120000+"),
                    values = c(1, 2, 3, 4))
```

![](README_files/figure-gfm/unnamed-chunk-25-1.png)<!-- -->

## Wrap Up

To close, I’ve written functions to access various endpoints of the
College Football Database, and I’ve used them to pull data and conduct
various analyses. I hope to have shed some light on the more interesting
factoids and tidbits of what makes this magically strange sport what it
is.

It is my hope that the reader of this would learn something about
college football, as well as something about interacting with APIs.
