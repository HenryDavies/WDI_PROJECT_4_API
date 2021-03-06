class ParserAndScraper

  def parse_file doc_to_parse
    @doc_to_scrape = Nokogiri::HTML.parse(doc_to_parse)
  end

  def initialize_data_array
    @data = []
  end

  def get_nokogiri_objects query
    @doc_to_scrape.xpath(query)
  end

  def get_date_strings
    @date_strings = @date_divs.collect do |div|
      div.text.gsub(/\n/, "").strip
    end
  end

  def get_year_integer date_string
    date_string.gsub(/[^\d]/, '')[-4..-1].to_i
  end

  def get_document_period_end_date
    query = "//body//tr//th[@class='th']"
    if get_nokogiri_objects(query)[1]
      @document_period_end_date = get_nokogiri_objects(query)[1].text
    else
      @document_period_end_date = get_nokogiri_objects(query)[0].text
    end
  end

  def populate_data_array_with_cells
    @date_strings.each_with_index do |date, index|
      @data[index] = create_yearly_results_hash date, index
    end
  end

  def negative_number? object
    object.text.include?('(')
  end

  def is_millions? unit_string
    !!unit_string.downcase.include?('million')
  end

  def is_thousands? unit_string
    !!unit_string.downcase.include?('thousand')
  end

  # The cell float function runs on the multi column, number only data sets like balance sheet.
  def get_cell_float key_symbol, column_index
    @onclick_terms[key_symbol].each do |title_phrase|
      query='//a[contains(@onclick, "'+ title_phrase + '")]/../../td[contains(@class, "num")]'
      object = get_nokogiri_objects(query)[column_index]
      # p object
      # if the above returns an object then execute the rest of the method
      # next unless object
      if object
        return get_appropriate_sign_integer object, key_symbol
      else
        return nil if title_phrase == @onclick_terms[key_symbol].last
        next
      end
    end
  end

  def get_float_info key_symbol, column_index

    @onclick_terms[key_symbol].each do |title_phrase|
      if column_index == 2 || column_index == 3
        query = '//a[contains(@onclick, "' + title_phrase + '")]/../../td[contains(@class, "num")]'
      else query = '//a[contains(@onclick, "' + title_phrase + '")]/../../td[2]' end
        object = get_nokogiri_objects(query)
        if object then return get_appropriate_sign_integer object, key_symbol
        else return nil end
      end
  end


  def get_appropriate_sign_integer object, key_symbol
    if negative_number? object then -(nokogiri_object_to_float(object, key_symbol))
    else nokogiri_object_to_float object, key_symbol end
  end

  def get_boolean_info key_symbol, column_index
    @onclick_terms[key_symbol].each do |title_phrase|
      query = '//a[contains(@onclick, "' + title_phrase + '")]/../../td[2]'
      object = get_nokogiri_objects(query)
      next unless object
      return nokogiri_object_to_bool object end
  end

  def get_int_info key_symbol, column_index
    @onclick_terms[key_symbol].each do |title_phrase|
      if column_index == 2 || column_index == 3
        query = '//a[contains(@onclick, "' + title_phrase + '")]/../../td[@class ="nump"]'
      else
        query = '//a[contains(@onclick, "' + title_phrase + '")]/../../td[2]'
      end
      object = get_nokogiri_objects(query)[0]
      next unless object
        return nokogiri_object_to_int object
    end
  end

  def nokogiri_object_to_float nokogiri_object, key_symbol
    value = nokogiri_object.text.gsub(/[^\d|.]/, '').to_f
    if @factor && key_symbol != "BASIC_EPS" && key_symbol != "DILUTED_EPS"
      return (value * @factor)
    else
      return value
    end
  end

  def nokogiri_object_to_int nokogiri_object
    return nokogiri_object.text.gsub(/[^\d|.]/, '').to_i
  end

  def nokogiri_object_to_bool nokogiri_object
    truthy = ["true", "yes", "Yes"]
    if truthy.include? nokogiri_object.text.gsub(/\n/, "").strip then return true
    else return false end
  end

  def nokogiri_object_to_date nokogiri_object
    return nokogiri_object.text.gsub(/\-/, " ").strip
  end

  def nokogiri_object_to_text nokogiri_object
    return nokogiri_object.text.gsub(/\n/, "").strip
  end

  def set_unit unit_string
    if unit_string
      @factor = 1000000 if is_millions? unit_string
      @factor = 1000 if is_thousands? unit_string
    else
      puts "no unit_string found:"
      p unit_string
    end
  end

  def get_and_set_unit
    unit_string = get_unit_string
    set_unit unit_string
    unit_string
  end

  def get_unit_string
    query = "//strong"
    get_nokogiri_objects(query)[0].text
  end

  def return_data
    @data
  end
end
