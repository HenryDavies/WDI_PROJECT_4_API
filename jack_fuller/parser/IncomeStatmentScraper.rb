require 'nokogiri'
require 'pp'
require 'pry'
require 'yaml'
load 'ParserAndScraper.rb'

class IncomeStatementScraper < ParserAndScraper

  def get_date_divs
    query = "//body//tr//th[@class='th']"
    @date_divs = get_nokogiri_objects(query)[1..-1]
  end

  def create_yearly_results_hash date, column_index
    {
      is_id: 1,
      year: get_year_integer(date),
      date: date,
      units: get_units,
      sales: get_cell_float("SALES", column_index),
      cogs: get_cell_float("COGS", column_index),
      ebit: get_cell_float("EBIT", column_index),
      pbt: get_cell_float("PBT", column_index),
      tax: get_cell_float("TAX", column_index),
      net_income: get_cell_float("NET_INCOME", column_index),
      basic_eps: get_cell_float("BASIC_EPS", column_index),
      diluted_eps: get_cell_float("DILUTED_EPS", column_index)
    }
  end

  def initialize file, onclick_terms
    @onclick_terms = onclick_terms
    open_file file
    parse_file
    initialize_data_array
    get_date_divs
    get_date_strings
    get_document_period_end_date
    populate_data_array_with_cells
    Pry::ColorPrinter.pp(@data)
  end

end

# file = "./htmls/google_IS.html"
# file = "./htmls/apple_IS.html"
# file = "./htmls/pg_IS.html"
file = "./htmls/coke_IS.html"

onclick_terms_file = YAML.load_file('onclick_terms.yml')
onclick_terms = onclick_terms_file["income_statement"]

IS = IncomeStatementScraper.new file, onclick_terms
