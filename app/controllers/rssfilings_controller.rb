require 'open-uri'
require 'date'

class RssfilingsController < ApplicationController

  def filing_feed
    tickers = params["_json"]
    filingFeeds = []
    tickers.each_with_index do |ticker, tickerIndex|
      # NEED TO LOOK UP CIK IN DATABASE
      # Company.find_by ticker: 'AAPL'

      company = Company.find_by({ticker: ticker})
      cik = company.filings.last.dei_statement.entity_central_index_key
      url = "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=#{cik}&type=&dateb=&owner=exclude&start=0&count=10&output=atom"
      # response = HTTParty.get(url)
      # data = response.parsed_response
      doc = open(url)
      parsed = Nokogiri::XML(doc)

      titles = parsed.css("entry title")
      titles.each_with_index do |title, index|
          filingFeeds << {
            title: title.text,
            ticker: ticker,
            cik: cik,
            link: parsed.css("entry filing-href")[index].text,
            date: Date.parse(parsed.css("entry updated")[index].text).strftime("%d/%m/%Y")
          }
      end
      # links = parsed.css("entry filing-href")
      # links.each_with_index do |link, index|
      #     objectArray[index]['link'] = link.text
      # end
      # dates = parsed.css("entry updated")
      # dates.each_with_index do |date, index|
      #     objectArray[index]['date'] = date.text
      # end

    end
    sortedFilingFeeds = (filingFeeds.sort_by { |k| k[:date] }).reverse
    render json:  { filingItems: sortedFilingFeeds }    # needs
  end
end
