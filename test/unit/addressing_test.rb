require 'test_helper'

class AddressingTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_protect(:study_subject_id, :study_subject)

	attributes = %w( address_id current_address address_at_diagnosis
		is_valid why_invalid is_verified how_verified valid_from
		valid_to verified_on verified_by_uid )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )

	assert_should_initially_belong_to( :study_subject, :address, :data_source )
	assert_should_require_attribute_length( :why_invalid, :how_verified, 
			:maximum => 250 )
	assert_should_require_attribute_length( :notes,
			:maximum => 65000 )
	assert_requires_complete_date( :valid_from, :valid_to )

	#	Someone always has to think that they are special!
	assert_should_accept_only_good_values( :current_address,
		{ :good_values => ( YNDK.valid_values ), 
			:bad_values  => 12345 })

	assert_should_accept_only_good_values( :is_valid, :address_at_diagnosis,
		{ :good_values => ( YNDK.valid_values + [nil] ), 
			:bad_values  => 12345 })


	test "addressing factory should create addressing" do
		assert_difference('Addressing.count',1) {
			addressing = Factory(:addressing)
			assert_equal 1, addressing.is_valid
			assert         !addressing.is_verified	
		}
	end

	test "addressing factory should create address" do
		assert_difference('Address.count',1) {
			addressing = Factory(:addressing)
			assert_not_nil addressing.address
		}
	end

	test "addressing factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			addressing = Factory(:addressing)
			assert_not_nil addressing.study_subject
		}
	end

	test "mailing_addressing factory should create addressing" do
		assert_difference('Addressing.count',1) {
			addressing = Factory(:mailing_addressing)
			assert_equal addressing.current_address, YNDK[:no]
		}
	end

	test "mailing_addressing factory should create mailing address" do
		assert_difference('Address.count',1) {
			addressing = Factory(:mailing_addressing)
			assert_equal addressing.address.address_type,
				AddressType['mailing']
		}
	end

	test "mailing_addressing factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			addressing = Factory(:mailing_addressing)
		}
	end

	test "current_mailing_addressing factory should create current addressing" do
		assert_difference('Addressing.count',1) {
			addressing = Factory(:current_mailing_addressing)
			assert_equal addressing.current_address, YNDK[:yes]
		}
	end

	test "current_mailing_addressing factory should create mailing address" do
		assert_difference('Address.count',1) {
			addressing = Factory(:current_mailing_addressing)
			assert_equal addressing.address.address_type,
				AddressType['mailing']
		}
	end

	test "current_mailing_addressing factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			addressing = Factory(:current_mailing_addressing)
		}
	end

	test "residence_addressing factory should create addressing" do
		assert_difference('Addressing.count',1) {
			addressing = Factory(:residence_addressing)
			assert_equal addressing.current_address, YNDK[:no]
		}
	end

	test "residence_addressing factory should create residence address" do
		assert_difference('Address.count',1) {
			addressing = Factory(:residence_addressing)
			assert_equal addressing.address.address_type,
				AddressType['residence']
		}
	end

	test "residence_addressing factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			addressing = Factory(:residence_addressing)
		}
	end

	test "current_residence_addressing factory should create current addressing" do
		assert_difference('Addressing.count',1) {
			addressing = Factory(:current_residence_addressing)
			assert_equal addressing.current_address, YNDK[:yes]
		}
	end

	test "current_residence_addressing factory should create residence address" do
		assert_difference('Address.count',1) {
			addressing = Factory(:current_residence_addressing)
			assert_equal addressing.address.address_type,
				AddressType['residence']
		}
	end

	test "current_residence_addressing factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			addressing = Factory(:current_residence_addressing)
		}
	end

	test "current_address should default to 1" do
		addressing = Addressing.new
		assert_equal 1, addressing.current_address
	end

	test "should require data_source" do
		addressing = Addressing.new( :data_source => nil)
		assert !addressing.valid?
		assert !addressing.errors.include?(:data_source)
		assert  addressing.errors.matching?(:data_source_id,"can't be blank")
	end

	test "should require valid data_source" do
		addressing = Addressing.new( :data_source_id => 0)
		assert !addressing.valid?
		assert !addressing.errors.include?(:data_source_id)
		assert  addressing.errors.matching?(:data_source,"can't be blank")
	end

	test "should require other_data_source if data_source is other" do
		#	The factory will create the associations regardless
		#	so an Address and StudySubject gets created regardless
		addressing = Addressing.new( :data_source => DataSource['Other'] )
		assert !addressing.valid?
		assert addressing.errors.matching?(:other_data_source, "can't be blank")
	end

	test "should NOT require other_data_source if data_source is not other" do
		addressing = Addressing.new( :data_source => DataSource['raf'])
		addressing.valid?
		assert !addressing.errors.matching?(:other_data_source, "can't be blank")
	end

	test "should require a valid address with address_attributes" do
		assert_difference("Address.count", 0 ) {
		assert_difference("Addressing.count", 0 ) {
			addressing = create_addressing(:address_id => nil,
				:address_attributes => {} )
		} }
	end

	[:yes,:nil].each do |yndk|
		test "should NOT require why_invalid if is_valid is #{yndk}" do
			addressing = Addressing.new(:is_valid => YNDK[yndk])
			addressing.valid?
			assert !addressing.errors.include?(:why_invalid)
		end
	end
	[:no,:dk].each do |yndk|
		test "should require why_invalid if is_valid is #{yndk}" do
			addressing = Addressing.new(:is_valid => YNDK[yndk])
			assert !addressing.valid?
			assert addressing.errors.include?(:why_invalid)
		end
	end

	test "should NOT require how_verified if is_verified is false" do
		addressing = Addressing.new(:is_verified => false)
		addressing.valid?
		assert !addressing.errors.include?(:how_verified)
	end
	test "should require how_verified if is_verified is true" do
		addressing = Addressing.new(:is_verified => true)
		assert !addressing.valid?
		assert addressing.errors.include?(:how_verified)
	end

	test "should NOT set verified_on if is_verified NOT changed to true" do
		addressing = create_addressing(:is_verified => false)
		assert_nil addressing.verified_on
	end

	test "should set verified_on if is_verified changed to true" do
		addressing = create_addressing(:is_verified => true,
			:how_verified => "not a clue")
		assert_not_nil addressing.verified_on
	end

	test "should set verified_on to NIL if is_verified changed to false" do
		addressing = create_addressing(:is_verified => true,
			:how_verified => "not a clue")
		assert_not_nil addressing.verified_on
		addressing.update_attributes(:is_verified => false)
		assert_nil addressing.verified_on
	end

	test "should NOT set verified_by_uid if is_verified NOT changed to true" do
		addressing = create_addressing(:is_verified => false)
		assert_nil addressing.verified_by_uid
	end

	test "should set verified_by_uid to 0 if is_verified changed to true" do
		addressing = create_addressing(:is_verified => true,
			:how_verified => "not a clue")
		assert_not_nil addressing.verified_by_uid
		assert_equal addressing.verified_by_uid, ''
	end

	test "should set verified_by_uid to current_user.id if is_verified " <<
		"changed to true if current_user passed" do
		cu = admin_user
		addressing = create_addressing(:is_verified => true,
			:current_user => cu,
			:how_verified => "not a clue")
		assert_not_nil addressing.verified_by_uid
		assert_equal addressing.verified_by_uid, cu.uid
	end

	test "should set verified_by_uid to NIL if is_verified changed to false" do
		addressing = create_addressing(:is_verified => true,
			:how_verified => "not a clue")
		assert_not_nil addressing.verified_by_uid
		addressing.update_attributes(:is_verified => false)
		assert_nil addressing.verified_by_uid
	end

	test "current scope should only return current addressings" do
		create_addressing(:current_address => YNDK[:yes])
		a = create_addressing(:current_address => YNDK[:no])
		create_addressing(:current_address => YNDK[:dk])
		addressings = Addressing.current
		assert_equal 2, addressings.length
		assert !addressings.include?( a )
		addressings.each do |addressing|
			assert [1,999].include?(addressing.current_address)
		end
	end

	test "historic scope should only return historic addressings" do
		create_addressing(:current_address => YNDK[:yes])
		a = create_addressing(:current_address => YNDK[:no])
		create_addressing(:current_address => YNDK[:dk])
		addressings = Addressing.historic
		assert_equal 1, addressings.length
		assert_equal a, addressings.first
		addressings.each do |addressing|
			assert ![1,999].include?(addressing.current_address)
		end
	end

	test "mailing scope should only return mailing addressings" do
		create_addressing
		a = create_mailing_addressing
		create_residence_addressing
		addressings = Addressing.mailing
		assert_equal 1, addressings.length
		assert_equal a, addressings.first
	end

