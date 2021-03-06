# This will guess the User class
FactoryBot.define do
  factory :sorn do
    agency_names { '["FAKE AGENCY NAMES"]' }
    action { "FAKE ACTION" }
    summary { "FAKE SUMMARY" }
    system_name { "FAKE SYSTEM NAME" }
    citation { 'citation' }
    publication_date { "2000-01-13"}
    html_url { "HTML URL" }
    xml_url { "xml_url" }
    xml { nil }
    data_source { 'fedreg' }
    agencies { [ association(:agency) ] }
  end
end