

def test_metric_count
  @client ||= InfluxDB::Rails.client
  reports = @client.query "select test from cool_device"
  report = reports.first
  binding.pry
  if report
    count = report["values"].count
  else
    0
  end
end
