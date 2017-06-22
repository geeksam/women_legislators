# Spoilers!

## Solution

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

## Things to watch for or to prod for

* Elm is a terrible choice for solving this problem in, because it's
  hard to get all of the data in and parsed.
* I like to see the problem approached as a pipeline of data
  transformations.
* The challenge can definitely be completed in 90 minutes.  I don't
  require, but it's good to bare in mind.
* A lot of people want to hold onto some ID (or name) for each
  legislator.  This is irrelevant to the challenge, but can lead to
  great discussions (like the value of having it for debugging).
* I often get good discussions out of asking how much memory their code
  uses (you can throwaway almost all the data as it is read in) and
  **if** it's "too slow."  I rarely think they're over the line, but
  it's good to hear their thoughts and talk about potential
  optimizations for down the road.
* Candidates sometimes ask me how many women each `#` represents.  It's
  one.  I like to get their reactions.  I find it sad.  We're nowhere
  near even today.  I also point out my favorite line in the data:  [the
  women who predates the right to
  vote](http://history.house.gov/People/Listing/R/RANKIN,-Jeannette-(R000055)/)!
* It's helpful to know, when watching candidates, that 88 is the correct
  number for 2016.

