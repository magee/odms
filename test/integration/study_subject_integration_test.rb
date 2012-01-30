require 'integration_test_helper'

class StudySubjectIntegrationTest < ActionController::CapybaraIntegrationTest

	site_editors.each do |cu|

		test "should preserve creation of subject_race on edit kickback with #{cu} login" do
			assert_difference( 'SubjectRace.count', 0 ){
				@study_subject = Factory(:study_subject)
			}
			login_as send(cu)
			page.visit edit_study_subject_path(@study_subject.id)
			assert_equal current_path, edit_study_subject_path(@study_subject.id)
			assert page.has_unchecked_field?(
				"study_subject[subject_races_attributes][0][race_id]")	#	white
			#	trigger a kickback from StudySubject update failure
			StudySubject.any_instance.stubs(:valid?).returns(false)
			click_button 'Save'
			assert page.has_css?("p.flash#error")
			assert_equal current_path, study_subject_path(@study_subject.id) #	still a kickback
			assert page.has_unchecked_field?(
				"study_subject[subject_races_attributes][0][race_id]")	#	white
		end

		test "should preserve destruction of subject_race on edit kickback with #{cu} login" do
			assert_difference( 'SubjectRace.count', 1 ){
				@study_subject = Factory(:study_subject, :subject_races_attributes => { 
					'0' => { :race_id => Race['white'].id }})
			}
			login_as send(cu)
			page.visit edit_study_subject_path(@study_subject.id)
			assert_equal current_path, edit_study_subject_path(@study_subject.id)
			assert page.has_checked_field?(
				"study_subject[subject_races_attributes][0][_destroy]")	#	white
			#	trigger a kickback from StudySubject update failure
			StudySubject.any_instance.stubs(:valid?).returns(false)
			click_button 'Save'
			assert page.has_css?("p.flash#error")
			assert page.has_checked_field?(
				"study_subject[subject_races_attributes][0][_destroy]")	#	white
		end

		test "should check race_id when is_primary is checked with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			page.visit edit_study_subject_path(study_subject)
			assert page.has_unchecked_field?(
				"study_subject[subject_races_attributes][1][race_id]")
			page.check "study_subject[subject_races_attributes][1][is_primary]"
			assert page.has_checked_field?(
				"study_subject[subject_races_attributes][1][race_id]")
		end

		test "should uncheck other is_primary's when is_primary is checked" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			page.visit edit_study_subject_path(study_subject)
			page.check "study_subject[subject_races_attributes][1][is_primary]"
			assert page.has_checked_field?(
				"study_subject[subject_races_attributes][1][is_primary]")
			page.check "study_subject[subject_races_attributes][2][is_primary]"
			assert page.has_checked_field?(
				"study_subject[subject_races_attributes][2][is_primary]")
			assert page.has_unchecked_field?(
				"study_subject[subject_races_attributes][1][is_primary]")
		end

		test "should uncheck is_primary when race_id is unchecked" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			page.visit edit_study_subject_path(study_subject)
			page.check "study_subject[subject_races_attributes][1][is_primary]"
			assert page.has_checked_field?(
				"study_subject[subject_races_attributes][1][race_id]")
			assert page.has_checked_field?(
				"study_subject[subject_races_attributes][1][is_primary]")
			page.uncheck "study_subject[subject_races_attributes][1][race_id]"
			assert page.has_unchecked_field?(
				"study_subject[subject_races_attributes][1][race_id]")
			assert page.has_unchecked_field?(
				"study_subject[subject_races_attributes][1][is_primary]")
		end

		test "should toggle specify other race when other race_id is checked" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			page.visit edit_study_subject_path(study_subject)
			assert page.has_css?("#specify_other_race",:visible => false)

			page.check "other_race_id"
			assert page.has_checked_field?("other_race_id")
			assert page.has_unchecked_field?("other_is_primary")
			assert page.has_css?("#specify_other_race",:visible => true)

			page.uncheck "other_race_id"
			assert page.has_unchecked_field?("other_race_id")
			assert page.has_unchecked_field?("other_is_primary")
			assert page.has_css?("#specify_other_race",:visible => false)

			page.check "other_is_primary"
			assert page.has_checked_field?("other_race_id")
			assert page.has_checked_field?("other_is_primary")
			assert page.has_css?("#specify_other_race",:visible => true)

			page.uncheck "other_is_primary"
			assert page.has_checked_field?("other_race_id")
			assert page.has_unchecked_field?("other_is_primary")
			assert page.has_css?("#specify_other_race",:visible => true)
		end

	end

end