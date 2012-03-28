require 'test_helper'

class IcfMasterTrackerChangeTest < ActiveSupport::TestCase
#			t.string :icf_master_id
#			t.date :master_tracker_date
#			t.boolean :new_tracker_record
#			t.string :modified_column
#			t.string :previous_value
#			t.string :new_value

	assert_should_create_default_object
	assert_should_require( :icf_master_id )

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_icf_master_tracker_change

#	def create_object(options={})
#		object = Factory.build(:icf_master_tracker_change,options)
#		object.save
#		object
#	end

end
