require 'test_helper'

class WaiveredsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:model   => 'StudySubject',
		:actions => [:new]
	}

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_no_access_without_login
	assert_access_with_https
	assert_no_access_with_http

	site_editors.each do |cu|

		test "should NOT create waivered case study_subject" <<
				" with existing duplicate hospital_no and #{cu} login" do
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			assert_all_differences(0) do
				post :create, minimum_waivered_form_attributes(
					'study_subject' => { 'patient_attributes' => {
						'organization_id' => ( subject.organization_id + 1 ),
						'hospital_no'     => subject.hospital_no
					} })
			end
			#	these share the same factory which means that the organization_id 
			#	is the same so the hospital_id won't be unique
			assert !assigns(:study_subject).errors.on_attr_and_type(
				"patient.hospital_no",:taken)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create waivered case study_subject" <<
				" with existing duplicate hospital_no" <<
				" and #{cu} login if 'Match Found' without duplicate_id" do
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			assert_all_differences(0) do
				post :create, minimum_waivered_form_attributes(
					'study_subject' => { 'patient_attributes' => {
						'organization_id' => ( subject.organization_id + 1 ),
						'hospital_no'     => subject.hospital_no
					} }, :commit => 'Match Found')
			end
			#	these share the same factory which means that the organization_id 
			#	is the same so the hospital_id won't be unique
			assert !assigns(:study_subject).errors.on_attr_and_type(
				"patient.hospital_no",:taken)
			assert_not_nil flash[:error]
			assert_not_nil flash[:warn]
			assert_match /No valid duplicate_id given/, flash[:warn]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create waivered case study_subject" <<
				" with existing duplicate hospital_no" <<
				" and #{cu} login if 'Match Found' with invalid duplicate_id" do
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			assert_all_differences(0) do
				post :create, minimum_waivered_form_attributes(
					'study_subject' => { 'patient_attributes' => {
						'organization_id' => ( subject.organization_id + 1 ),
						'hospital_no'     => subject.hospital_no
					} }, :commit => 'Match Found', :duplicate_id => 0 )
			end
			#	these share the same factory which means that the organization_id 
			#	is the same so the hospital_id won't be unique
			assert !assigns(:study_subject).errors.on_attr_and_type(
				"patient.hospital_no",:taken)
			assert_not_nil flash[:error]
			assert_not_nil flash[:warn]
			assert_match /No valid duplicate_id given/, flash[:warn]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create waivered case study_subject" <<
				" with existing duplicate hospital_no" <<
				" and #{cu} login if 'Match Found' with valid duplicate_id" do
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			assert_difference('OperationalEvent.count',1) {
			assert_all_differences(0) {
				post :create, minimum_waivered_form_attributes(
					'study_subject' => { 'patient_attributes' => {
						'organization_id' => ( subject.organization_id + 1 ),
						'hospital_no'     => subject.hospital_no
					} }, :commit => 'Match Found', :duplicate_id => subject.id )
			} }
			#	these share the same factory which means that the organization_id 
			#	is the same so the hospital_id won't be unique
			assert !assigns(:study_subject).errors.on_attr_and_type(
				"patient.hospital_no",:taken)
			assert_not_nil flash[:notice]
			assert_redirected_to subject
		end

		test "should create waivered case study_subject" <<
				" with existing duplicate hospital_no" <<
				" and #{cu} login if 'No Match'" do
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			minimum_successful_creation(
					'study_subject' => { 'patient_attributes' => {
						'organization_id' => ( subject.organization_id + 1 ),
						'hospital_no'     => subject.hospital_no
					} }, :commit => 'No Match')
			#	these share the same factory which means that the organization_id 
			#	is the same so the hospital_id won't be unique
			assert !assigns(:study_subject).errors.on_attr_and_type(
				"patient.hospital_no",:taken)
		end

		test "should NOT create waivered case study_subject" <<
				" with existing duplicate admit_date and organization_id and #{cu} login" do
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			assert_all_differences(0) do
				post :create, minimum_waivered_form_attributes(
					'study_subject' => { 'patient_attributes' => {
							'admit_date'      => subject.admit_date,
							'organization_id' => subject.organization_id
					} })
			end
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create waivered case study_subject" <<
				" with existing duplicate admit_date and organization_id" <<
				" and #{cu} login if 'Match Found' without duplicate_id" do
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			assert_all_differences(0) do
				post :create, minimum_waivered_form_attributes(
					'study_subject' => { 'patient_attributes' => {
							'admit_date'      => subject.admit_date,
							'organization_id' => subject.organization_id
					} }, :commit => 'Match Found' )
			end
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_not_nil flash[:warn]
			assert_match /No valid duplicate_id given/, flash[:warn]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create waivered case study_subject" <<
				" with existing duplicate admit_date and organization_id" <<
				" and #{cu} login if 'Match Found' with invalid duplicate_id" do
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			assert_all_differences(0) do
				post :create, minimum_waivered_form_attributes(
					'study_subject' => { 'patient_attributes' => {
							'admit_date'      => subject.admit_date,
							'organization_id' => subject.organization_id
					} }, :commit => 'Match Found', :duplicate_id => 0 )
			end
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_not_nil flash[:warn]
			assert_match /No valid duplicate_id given/, flash[:warn]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create waivered case study_subject" <<
				" with existing duplicate admit_date and organization_id" <<
				" and #{cu} login if 'Match Found' with valid duplicate_id" do
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			assert_difference('OperationalEvent.count',1) {
			assert_all_differences(0) {
				post :create, minimum_waivered_form_attributes(
					'study_subject' => { 'patient_attributes' => {
							'admit_date'      => subject.admit_date,
							'organization_id' => subject.organization_id
					} }, :commit => 'Match Found', :duplicate_id => subject.id )
			} }
			assert assigns(:study_subject)
			assert_not_nil flash[:notice]
			assert_redirected_to subject
		end

		test "should create waivered case study_subject" <<
				" with existing duplicate admit_date and organization_id" <<
				" and #{cu} login if 'No Match'" do
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			minimum_successful_creation(
					'study_subject' => { 'patient_attributes' => {
							'admit_date'      => subject.admit_date,
							'organization_id' => subject.organization_id
					} }, :commit => 'No Match' )
		end

