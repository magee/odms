require 'test_helper'

class SampleOutcomeTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_have_many( :homex_outcomes )
	assert_should_not_require_attributes( :position )

	test "sample_outcome factory should create sample outcome" do
		assert_difference('SampleOutcome.count',1) {
			sample_outcome = Factory(:sample_outcome)
			assert_match /Key\d*/,  sample_outcome.key
			assert_match /Desc\d*/, sample_outcome.description
		}
	end

	test "should return description as to_s" do
		sample_outcome = SampleOutcome.new(:description => "testing")
		assert_equal sample_outcome.description, 'testing'
		assert_equal sample_outcome.description, "#{sample_outcome}"
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_sample_outcome

end
