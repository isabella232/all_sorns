class SornXmlParser
  # Uses an XML streamer. Each method re-streams the file. Fast enough and uses no memory.

  def initialize(xml)
    @parser = Saxerator.parser(xml)# {|config| config.ignore_namespaces!}
    @sections = get_sections
  end

  def parse_sorn
    {
      # agency: get_agency,
      # subagency: get_subagency,
      action: get_action,
      summary: get_summary,
      dates: get_dates,
      addresses: get_addresses,
      further_info: get_further_information,
      supplementary_info: get_supplementary_information,
      system_name: get_system_name,
      system_number: get_system_number,
      security: get_security,
      location: get_location,
      manager: get_manager,
      authority: get_authority,
      purpose: get_purpose,
      categories_of_individuals: get_individuals,
      categories_of_record: get_categories_of_record,
      source: get_source,
      routine_uses: get_routine_uses,
      storage: get_storage,
      retrieval: get_retrieval,
      retention: get_retention,
      safeguards: get_safeguards,
      access: get_access,
      contesting: get_contesting,
      notification: get_notification,
      exemptions: get_exemptions,
      history: get_history,
      # headers: @sections.keys
    }
  end

  def get_agency
    find_tag('AGENCY')
  end

  def get_action
    find_tag('ACT')
  end

  def get_summary
    find_tag('SUM')
  end

  def get_dates
    find_tag('DATES')
  end

  def get_addresses
    find_tag('ADD')
  end

  def get_further_information
    find_tag('FURINF')
  end

  def get_supplementary_information
    # custom to get everything but priact and sig
    # an example of why paragraphs only won't work
    # https://www.federalregister.gov/documents/full_text/xml/2020/10/13/2020-22534.xml
    content = []
    @parser.within('SUPLINF').each do |node|
      if node.name != 'PRIACT' && node.name != 'SIG'
        # skip section title
        if node.name == 'HD' && node.include?('SUPPLEMENTARY')
          next
        else
          content << node
        end
      end
    end
    content
  end

  def get_system_name
    find_section('SYSTEM NAME')
  end

  def get_system_number
    find_section('NUMBER')
  end

  def get_security
    find_section('SECURITY')
  end

  def get_location
    find_section('LOCATION')
  end

  def get_manager
    find_section('MANAGER')
  end

  def get_authority
    find_section('AUTHORITY FOR MAINTENANCE OF THE SYSTEM')
  end

  def get_purpose
    find_section('PURPOSE')
  end

  def get_individuals
    find_section('INDIVIDUALS')
  end

  def get_categories_of_record
    find_section('CATEGORIES OF RECORDS')
  end

  def get_source
    find_section('SOURCE')
  end

  def get_routine_uses
    find_section('ROUTINE')
  end

  def get_storage
    find_section('STORAGE')
  end

  def get_retrieval
    find_section('RETRIEVAL') #Retrievability
  end

  def get_retention
    find_section('RETENTION')
  end

  def get_safeguards
    find_section('SAFEGUARDS')
  end

  def get_access
    find_section('ACCESS')
  end

  def get_contesting
    find_section('CONTESTING')
  end

  def get_notification
    find_section('NOTIFICATION')
  end

  def get_exemptions
    find_section('EXEMPTIONS')
  end

  def get_history
    find_section('HISTORY')
  end

  private

  def find_tag(tag)
    # Return the whole element if its a string or array
    # Most of the AGENCY tags are single strings
    # Rarely another tag will be complicated and have more than paragraphs, these show up as arrays.
    # Just return the whole array as a string
    element = @parser.for_tag(tag).first

    # Most commonly, it is a hash with paragraphs
    element.fetch('P', nil) if element.class == Saxerator::Builder::HashElement
  end

  def get_sections
    sections = {}
    current_node = nil
    @parser.within('PRIACT').each do |node|
      if node.name == 'HD'
        if node.class == Saxerator::Builder::ArrayElement
          node.delete({})
          node = node.first
        end
        current_node = node
        sections[current_node] = []
      else
        sections[current_node] << node if current_node
      end
    end

    sections
  end

  def find_section(header)
    matched_header = @sections.keys.select do |key|
      begin
        if key.class == Saxerator::Builder::HashElement
          key = key.flatten.join(" ")
        end
        key.upcase.include? header
      rescue => e
        puts 'ERROR: ' + e.to_s
      end
    end.first
    @sections[matched_header]
  end
end