#On the Possible Duplicates Found screen, display a list of subjects who…
#	•	All subjects:  Have the same birth date (piis.dob) and sex (subject.sex) as the new subject and (same mother’s maiden name or existing mother’s maiden name is null), or

		test "should NOT create waivered case study_subject" <<
				" with existing duplicate sex and dob and #{cu} login" do
pending	#	TODO still need to add mother's maiden name to comparison
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			assert_all_differences(0) do
				post :create, minimum_waivered_form_attributes(
					'study_subject' => { 'sex' => subject.sex,
						'pii_attributes' => { 'dob' => subject.dob }
					})
			end
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create waivered case study_subject" <<
				" with existing duplicate sex and dob" <<
				" and #{cu} login if 'Match Found' without duplicate_id" do
pending	#	TODO still need to add mother's maiden name to comparison
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			assert_all_differences(0) do
				post :create, minimum_waivered_form_attributes(
					'study_subject' => { 'sex' => subject.sex,
						'pii_attributes' => { 'dob' => subject.dob }
					}, :commit => 'Match Found' )
			end
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_not_nil flash[:warn]
			assert_match /No valid duplicate_id given/, flash[:warn]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create waivered case study_subject" <<
				" with existing duplicate sex and dob" <<
				" and #{cu} login if 'Match Found' with invalid duplicate_id" do
pending	#	TODO still need to add mother's maiden name to comparison
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			assert_all_differences(0) do
				post :create, minimum_waivered_form_attributes(
					'study_subject' => { 'sex' => subject.sex,
						'pii_attributes' => { 'dob' => subject.dob }
					}, :commit => 'Match Found', :duplicate_id => 0 )
			end
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_not_nil flash[:warn]
			assert_match /No valid duplicate_id given/, flash[:warn]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create waivered case study_subject" <<
				" with existing duplicate sex and dob" <<
				" and #{cu} login if 'Match Found' with valid duplicate_id" do
pending	#	TODO still need to add mother's maiden name to comparison
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			assert_difference('OperationalEvent.count',1) {
			assert_all_differences(0) {
				post :create, minimum_waivered_form_attributes(
					'study_subject' => { 'sex' => subject.sex,
						'pii_attributes' => { 'dob' => subject.dob }
					}, :commit => 'Match Found', :duplicate_id => subject.id )
			} }
			assert assigns(:study_subject)
			assert_not_nil flash[:notice]
			assert_redirected_to subject
		end

		test "should create waivered case study_subject" <<
				" with existing duplicate sex and dob" <<
				" and #{cu} login if 'No Match'" do