#	test "should make study_subject ineligible "<<
#			"on create if state NOT 'CA' and address is ONLY residence" do
#		study_subject = create_eligible_hx_study_subject
#		assert_difference('OperationalEvent.count',1) {
#		assert_difference('Addressing.count',1) {
#		assert_difference('Address.count',1) {
#			create_az_addressing(study_subject)
#		} } }
#		assert_study_subject_is_not_eligible(study_subject)
#		hxe = study_subject.enrollments.find_by_project_id(Project['HomeExposures'].id)
#		assert_equal   hxe.ineligible_reason,
#			IneligibleReason['newnonCA']
#	end
#
#	test "should make study_subject ineligible "<<
#			"on create if state NOT 'CA' and address is ANOTHER residence" do
#		study_subject = create_eligible_hx_study_subject
#		assert_difference('OperationalEvent.count',1) {
#		assert_difference('Address.count',2) {
#		assert_difference("Addressing.count", 2 ) {
#			ca_addressing = create_ca_addressing(study_subject)
#			az_addressing = create_az_addressing(study_subject)
#		} } }
#		assert_study_subject_is_not_eligible(study_subject)
#		hxe = study_subject.enrollments.find_by_project_id(Project['HomeExposures'].id)
#		assert_equal   hxe.ineligible_reason,
#			IneligibleReason['moved']
#	end
#
#	test "should NOT make study_subject ineligible "<<
#			"on create if OET is missing" do
#		OperationalEventType['ineligible'].destroy
#		study_subject = create_eligible_hx_study_subject
#		assert_difference('OperationalEvent.count',0) {
#		assert_difference('Address.count',1) {
#		assert_difference("Addressing.count", 1 ) {
#			create_ca_addressing(study_subject)
#			assert_raise(ActiveRecord::RecordNotSaved){
#				addressing = create_az_addressing(study_subject)
#		} } } }
#		assert_study_subject_is_eligible(study_subject)
#	end
#
#	test "should NOT make study_subject ineligible "<<
#			"on create if state NOT 'CA' and address is NOT residence" do
#		study_subject = create_eligible_hx_study_subject
#		assert_difference('OperationalEvent.count',0) {
#		assert_difference('Address.count',1) {
#		assert_difference("Addressing.count", 1 ) {
#			addressing = create_az_addressing(study_subject,
#				:address => { :address_type_id => AddressType['mailing'].id })
#		} } }
#		assert_study_subject_is_eligible(study_subject)
#	end
#
#	test "should NOT make study_subject ineligible "<<
#			"on create if state 'CA' and address is residence" do
#		study_subject = create_eligible_hx_study_subject
#		assert_difference('OperationalEvent.count',0) {
#		assert_difference('Address.count',1) {
#		assert_difference("Addressing.count", 1 ) {
#			addressing = create_ca_addressing(study_subject)
#		} } }
#		assert_study_subject_is_eligible(study_subject)
#	end


	#	delegated to the address
	%w( address_type address_type_id
			line_1 line_2 street unit city state zip csz county ).each do |method_name|
		test "should respond to #{method_name}" do
			addressing = Addressing.new
			assert addressing.respond_to?(method_name)
		end
	end


