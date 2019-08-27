# InvestSmart

<img width="1440" alt="screen shot 2017-03-13 at 20 22 16" src="https://cloud.githubusercontent.com/assets/22742327/23873791/31fa64c6-082b-11e7-9bef-fae38c3db62d.png">


## Overview

InvestSmart makes investing in stocks & shares easier. It was created as my final project during my 12-week Web Development Immersive course at General Assembly in London. We were given the choice to work individually or as a team - I decided to work with three classmates. InvestSmart was built using a Ruby on Rails back-end, a SQL database, and AngularJS front-end.

Update August 2019: Link to (unmaintained) project removed due to multiple breaking API changes

## The idea

The core functionality of InvestSmart was an idea I have wanted to make for a long time - to automate the building and updating of financial models. This process is currently labour-intensive, often taking a trained analyst (my previous profession) a day or more each time. These models are only available to institutional investors (investment/pension/hedge funds). InvestSmart could provide automated financial models to retail investors, who lack the time and skillset to build them.

The idea involves scraping US company financials, parsing them into a consistent format and storing them in our database. We also decided to implement other features that would allow the average investor to track their investments - including the ability to add stocks to a watchlist, news / press release RSS feeds, stock price charts, and valuation multiples versus industry peers.

## The build

- Back-end: Ruby on Rails
- Front-end: AngularJS
- CSS framework: Skeleton
- Database: PostgreSQL
- Angular modules:
	- Simple HTTP requests: ngResource
	- Authentication: angular-jwt
	- Charts: chart.js
	- Autocomplete functionality: angucomplete-alt
- Ruby gems:
	- Parsing: nokogiri
	- HTTP requests: httparty
- External APIs:
	- Yahoo Finance

## The process

### 1. Financial Models

#### i) Scoping out the data