pending	#	TODO still need to add mother's maiden name to comparison
			subject = Factory(:complete_case_study_subject).reload
			login_as send(cu)
			minimum_successful_creation(
					'study_subject' => { 'sex' => subject.sex,
						'pii_attributes' => { 'dob' => subject.dob }
					}, :commit => 'No Match' )
		end








		test "should create waivered case study_subject enrolled in ccls" <<
				" with #{cu} login" do
			login_as send(cu)
			minimum_successful_creation
			assert_equal [Project['ccls']],
				assigns(:study_subject).enrollments.collect(&:project)
		end

		test "should create waivered case study_subject" <<
				" with minimum requirements and #{cu} login" do
			login_as send(cu)
			minimum_successful_creation
		end

		test "should create waivered case study_subject" <<
				" with complete attributes and #{cu} login" do
			login_as send(cu)
			full_successful_creation
			assert_equal 'C', assigns(:study_subject).identifier.case_control_type
			assert_equal '0', assigns(:study_subject).identifier.orderno.to_s
		end

		test "should create waivered case study_subject" <<
				" with waivered attributes and #{cu} login" do
			login_as send(cu)
			waivered_successful_creation
			assert_equal 'C', assigns(:study_subject).identifier.case_control_type
			assert_equal '0', assigns(:study_subject).identifier.orderno.to_s
		end

		test "should create mother on create with #{cu} login" do
			login_as send(cu)
			minimum_successful_creation
			assert_not_nil assigns(:study_subject).mother
		end

		test "should not assign icf_master_id to mother if none exist on create" <<
				" with #{cu} login" do
			login_as send(cu)
			minimum_successful_creation
			assert_nil assigns(:study_subject).mother.identifier.icf_master_id
			assert_not_nil flash[:warn]
		end

		test "should not assign icf_master_id to mother if one exist on create" <<
				" with #{cu} login" do
			login_as send(cu)
			Factory(:icf_master_id,:icf_master_id => '123456789')
			minimum_successful_creation
			assert_nil assigns(:study_subject).mother.identifier.icf_master_id
			assert_not_nil flash[:warn]
		end

		test "should assign icf_master_id to mother if two exist on create" <<
				" with #{cu} login" do
			login_as send(cu)
			Factory(:icf_master_id,:icf_master_id => '123456780')
			Factory(:icf_master_id,:icf_master_id => '123456781')
			minimum_successful_creation
			assert_not_nil assigns(:study_subject).identifier.icf_master_id
			assert_equal '123456780', assigns(:study_subject).identifier.icf_master_id
			assert_not_nil assigns(:study_subject).mother.identifier.icf_master_id
			assert_equal '123456781', assigns(:study_subject).mother.identifier.icf_master_id
		end

		test "should not assign icf_master_id if none exist on create" <<
				" with #{cu} login" do
			login_as send(cu)
			minimum_successful_creation
			assert_nil assigns(:study_subject).identifier.icf_master_id
			assert_not_nil flash[:warn]
		end

		test "should assign icf_master_id if any exist on create with #{cu} login" do
			login_as send(cu)
			Factory(:icf_master_id,:icf_master_id => '123456789')
			minimum_successful_creation
			assert_not_nil assigns(:study_subject).identifier.icf_master_id
			assert_equal '123456789', assigns(:study_subject).identifier.icf_master_id
			#	only one icf_master_id so mother will raise warning
			assert_not_nil flash[:warn]	
		end

		test "should NOT create waivered case study_subject" <<
				" with invalid study_subject and #{cu} login" do
			login_as send(cu)
			StudySubject.any_instance.stubs(:valid?).returns(false)
			assert_all_differences(0) do
				post :create, complete_case_study_subject_attributes
			end
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create waivered case study_subject when save fails" <<
				" with #{cu} login" do
			login_as send(cu)
			StudySubject.any_instance.stubs(:create_or_update).returns(false)
			assert_all_differences(0) do
				post :create, complete_case_study_subject_attributes
			end
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

#		test "should rollback when assign_icf_master_id raises error with #{cu} login" do
#pending	#	TODO
#		end
#
#		test "should rollback when create_mother raises error with #{cu} login" do
#pending	#	TODO
#		end

		test "should do something if patid exists with #{cu} login" do
			Identifier.any_instance.stubs(:get_next_patid).returns('0123')
			identifier1 = Factory(:case_identifier)
			assert_not_nil identifier1.patid
			login_as send(cu)
			assert_all_differences(0) do
				post :create, complete_case_study_subject_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should do something if childid exists with #{cu} login" do
			Identifier.any_instance.stubs(:get_next_childid).returns(12345)
			identifier1 = Factory(:identifier)
			assert_not_nil identifier1.childid
			login_as send(cu)
			assert_all_differences(0) do
				post :create, complete_case_study_subject_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should do something if subjectid exists with #{cu} login" do
			Identifier.any_instance.stubs(:generate_subjectid).returns('012345')
			identifier1 = Factory(:identifier)
			assert_not_nil identifier1.subjectid
			login_as send(cu)
			assert_all_differences(0) do
				post :create, complete_case_study_subject_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

	end

	non_site_editors.each do |cu|

		test "should NOT create waivered case study_subject with #{cu} login" do
			login_as send(cu)
			assert_all_differences(0) do
				post :create, complete_case_study_subject_attributes
			end
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT create waivered case study_subject without login" do
		assert_all_differences(0) do
			post :create, complete_case_study_subject_attributes
		end
		assert_redirected_to_login
	end

