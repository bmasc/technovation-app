require "rails_helper"

class SeedsTest < Minitest::Test
  def setup
    Rails.application.load_tasks

    capture_stdout do
      Rake.application["db:seed"].invoke
    end
  end

  def test_seed_adds_region
    assert Region.count == 1
    assert Region.last.name == "US/Canada"
  end

  def test_seed_adds_season
    assert Season.count == 1
    assert Season.current.year == Time.current.year
  end

  def test_seed_adds_score_category
    assert ScoreCategory.count == 1
    assert ScoreCategory.last.name == "Ideation"
  end

  def test_seed_adds_score_attribute
    assert ScoreAttribute.count == 1
    assert ScoreCategory.last.score_attributes.last.label ==(
      "Did the team identify a real problem in their community?"
    )
  end

  def test_seed_adds_score_value
    assert ScoreValue.count == 1
    assert ScoreCategory.last.score_attributes.last
                        .score_values.last.label == "No"
    assert ScoreCategory.last.score_attributes.last
                        .score_values.last.value.zero?
  end

  private
  def capture_stdout
    s = StringIO.new
    oldstdout = $stdout
    $stdout = s
    yield
    s.string
  ensure
    $stdout = oldstdout
  end
end
