class FindSornsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Makes queries to the Federal Register API to find SORNs.
    # Searching for 'Privacy Act of 1974; System of Records' of type 'Notice' is the best query we have found.
    # In the results we still filter on those with a title that includes 'Privacy Act of 1974'.


    conditions = { term: 'Privacy Act of 1974; System of Records' }#, agencies: ['general-services-administration'] }
    # 'general-services-administration', 'justice-department', 'defense-department']
    fields = ['type', 'publication_date', 'title', 'full_text_xml_url', 'html_url', 'citation', 'agency_names', 'action' ]
    # unfortunately the ruby gem doesn't have the year filter implemented, only specific dates.
    # we should probably switch to use the http api
    search_options = {
      conditions: conditions,
      type: 'NOTICE', # doesn't seem to work
      fields: fields,
      order: 'newest', #oldest
      per_page: 200,
      page: 1
    }

    search_fed_reg(search_options)
  end

  def search_fed_reg(search_options)
    puts 'Asking for SORNs'
    result_set = FederalRegister::Document.search(search_options)


    result_set.results.each do |result|
      next unless result.type == 'Notice'
      next unless result.title.include? 'Privacy Act of 1974'

      params = {
        action: result.action,
        xml_url: result.full_text_xml_url,
        html_url: result.html_url,
        citation: result.citation,
        agency_names: result.agency_names,
        publication_date: result.publication_date,
        title: result.title,
        text_url: result.raw_text_url,
        dates: result.dates,
        data_source: :fedreg
      }
      sorn = Sorn.create!(params)
      puts "Sorn #{sorn.id} created"

      ParseSornXmlJob.perform_later(sorn.id) if sorn.xml_url
    end

    # Keep making more requests until there are no more.
    search_options[:page] = search_options[:page] + 1
    if search_options[:page] <= result_set.total_pages
      search_fed_reg(search_options)
    end
  end

  private

  def a_sorn_title?(title)
    includes_privacy_act = title.include?('Privacy Act of 1974')
    # excludes_unwanted_titles = ['matching', 'rulemaking', 'implementation'].all? do |excluded_title|
    #   title.downcase.exclude? excluded_title
    # end
    includes_privacy_act #&& excludes_unwanted_titles
  end
end
