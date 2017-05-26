defmodule WomenLegislators do
  @moduledoc """
  Documentation for WomenLegislators.
  """

  @doc """
  Hello world.

  ## Examples

      iex> WomenLegislators.hello
      :world

  """
  
  # With the function parens warnings find out if I should be adding parens even in pipelines.
  def run(time_period \\ "current") do
    get_parse_yaml(time_period)
    |> filter_females
    |> flatten_term_structure
    |> filter_rep_branch
    |> get_term_years_list
    |> count_females_per_year
    |> print_histogram
  end
  
  # Check what you did with dates on the terminal
  
  @spec get_parse_yaml(bitstring) :: list(%{})
  def get_parse_yaml("both") do
    current_dir = File.cwd!
    
    current_legislators = 
      current_dir
      |> Path.join("data/legislators-current.yaml")
      |> parse_yaml
      
    historical_legislators =
      current_dir
      |> Path.join("data/legislators-historical.yaml")
      |> parse_yaml
      
    historical_legislators ++ current_legislators
  end
  
  @spec get_parse_yaml(bitstring) :: list(%{})
  def get_parse_yaml(time_period) do
    File.cwd! 
    |> Path.join("data/legislators-#{time_period}.yaml")
    |> parse_yaml
  end
  
  @spec parse_yaml(bitstring) :: list(%{})
  defp parse_yaml(file_path) do
    YamlElixir.read_from_file(file_path)
  end
  
  @spec filter_females(list(%{})) :: list(%{})
  def filter_females(legislators_maps_list) do
    legislators_maps_list
    |> Enum.filter(fn(person) -> person["bio"]["gender"] == "F" end)
  end
  
  # I think that I could get rid of this step. Haven't played with data enough to know yet.
  # But for now it throws away everything but terms
  @spec flatten_term_structure(list(%{})) :: list(%{})
  def flatten_term_structure(only_females_maps_list) do
    only_females_maps_list
    |> Enum.flat_map(fn(female) -> female["terms"] end)
  end
  
  # Throwing away any terms that were not in house of reps.
  # Returns a list of maps.
  # Maybe it would make sense to combine with above function?
  @spec filter_rep_branch(list(%{})) :: list(%{})
  def filter_rep_branch(terms_maps_list) do
    terms_maps_list
    |> Enum.filter(fn(term) -> term["type"] == "rep" end)
  end
  
  # Takes a map of house of rep terms and pattern matches on the start and end.
  # Using finish instead of end as that seemed to break things.
  # Takes date string and converts to ISO formated date, grabs the year, and subtracts year since all terms in house end early.
  # TODO: Date parsing should be split into own function. There are edge cases where term begins and ends in same year.
  # Also long.
  @spec get_term_years_list(list(%{})) :: list
  def get_term_years_list(rep_terms_maps_list) do
    rep_terms_maps_list
    |> Enum.map(fn(%{"start" => start, "end" => finish}) -> check_years(Date.from_iso8601!(start), Date.from_iso8601!(finish)) end)
    |> List.flatten
  end
  
  # I really wanted to do in function heads or guard clauses but can't call remote function in them.
  defp check_years(start, finish) do
    cond do
      start.year == finish.year ->
        [start.year]
      start.year + 1 == finish.year && finish.month == 1 ->
        [start.year]
      finish.month == 1 ->
        [start.year, finish.year - 1]
      true -> 
        Enum.to_list start.year..finish.year 
    end
  end
  
  @spec count_females_per_year(list(%{})) :: list(%{})
  def count_females_per_year(flattened_years_list) do
    flattened_years_list
    |> Enum.group_by(&(&1))
    |> Enum.map(fn({key, val}) -> %{year: key, female_reps: Enum.count(val)} end)
  end
  
  # Should we include in the function name that the list is being sorted?
  # Something like sort_then_print_histogram
  def print_histogram(house_females_maps_list) do
    house_females_maps_list
    |> Enum.sort(&(&1.year <= &2.year)) 
    |> Enum.map(fn(%{year: year, female_reps: female_reps}) -> IO.puts("#{year}: #{String.duplicate("#", female_reps)}") end)
  end
end
