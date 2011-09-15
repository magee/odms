require 'test_helper'

class InterviewsControllerTest < ActionController::TestCase

	site_readers.each do |cu|

		test "should get dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_response :success
		end
	
		test "should get find with #{cu} login" do
			login_as send(cu)
			get :find
			assert_response :success
		end
	
		test "should get followup with #{cu} login" do
			login_as send(cu)
			get :followup
			assert_response :success
		end
	
		test "should get reports with #{cu} login" do
			login_as send(cu)
			get :reports
			assert_response :success
		end
	
	end

	non_site_readers.each do |cu|

		test "should NOT get dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_redirected_to root_path
		end
	
		test "should NOT get find with #{cu} login" do
			login_as send(cu)
			get :find
			assert_redirected_to root_path
		end
	
		test "should NOT get followup with #{cu} login" do
			login_as send(cu)
			get :followup
			assert_redirected_to root_path
		end
	
		test "should NOT get reports with #{cu} login" do
			login_as send(cu)
			get :reports
			assert_redirected_to root_path
		end
	
	end

	test "should NOT get dashboard without login" do
		get :dashboard
		assert_redirected_to_login
	end

	test "should NOT get find without login" do
		get :find
		assert_redirected_to_login
	end

	test "should NOT get followup without login" do
		get :followup
		assert_redirected_to_login
	end

	test "should NOT get reports without login" do
		get :reports
		assert_redirected_to_login
	end

end