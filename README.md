# WomenLegislators

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

One possible solution, in Ruby:

```ruby
#!/usr/bin/env ruby -w

require "date"
require "yaml"

class Parser
  def initialize(files)
    @files = files
  end

  attr_reader :files
  private     :files

  def parse
    files.inject([ ]) { |data, file| data + YAML.load_file(file) }
  end
end

class Filter
  def initialize(data)
    @data = data
  end

  attr_reader :data
  private     :data

  def filter
    years_running.each_with_object({ }) { |year, counts|
      counts[year] = counts_by_year[year] || 0
    }
  end

  private

  def counts_by_year
    @counts_by_year ||=
      Hash[
        data
          .select { |person| person.dig("bio", "gender") == "F" }
          .flat_map { |woman| woman["terms"] }
          .select { |term| term["type"] == "rep" }
          .map { |term| term.values_at("start", "end") }
          .flat_map { |start_date, end_date| to_years(start_date, end_date) }
          .group_by(&:itself)
          .map { |year, terms| [year, terms.size] }
      ]
  end

  def years_running
    from, to =
      data
        .flat_map { |person| person["terms"] }
        .select { |term| term["type"] == "rep" }
        .flat_map { |term| to_years(*term.values_at("start", "end")) }
        .minmax
    from..to
  end

  def to_years(start_date, end_date)
    from = Date.parse(start_date).year
    to_date = Date.parse(end_date)
    to = to_date.year - (to_date.month == 1 ? 1 : 0)
    (from..to).to_a
  end
end

class Histogram
  def initialize(counts_by_year)
    @counts_by_year = counts_by_year
  end

  attr_reader :counts_by_year
  private     :counts_by_year

  def graph
    counts_by_year
      .chunk { |_year, count| count }
      .map { |count, years|
        "#{years.first.first}-#{years.last.first}:  #{'#' * count}"
      }
  end
end

if ARGV.empty?
  abort "USAGE:  #{$PROGRAM_NAME} FILE_1 [FILE_2 .. FILE_N]"
end

puts Histogram.new(Filter.new(Parser.new(ARGV).parse).filter).graph
```

### Constraints

* Most people filter the start year of the House of Representatives out of the data (because the were no women).  A lot of people then hardcode for the histogram.  (Honestly, that's fine.  It's not like it changes, which makes a great talking point.)  It's an extra challenge if you push them to get it from the data though.

### Spec: in progressive difficulty

* Just handle the `legislators-current.yaml` data.  It's fine to just output number's by year at this point.  I show them they only need [gender (in the bio section)](https://github.com/unitedstates/congress-legislators/blob/ac55afa44721a6cdd58c337ac73e0c7a0c5841a2/legislators-current.yaml#L23-L25) and [terms](https://github.com/unitedstates/congress-legislators/blob/ac55afa44721a6cdd58c337ac73e0c7a0c5841a2/legislators-current.yaml#L27-L97).  I also show [an example of a legislator that switched congressional branches](https://github.com/unitedstates/congress-legislators/blob/ac55afa44721a6cdd58c337ac73e0c7a0c5841a2/legislators-current.yaml#L124-L137) and clarify that we only care about time in the House of Representatives.
* Add the special case of not counting a end dates like January 3rd as having served that year.  Only don't count January.  It's a heuristic and doesn't work for all cases (terms use to end in March or April), but it's close enough.
* Build the histogram, one row per year.
* Add the other challenge of collapsing identical consecutive years in the histogram.
* Introduce `legislators-historical.yaml` to see if there code chokes on moderate size data.

### Things to watch for or to prod for

* Elm is a terrible choice for solving this problem in, because it's hard to get all of the data in and parsed.
* I like to see the problem approached as a pipeline of data transformations.
* The challenge can definitely be completed in 90 minutes.  I don't require, but it's good to bare in mind.
* A lot of people want to hold onto some ID (or name) for each legislator.  This is irrelevant to the challenge, but can lead to great discussions (like the value of having it for debugging).
* I often get good discussions out of asking how much memory their code uses (you can throwaway almost all the data as it is read in) and **if** it's "too slow."  I rarely think they're over the line, but it's good to hear their thoughts and talk about potential optimizations for down the road.
* Candidates sometimes ask me how many women each `#` represents.  It's one.  I like to get their reactions.  I find it sad.  We're nowhere near even today.  I also point out my favorite line in the data:  [the women who predates the right to vote](http://history.house.gov/People/Listing/R/RANKIN,-Jeannette-(R000055)/)!
* It's helpful to know, when watching candidates, that 88 is the correct number for 2016.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `women_legislators` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:women_legislators, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/women_legislators](https://hexdocs.pm/women_legislators).

