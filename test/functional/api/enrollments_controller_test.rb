require 'test_helper'

class Api::EnrollmentsControllerTest < ActionController::TestCase
#
#	test "should get enrollments with credentials" do
#		set_credentials
#		enrollment = create_enrollment
#		get :index
#		assert_response :success
#		assert assigns(:enrollments)
#		assert assigns(:enrollments).include?(enrollment)
#	end
#
#	test "should not get enrollments with http" do
#		turn_https_off
#		set_credentials
#		get :index
#		assert_response 302
#		assert_response :redirect	#	to https
#	end
#
#	test "should not get enrollments without password" do
#		set_credentials('admin')
#		get :index
#		assert_response 401
#		assert_response :unauthorized
#		#	action_controller/status_codes.rb
#	end
#
#	test "should not get enrollments with bad credentials" do
#		set_credentials('foo','bar')
#		get :index
#		assert_response 401
#		assert_response :unauthorized
#		#	action_controller/status_codes.rb
#	end
#
#	test "should not get enrollments without credentials" do
#		get :index
#		assert_response 401
#		assert_response :unauthorized
#		#	action_controller/status_codes.rb
#	end
#
##	test "should not gem homex enrollment without id" do
##		set_credentials
##		assert_raise(ActionController::RoutingError){
##			get :show
##		}
##	end
##
##	test "should not gem homex enrollment with invalid id" do
##		set_credentials
##		assert_raise(ActiveRecord::RecordNotFound){
##			get :show, :id => 0
##		}
##	end
#
#protected 
#
#	def set_credentials(*args)
#		username, password = if args.empty?
#			username_and_password
#		else
#			[ args[0], args[1] ]
#		end
#		@request.env['HTTP_AUTHORIZATION'
#			] = ActionController::HttpAuthentication::Basic.encode_credentials(
#				username, password)
#	end
#
#	def username_and_password
##		config = YAML::load(ERB.new(IO.read("#{RAILS_ROOT}/config/api.yml")).result)
#		config = YAML::load(ERB.new(IO.read("#{Rails.root}/config/api.yml")).result)
#		[ config[:user], config[:password] ]
#	end
#
end
