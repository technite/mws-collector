gem 'peddler', '= 0.15.0'

require 'active_support/all'
require 'peddler'
require 'logger'
require 'yaml'
require 'date'

config = YAML.load_file( '/opt/scripts/amazon/config/mws.yml' )
config['production']

client_orders = MWS.orders(config['production'])
client_reports = MWS.reports(config['production'])

logger = Logger.new "/var/log/collector/amazon_reports.log"
logger.progname = 'amazon_get_report'

report_request_list = client_reports.get_report_request_list(:requested_from_date=>0.day.ago.midnight, :report_processing_status_list=>"_DONE_").parse
if report_request_list.count<2
	msg = "No report available"
	logger.error msg
else
	report_request_list["ReportRequestInfo"].each do |x|
		@requestid 	= x["ReportRequestId"]
		@reporttype 	= x["ReportType"]
		@startdate	= x["StartDate"]
		@enddate	= x["EndDate"]
		@reportid	= x["GeneratedReportId"]
#		puts " #@reporttype :  #@requestid : #@reportid : #@startdate : #@enddate "
		if DateTime.parse(@startdate) == 1.day.ago.midnight && DateTime.parse(@enddate) <= 1.day.ago.end_of_day
		#	puts " #@reporttype :  #@requestid : #@reportid : #@startdate : #@enddate "
			report=client_reports.get_report(@reportid).parse
		end
	end 
#	puts $report_id
#	msg = "Report Exists",@requestid,@reportid,@reporttype,@startdate,@enddate
#	logger.info msg
#	puts @requestid
end