#	'1' and '0' are the default values for a checkbox.
#	I probably should add a condition to this event that
#	the address_type be 'Residence', but I've left that to the view.
#			addressing = Factory(:current_residence_addressing)

	test "should NOT add 'subject_moved' event to subject if subject_moved is '1'" <<
			" if not residence address" do
		addressing = Factory(:current_mailing_addressing)
		assert_difference('OperationalEvent.count',0) {
			addressing.update_attributes(
				:current_address => '2',
				:subject_moved => '1')
		}
	end

	test "should NOT add 'subject_moved' event to subject if subject_moved is '1'" <<
			" if was not current address" do
		addressing = Factory(:residence_addressing)
		assert_difference('OperationalEvent.count',0) {
			addressing.update_attributes(
				:current_address => '2',
				:subject_moved => '1')
		}
	end

	test "should add 'subject_moved' event to subject if subject_moved is '1'" do
		addressing = Factory(:current_residence_addressing)
		assert_difference('OperationalEvent.count',1) {
			addressing.update_attributes(
				:current_address => '2',
				:subject_moved => '1')
		}
	end

	test "should not add 'subject_moved' event to subject if subject_moved is '0'" do
		addressing = Factory(:current_residence_addressing)
		assert_difference('OperationalEvent.count',0) {
			addressing.update_attributes(
				:current_address => '2',
				:subject_moved => '0')
		}
	end

	test "should add 'subject_moved' event to subject if subject_moved is 'true'" do
		addressing = Factory(:current_residence_addressing)
		assert_difference('OperationalEvent.count',1) {
			addressing.update_attributes(
				:current_address => '2',
				:subject_moved => 'true')
		}
	end

	test "should not add 'subject_moved' event to subject if subject_moved is 'false'" do
		addressing = Factory(:current_residence_addressing)
		assert_difference('OperationalEvent.count',0) {
			addressing.update_attributes(
				:current_address => '2',
				:subject_moved => 'false')
		}
	end

	test "should not add 'subject_moved' event to subject if subject_moved is nil" do
		addressing = Factory(:current_residence_addressing)
		assert_difference('OperationalEvent.count',0) {
			addressing.update_attributes(
				:current_address => '2',
				:subject_moved => nil)
		}
	end

protected

	def create_addressing_with_address(study_subject,options={})
		create_addressing({
			:study_subject => study_subject,
#	doesn't work in rcov for some reason
#			:address => nil,	#	block address_attributes
			:address_id => nil,	#	block address_attributes
			:address_attributes => Factory.attributes_for(:address,{
				:address_type_id => AddressType['residence'].id
			}.merge(options[:address]||{}))
		}.merge(options[:addressing]||{}))
	end

	def create_ca_addressing(study_subject,options={})
		create_addressing_with_address(study_subject,{
			:address => {:state => 'CA'}}.merge(options))
	end

	def create_az_addressing(study_subject,options={})
		create_addressing_with_address(study_subject,{
			:address => {:state => 'AZ'}}.merge(options))
	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_addressing

end
