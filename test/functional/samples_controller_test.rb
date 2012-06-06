require 'test_helper'

class SamplesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Sample',
		:actions => [:edit,:update,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_sample
	}
	def factory_attributes(options={})
		#	Being more explicit to reflect what is actually on the form
		{
			:project_id     => Project['ccls'].id,
			:sample_type_id => Factory(:sample_type).id
		}.merge(options)
	end

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_access_with_login({    :logins => site_readers, 
		:actions => [:show] })
	assert_no_access_with_login({ :logins => non_site_readers, 
		:actions => [:show] })
	assert_no_access_without_login

	#	no study_subject_id
	assert_no_route(:get,:index)

	#	no id
	assert_no_route(:get, :show)
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	site_editors.each do |cu|

		test "should get new sample with #{cu} login" <<
				" and study_subject_id" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert assigns(:sample)
		end

		test "should NOT get new sample with #{cu} login" <<
				" and invalid study_subject_id" do
			login_as send(cu)
			get :new, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should create new sample with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			assert_difference('Sample.count',1) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_nil flash[:error]
			assert_redirected_to sample_path(assigns(:sample))
		end

		test "should NOT create with #{cu} login " <<
				"and invalid study_subject_id" do
			login_as send(cu)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => 0,
					:sample => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT create with #{cu} login " <<
				"and invalid sample" do
			login_as send(cu)
			Sample.any_instance.stubs(:valid?).returns(false)
			study_subject = Factory(:study_subject)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create with #{cu} login " <<
				"and save failure" do
			login_as send(cu)
			Sample.any_instance.stubs(:create_or_update).returns(false)
			study_subject = Factory(:study_subject)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

	end
	
	non_site_editors.each do |cu|

		test "should NOT get new sample with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create new sample with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			post :create, :study_subject_id => study_subject.id,
				:sample => factory_attributes
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end
	
	site_readers.each do |cu|

		test "should get index with #{cu} login and valid study_subject_id" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert assigns(:samples)
			assert_response :success
			assert_template 'index'
		end

		test "should NOT get index with #{cu} login and invalid study_subject_id" do
			login_as send(cu)
			get :index, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end
	
		test "should get dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_response :success
			assert_template 'dashboard'
		end
	
		test "should get find with #{cu} login" do
			login_as send(cu)
			get :find
			assert_response :success
			assert_template 'find'
		end

	##################################################
	#		Begin Find Tests
	
		test "should get samples find with #{cu} login and page too high" do
			3.times{Factory(:sample)}
			login_as send(cu)
			get :find, :page => 999
			assert_not_nil flash[:warn]
			assert_equal 3, assigns(:samples).count
			assert_equal 0, assigns(:samples).length
			assert_redirected_to find_samples_path(:page => 1)
		end

		test "should find samples by sample_id and #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample) }
			login_as send(cu)
#	There is no actual sampleid field. It is just id with leading zeros.
			get :find, :sampleid => samples[1].id
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end

		test "should find samples by parent sample_type and #{cu} login" do
			samples = 3.times.collect{|i| 
				Factory(:sample,:sample_type => SampleType.roots[i].children.first )}
			login_as send(cu)
			get :find, :sample_type_id => samples[1].sample_type.parent.id
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end

		test "should find samples by child sample_type and #{cu} login" do
			samples = 3.times.collect{|i| 
				Factory(:sample,:sample_type => SampleType.not_roots[i] )}
			login_as send(cu)
			get :find, :sample_type_id => samples[1].sample_type_id
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end

