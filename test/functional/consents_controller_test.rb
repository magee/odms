require 'test_helper'

class ConsentsControllerTest < ActionController::TestCase

	#	no study_subject_id
	assert_no_route(:get, :show)
#	assert_no_route(:get,:index)

	#	no id
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	#	no route
	assert_no_route(:get,:new,:study_subject_id => 0)
	assert_no_route(:post,:create,:study_subject_id => 0)

	site_readers.each do |cu|

		test "should get consents with #{cu} login" do
			study_subject = Factory(:enrollment).study_subject
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert_not_nil assigns(:enrollment)
			assert_response :success
			assert_template 'show'
		end

#		test "should get consents for ccls enrolled subject with #{cu} login" do
#	subject is auto enrolled so previous test works just fine
#			study_subject = Factory(:enrollment,
#				:project => Project['ccls'] ).study_subject
#			login_as send(cu)
#			get :show, :study_subject_id => study_subject.id
#			assert assigns(:study_subject)
#			assert assigns(:enrollment)
#			assert_not_nil assigns(:enrollment)
#			assert_response :success
#			assert_template 'show'
#		end

		test "should NOT get consents with invalid study_subject_id " <<
			"and #{cu} login" do
			login_as send(cu)
			get :show, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should get edit consent with #{cu} login" do
pending	#	TODO
		end

		test "should NOT get edit consent with invalid study_subject_id #{cu} login" do
pending	#	TODO
		end

		test "should put update consent with #{cu} login" do
pending	#	TODO
		end

		test "should NOT put update consent with invalid study_subject_id #{cu} login" do
pending	#	TODO
		end

	end

	non_site_readers.each do |cu|

		test "should NOT get consents with #{cu} login" do
			study_subject = Factory(:enrollment).study_subject
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT get edit consent with #{cu} login" do
pending	#	TODO
		end

		test "should NOT put update consent with #{cu} login" do
pending	#	TODO
		end

	end

	test "should NOT get consents without login" do
		study_subject = Factory(:enrollment).study_subject
		get :show, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT get edit consent without login" do
pending	#	TODO
	end

	test "should NOT put update consent without login" do
pending	#	TODO
	end

end