Before doing anything else, we had to work out whether it would be possible to get the data. I knew we would get the data from annual reports on the SEC (securities & exchange commission) website. We narrowed this down to four tables of the tables shown on [this link](https://www.sec.gov/cgi-bin/viewer?action=view&cik=320193&accession_number=0001628280-16-020309&xbrl_type=v#). A look at the JavaScript source file showed us that each table had its [own link](https://www.sec.gov/Archives/edgar/data/320193/000162828016020309/R2.htm), that looked like this: https://www.sec.gov/Archives/edgar/data/320193/000162828016020309/R2.htm.

The link contained three parts that we would need - identification codes for both the company and the report in question, and an R number referring to the table in question. We found the required codes contained in an [SEC webpage](http://www.sec.gov/Archives/edgar/data/320193/000162828016020309/0001628280-16-020309-index.htm) for each company and each report. We could work out the R number later.

Next, we inspected the HTML source file to work out where we would pull the data from. We worked out that rather than pulling data based upon the name of each line item in each table, we would pull it based upon the SEC's reference for each line, located within an onclick function for each table row. There was much less discrepancy in these references compared to the names given. For example, the four companies gave three different names for tax paid in the income statement, whereas the SEC reference was "defref_us-gaap_IncomeTaxExpenseBenefit" for all four.

With this, we had the beginnings of a plan in place - we knew how to access the right data, and we knew how to parse it. I started by manually entering all of the SEC references for four companies, lining them up and creating the first draft of the fields for our model.

#### ii) Scraping and saving the data

We decided to save the relevant tables for each company in order to avoid hitting the SEC website too frequently. To do this, we created methods that did the following:

- Retrieve the identification code and report codes for the specified company tickers from the aforementioned link
- Retrieve the R numbers for the required tables (income statement, balance sheet, cash flow), based upon the inclusion and exclusion of certain keywords in the heading of each, which had several different connotations
- Create a folder for each company, containing a folder for each of the last 5 years (where available)
- Save the relevant xml files for each table into files with standardised filenames

This allowed us to save the relevant files for an initial subset of 30 large US companies.

#### iii) Parsing the data

Parsing the data was by far the hardest part of the project. We created one parent class, and one class for each of the four tables that we needed to scrape. The classes did the following:

- Strip ticker, year and accession id for each of the file paths and directories
- Create new company hash including ticker, sector and description - the latter two scraped from Yahoo Finance. If the company exists in the DB already, assign it to the company variable
- Create new filing hash including year and accession id
- Open each file, work out the table type from the file name and run the correct parse method
- Dependent on table type, set the correct onclick terms from the YML file and pass these terms along with the file to the correct class method
- Open file & parse with Nokogiri
- Strip the date divs from the top of the table. Convert to string by removing newlines and blank space, and strip the year from the end
- Get the period end date from table heading
- For each date, create yearly results hash using the fields specified in each table's individual class. As part of this, fix all inconsistencies - e.g. positive vs. negative numbers, non-digit characters, units etc
- Save each of these to the database

One of the tables (document and entity information) was quite different to the other three, hence has several of its own specific methods

#### iv) Saving the data to the database

We used a PostgreSQL database, with our model set up as shown below:

![](https://cloud.githubusercontent.com/assets/22742327/23875227/98727a04-0830-11e7-9aed-ee61721e8cff.png)
### 2. User dashboard

We implemented a watchlist, which users can add stocks to. These stocks then populate the two RSS feeds - one for company news from yahoo, and one for the latest company filings (filings are information straight from the company).

Users can also click on the 'chart' button in the watchlist to populate the stock price chart with a specific company's data, which defaults to the US market (S&P 500) otherwise. We used *chart.js* to build the chart, and sourced the data from the Yahoo Finance API.

Finally, our user dashboard contains an FX matrix of key currencies, with corresponding daily moves. The data for this is again sourced from Yahoo Finance.

### 3. Company page

To get to the company page, a user can either click on a stock in their watchlist, or use the search box in the top-right of our navigation bar. We used *angucomplete-alt* to add autocomplete functionality to the search.

On this page, we provide a company summary, largely populated from our own database, with only the market cap coming from a separate API request.

We also include a valuation multiples versus peers table. To do this, we send the company name to the back-end, find all companies in the same sector, and send back a combination of historical earnings per share (from our database) and future earnings estimates (from a scrape of Yahoo). On the front-end, we look up the most recent stock price and include that along with PE multiples (stock price / earnings per share).  

The page also includes a news feed and stock price chart, similar to the user dashboard.

## Key challenges / learnings

I learned a huge amount during this project, largely technical:

- Ruby on Rails: we were relatively new to Ruby on Rails, having only spent the last 2 weeks of the 12 week course learning about it - the previous 10 weeks were focused on JavaScript. We avoided scaffolding, which I believe helped my learning
- Scraping/parsing: I had not done any real scraping before, nor learned about it on the course. By the end of the project, I felt comfortable with it
- Relational databases: after using NoSQL databases for our previous projects, trying to think in SQL terms initially felt like a foreign concept. After much discussion and scrawling on white-boards, it eventually clicked
- Charts & RSS feeds: again, not something I had much experience with, but cool things to know how to do for the future

It was also great experience to work in a team for the second time. I believe we worked very well together.

## Future work

While there is a huge amount of potential further work on all aspects of our app, I believe the real value add is in the financial model builder, simply because it does not exist (to a high standard) yet. Therefore this is where we plan to focus our efforts.

First, we have a decision to make on how best to structure each financial model. This decision is a trade-off between customisation and scalability. The most scalable approach would be to present the financial models exactly how each company reports. The most custom approach would be to work out how best to present the models on a company by company basis. Our application currently leans more to the latter, providing a model that better fits the company but limiting the companies covered and making it less efficient to scale to more companies. I believe the right approach will fall in between the two.

Once we have made this decision, our first task will be to cover more companies. Ideally, we would like to cover the 500 companies in the S&P 500 index. Then, there are several other improvements we can introduce:

- Include quarterly financials, in addition to annual financials
- Automatic checking and updating for companies that have reported
- Deal with company restatements of prior year financials
- Build a stock screen, which would allow investors to search for companies that meet certain financial criteria
- Build an Excel plug-in. Investors will want the models in excel, not the browser
- Look into scraping other parts of the annual reports
