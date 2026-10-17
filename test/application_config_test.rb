require "test_helper"

class ApplicationConfigTest < ActiveSupport::TestCase
  test "uses the OnayFlow product name" do
    assert_equal "OnayFlow", Rails.configuration.x.product_name
  end

  test "uses Istanbul application time and UTC database storage" do
    application_zone = Time.find_zone!(Rails.configuration.time_zone)

    assert_equal "Istanbul", application_zone.name
    assert_equal "Europe/Istanbul", application_zone.tzinfo.identifier
    assert_equal "+03:00", application_zone.local(2026, 1, 15, 12).formatted_offset
    assert_equal "+03:00", application_zone.local(2026, 7, 15, 12).formatted_offset
    assert_equal :utc, ActiveRecord.default_timezone
  end
end