protected

	def minimum_waivered_form_attributes(options={})
		{ 'study_subject' => {
			"sex"                   => "M", 
			"pii_attributes"        => Factory.attributes_for(:pii),
			"identifier_attributes" => { },
			"patient_attributes"    => Factory.attributes_for(:patient)
		} }.deep_merge(options)
	end

	def waivered_form_attributes(options={})
		{ 'study_subject' => {
			"subject_languages_attributes"=>{
				"0"=>{"language_id"=>"1"}, 
				"1"=>{"language_id"=>""}, 
				"2"=>{"language_id"=>"", "other"=>""}
			}, 
			"sex"=>"M", 
			"identifier_attributes"=>{ }, 
			"pii_attributes"=> Factory.attributes_for(:pii, {
				"first_name"=>"", 
				"middle_name"=>"", 
				"last_name"=>"", 
				"mother_first_name"=>"", 
				"mother_middle_name"=>"", 
				"mother_last_name"=>"", 
				"mother_maiden_name"=>"", 
				"father_first_name"=>"", 
				"father_middle_name"=>"", 
				"father_last_name"=>"", 
				"guardian_relationship_id"=>"", 
				"guardian_relationship_other"=>"", 
				"guardian_first_name"=>"",
				"guardian_middle_name"=>"", 
				"guardian_last_name"=>""
			}), 
			"addressings_attributes"=>{
				"0"=>{
					"address_attributes"=> Factory.attributes_for(:address)
				}
			},
			"phone_numbers_attributes"=>{
				"0"=>{"phone_number"=>"1234567890"},
				"1"=>{"phone_number"=>""}
			}, 
			"enrollments_attributes"=>{
#	consented does not have a default value, so can send nothing if one button not checked
#	TODO add consented field
				"0"=>{
					"other_refusal_reason"=>"", 
					"consented_on"=>"", 
					"document_version_id"=>"", 
					"refusal_reason_id"=>""
				}
			}, 
			"patient_attributes"=> Factory.attributes_for(:patient,{
				"raf_zip" => '12345',
				"raf_county" => "some county, usa",
				"was_previously_treated"=>"false", 
				"admitting_oncologist"=>"", 
				"was_under_15_at_dx"=>"true", 
#				"diagnosis_id"=>"", 
				"was_ca_resident_at_diagnosis"=>"true"
			})
		}}.deep_merge(options)
	end

	def minimum_successful_creation(options={})
		assert_difference('Enrollment.count',2){	#	subject AND mother
		assert_difference('Pii.count',2){
		assert_difference('Patient.count',1){
		assert_difference('Identifier.count',2){
		assert_difference('StudySubject.count',2){
			post :create, minimum_waivered_form_attributes(options)
		} } } } }
		assert_nil flash[:error]
		assert_redirected_to assigns(:study_subject)
	end

	def full_successful_creation(options={})
		assert_difference('StudySubject.count',2){
#		assert_difference('SubjectRace.count',count){
		assert_difference('SubjectLanguage.count',1){
		assert_difference('Identifier.count',2){
		assert_difference('Patient.count',1){
		assert_difference('Pii.count',2){
		assert_difference('Enrollment.count',2){	#	subject AND mother
		assert_difference('PhoneNumber.count',1){
		assert_difference('Addressing.count',1){
		assert_difference('Address.count',1){
			post :create, complete_case_study_subject_attributes(options)
		} } } } } } } } } #}
		assert_nil flash[:error]
		assert_redirected_to assigns(:study_subject)
	end

	def waivered_successful_creation(options={})
		assert_difference('StudySubject.count',2){
#		assert_difference('SubjectRace.count',count){
		assert_difference('SubjectLanguage.count',1){
		assert_difference('Identifier.count',2){
		assert_difference('Patient.count',1){
		assert_difference('Pii.count',2){
		assert_difference('Enrollment.count',2){	#	subject AND mother
		assert_difference('PhoneNumber.count',1){
		assert_difference('Addressing.count',1){
		assert_difference('Address.count',1){
			post :create, waivered_form_attributes(options)
		} } } } } } } } } #}
		assert_nil flash[:error]
		assert_redirected_to assigns(:study_subject)
	end

end