#	i starts at 0!

		test "should find samples by first_name and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :first_name => "First#{i}" ) 
			}
			login_as send(cu)
			get :find, :first_name => 'st1'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end

		test "should find samples by last_name and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :last_name => "Last#{i}" )
			}
			login_as send(cu)
			get :find, :last_name => 'st1'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end
	
		test "should find samples by maiden_name and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :maiden_name => "Maiden#{i}" )
			}
			login_as send(cu)
			get :find, :last_name => 'en1'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end

		test "should find samples with childid and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :childid => "12345#{i}" ) }
			login_as send(cu)
			get :find, :childid => '451'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end
	
		test "should find samples with icf_master_id and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :icf_master_id => "345x#{i}" ) }
			login_as send(cu)
			get :find, :icf_master_id => '45x1'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end
	
		test "should find samples with patid and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :patid => "345#{i}" ) }
			login_as send(cu)
			get :find, :patid => '451'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end
	


		test "should find samples with sent_to_subject_at as month day year and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| 
				Factory(:sample,:sent_to_subject_at => base_date + (5*i).days ) }
			login_as send(cu)
			#	Dec 1 2000
			get :find, :sent_to_subject_at => samples[1].sent_to_subject_at.strftime("%b %d %Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with sent_to_subject_at as MM/DD/YYYY and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| 
				Factory(:sample,:sent_to_subject_at => base_date + (5*i).days ) }
			login_as send(cu)
			#	javascript selector format
			get :find, :sent_to_subject_at => samples[1].sent_to_subject_at.strftime("%m/%d/%Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with sent_to_subject_at as YYYY-MM-DD and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| 
				Factory(:sample,:sent_to_subject_at => base_date + (5*i).days ) }
			login_as send(cu)
			#	same as strftime('%Y-%m-%d')
			get :find, :sent_to_subject_at => samples[1].sent_to_subject_at.to_s	
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples ignoring poorly formatted sent_to_subject_at and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| 
				Factory(:sample,:sent_to_subject_at => base_date + (5*i).days ) }
			login_as send(cu)
			get :find, :sent_to_subject_at => 'bad monkey'
			assert_response :success
			assert_equal 3, assigns(:samples).length
		end
	

		test "should find samples with received_by_ccls_at as month day year and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	Dec 1 2000
			get :find, :received_by_ccls_at => samples[1].received_by_ccls_at.strftime("%b %d %Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with received_by_ccls_at as MM/DD/YYYY and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	javascript selector format
			get :find, :received_by_ccls_at => samples[1].received_by_ccls_at.strftime("%m/%d/%Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with received_by_ccls_at as YYYY-MM-DD and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	same as strftime('%Y-%m-%d')
			get :find, :received_by_ccls_at => samples[1].received_by_ccls_at.to_s	
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples ignoring poorly formatted received_by_ccls_at and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			get :find, :received_by_ccls_at => 'bad monkey'
			assert_response :success
			assert_equal 3, assigns(:samples).length
		end
	

#	I could add tons of tests for searching on multiple attributes
#	but it would get ridiculous.  I do need to add a few to test the
#	operator parameter so there will be a few here.	

		test "should find samples by first_name OR last_name and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject(:first_name => "First#{i}",:last_name => "Last#{i}")}
			login_as send(cu)
			get :find, :first_name => 'st1', :last_name => 'st2', :operator => 'OR'
			assert_response :success
			assert_equal 2, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
			assert assigns(:samples).include?(samples[2])
		end

		test "should find samples by first_name AND last_name and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject(:first_name => "First#{i}",:last_name => "Last#{i}")}
			login_as send(cu)
			get :find, :first_name => 'st1', :last_name => 'st1', :operator => 'AND'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end

		test "should find samples by childid OR patid and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject(:patid => "345#{i}", :childid => "12345#{i}" ) }
			login_as send(cu)
			get :find, :patid => '451', :childid => '452', :operator => 'OR'
			assert_response :success
			assert_equal 2, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
			assert assigns(:samples).include?(samples[2])
		end

		test "should find samples by childid AND patid and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject(:patid => "345#{i}", :childid => "12345#{i}" ) }
			login_as send(cu)
			get :find, :patid => '451', :childid => '451', :operator => 'AND'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end

	#		End Find Tests
	##################################################
	

	##################################################
	#		Begin Find Order Tests (only on fields in table)










	
	#		End Find Order Tests
	##################################################

	
		test "should get followup with #{cu} login" do
			login_as send(cu)
			get :followup
			assert_response :success
			assert_template 'followup'
		end
	
		test "should get reports with #{cu} login" do
			login_as send(cu)
			get :reports
			assert_response :success
			assert_template 'reports'
		end
	
		test "should get manifest in csv with #{cu} login" do
			login_as send(cu)
			get :manifest, :format => 'csv'
			assert_response :success
			assert_template 'manifest'

#			assert_not_nil @response.headers['Content-disposition'].match(/attachment;.*csv/)
#			assert_template 'index'
#			assert assigns(:bc_requests)
#			assert !assigns(:bc_requests).empty?
#			assert_equal 1, assigns(:bc_requests).length
#
#			require 'fastercsv'
#			f = FasterCSV.parse(@response.body)
#			assert_equal 2, f.length	#	2 rows, 1 header and 1 data
#			assert_equal f[0], ["masterid", "biomom", "biodad", "date", "mother_full_name", "mother_maiden_name", "father_full_name", "child_full_name", "child_dobm", "child_dobd", "child_doby", "child_gender", "birthplace_country", "birthplace_state", "birthplace_city", "mother_hispanicity", "mother_hispanicity_mex", "mother_race", "other_mother_race", "father_hispanicity", "father_hispanicity_mex", "father_race", "other_father_race"]
#			assert_equal 23, f[0].length
##["46", nil, nil, nil, "[name not available]", nil, "[name not available]", "[name not available]", "3", "23", "2006", "F", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
#			assert_equal f[1][0],  case_study_subject.icf_master_id
#			assert_equal f[1][8],  case_study_subject.dob.try(:month).to_s
#			assert_equal f[1][9],  case_study_subject.dob.try(:day).to_s
#			assert_equal f[1][10], case_study_subject.dob.try(:year).to_s
#			assert_equal f[1][11], case_study_subject.sex
#
##assert f[2].blank?
#
		end
	
	end

	non_site_readers.each do |cu|

		test "should NOT get index with #{cu} login and valid study_subject_id" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end
	
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
	
		test "should NOT get manifest in html with #{cu} login" do
			login_as send(cu)
			get :manifest
			assert_redirected_to root_path
		end
	
		test "should NOT get manifest in csv with #{cu} login" do
			login_as send(cu)
			get :manifest, :format => 'csv'
			assert_redirected_to root_path
		end
	
	end

	test "should NOT get index without login and valid study_subject_id" do
		study_subject = Factory(:study_subject)
		get :index, :study_subject_id => study_subject.id
		assert_redirected_to_login
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
	
	test "should NOT get manifest in html without login" do
		get :manifest
		assert_redirected_to_login
	end
	
	test "should NOT get manifest in csv without login" do
		get :manifest, :format => 'csv'
		assert_redirected_to_login
	end
	
	test "should NOT get new sample without login" do
		study_subject = Factory(:study_subject)
		get :new, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT create new sample without login" do
		study_subject = Factory(:study_subject)
		post :create, :study_subject_id => study_subject.id,
			:sample => factory_attributes
		assert_redirected_to_login
	end

protected 

	def create_sample_with_subject(options={})
		s = Factory(:study_subject, options)
		Factory(:sample, :study_subject => s, :project => Project['ccls'])
	end

end
__END__
