# WomenLegislators

Forked from https://github.com/brettwise/women_legislators

## Problem statement

**Women in the U.S. House of Representatives by Year**

Draw a histogram, using the `legislators-current.yaml` and `legislators-historical.yaml` files from [this dataset](https://github.com/unitedstates/congress-legislators), that shows a count of the number of women in the U.S. House of Representatives each year that it has existed.  There are two special concerns:

* Don't count the first month of the year before a new representative is sworn in
* Collapse years that have the same number

Here's some sample output:

```
1789-1916:  
1917-1919:  #
1920-1920:  
1921-1922:  ###
1923-1923:  ####
1924-1924:  #
1925-1925:  ####
1926-1926:  ###
1927-1927:  ########
1928-1928:  #####
1929-1929:  ##############
1930-1930:  #########
1931-1931:  ################
1932-1932:  #######
1933-1933:  ##############
1934-1934:  #######
1935-1938:  ######
1939-1940:  ########
1941-1941:  #########
1942-1944:  ########
1945-1946:  ###########
1947-1948:  #######
1949-1950:  #########
1951-1952:  ##########
1953-1954:  ############
1955-1956:  #################
1957-1958:  ###############
1959-1960:  #################
1961-1962:  ##################
1963-1964:  ############
1965-1968:  ###########
1969-1970:  ##########
1971-1972:  #############
1973-1974:  ################
            ################
1975-1976:  ###################
1977-1978:  ##################
1979-1980:  ################
1981-1982:  #####################
1983-1984:  ######################
1985-1986:  #######################
1987-1987:  ########################
1988-1988:  #######################
1989-1989:  ###########################
1990-1991:  #############################
1992-1992:  ##############################
            ##############################
1993-1995:  ################################################
1996-1996:  #################################################
1997-1997:  #####################################################
            #####################################################
1998-1998:  ########################################################
            ########################################################
1999-2000:  ##########################################################
2001-2003:  ##############################################################
2004-2004:  ###############################################################
            ###############################################################
2005-2005:  ######################################################################
            ######################################################################
2006-2006:  #######################################################################
            #######################################################################
2007-2008:  ############################################################################
            ############################################################################
2009-2009:  ##############################################################################
my 2009     ###############################################################################
2010-2010:  ############################################################################
            ############################################################################
2011-2012:  #############################################################################
            #############################################################################
2013-2013:  ##################################################################################
my 2013     ###################################################################################
2014-2014:  ###################################################################################
            ###################################################################################
2015-2016:  ########################################################################################
            ########################################################################################
my 2016     #########################################################################################
```

### Resources

### Constraints

* Most people filter the start year of the House of Representatives out
  of the data (because the were no women).  A lot of people then
  hardcode for the histogram.  (Honestly, that's fine.  It's not like it
  changes, which makes a great talking point.)  It's an extra challenge
  if you push them to get it from the data though.

### Spec: in progressive difficulty

* Just handle the `legislators-current.yaml` data.  It's fine to just
  output number's by year at this point.  I show them they only need
  [gender (in the bio
  section)](https://github.com/unitedstates/congress-legislators/blob/ac55afa44721a6cdd58c337ac73e0c7a0c5841a2/legislators-current.yaml#L23-L25)
  and
  [terms](https://github.com/unitedstates/congress-legislators/blob/ac55afa44721a6cdd58c337ac73e0c7a0c5841a2/legislators-current.yaml#L27-L97).
  I also show [an example of a legislator that switched congressional
  branches](https://github.com/unitedstates/congress-legislators/blob/ac55afa44721a6cdd58c337ac73e0c7a0c5841a2/legislators-current.yaml#L124-L137)
  and clarify that we only care about time in the House of
  Representatives.
* Add the special case of not counting a end dates like January 3rd as
  having served that year.  Only don't count January.  It's a heuristic
  and doesn't work for all cases (terms use to end in March or April),
  but it's close enough.
* Build the histogram, one row per year.
* Add the other challenge of collapsing identical consecutive years in
  the histogram.
* Introduce `legislators-historical.yaml` to see if there code chokes on
  moderate size data.

