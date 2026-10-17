require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "time zone label uses configured Istanbul zone when runtime zone is UTC" do
    Time.use_zone("UTC") do
      travel_to Time.utc(2026, 1, 15, 9) do
        assert_equal "Türkiye saati (UTC+03:00)", onayflow_time_zone_label
      end
    end
  end

  test "date formatting converts UTC instants to Turkish local time" do
    Time.use_zone("UTC") do
      assert_equal "15.01.2026 12:05", onayflow_datetime(Time.utc(2026, 1, 15, 9, 5))
      assert_equal "15.07.2026 12:05", onayflow_datetime(Time.utc(2026, 7, 15, 9, 5))
    end
  end

  test "due time labels render readable remaining and overdue durations" do
    current_time = Time.zone.local(2026, 10, 17, 12)
    document = ApprovalDocument.new(status: :pending, due_at: current_time + 3.hours)

    assert_equal "3 sa kaldı", due_time_label(document, at: current_time)

    document.due_at = current_time - 2.hours
    assert_equal "2 sa gecikti", due_time_label(document, at: current_time)
  end
end
