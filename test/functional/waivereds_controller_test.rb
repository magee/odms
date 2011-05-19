require 'test_helper'

class WaiveredsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:model   => 'Subject',
		:actions => [:new, :create],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_subject
	}
	def factory_attributes(options={})
		Factory.attributes_for(:subject,{
			:subject_type_id => SubjectType['Case'].id,
			:race_ids => [Race.random.id]}.merge(options))
	end

	assert_access_with_login({
		:logins => site_editors })

	assert_no_access_with_login({
		:logins => non_site_editors })

	assert_no_access_without_login

	assert_access_with_https
	assert_no_access_with_http


	site_editors.each do |cu|

		test "should create waivered case subject with #{cu} login" do
			login_as send(cu)
			assert_difference('Subject.count',1){
			assert_difference('SubjectRace.count',1){
				post :create, :subject => factory_attributes
			} }
			assert_nil flash[:error]
			assert_redirected_to assigns(:subject)
		end

		test "should NOT create waivered case subject with invalid subject and #{cu} login" do
			login_as send(cu)
			Subject.any_instance.stubs(:valid?).returns(false)
			assert_difference('Subject.count',0){
			assert_difference('SubjectRace.count',0){
				post :create, :subject => factory_attributes
			} }
			assert assigns(:subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create waivered case subject when save fails with #{cu} login" do
			login_as send(cu)
			Subject.any_instance.stubs(:create_or_update).returns(false)
			assert_difference('Subject.count',0){
			assert_difference('SubjectRace.count',0){
				post :create, :subject => factory_attributes
			} }
			assert assigns(:subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

	end

	non_site_editors.each do |cu|

		test "should NOT create waivered case subject with #{cu} login" do
			login_as send(cu)
			assert_difference('Subject.count',0){
			assert_difference('SubjectRace.count',0){
				post :create, :subject => factory_attributes
			} }
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT create waivered case subject without login" do
		assert_difference('Subject.count',0){
		assert_difference('SubjectRace.count',0){
			post :create, :subject => factory_attributes
		} }
		assert_redirected_to_login
	end

end