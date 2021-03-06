class ChartsController < ApplicationController
	def phase_5_case_enrollment_by_month
		dates = 15.times.collect{|i| Date.today - i.months }.reverse
#		this_month = Date.today.month
#
#	may want to index dates using "trie"
#
#	using month-year label in case want more than a year
#
		phase5 = StudySubject.search{
			with(:subject_type, 'Case')
			with(:phase, '5') 
			facet(:reference_date) {
				dates.each { |date|
					row("#{date.month}-#{date.year}"){ with(:reference_date).between([
						date.beginning_of_month, date.end_of_month]) } } } 
		}	#	by month over the past 12 months
		p = Project['ccls']
		consenting = StudySubject.search{
			facet(:reference_date) {
				dates.each { |date|
					row("#{date.month}-#{date.year}"){ with(:reference_date).between([
						date.beginning_of_month, date.end_of_month]) } } } 
			with(:subject_type, 'Case')
			with(:phase, '5')
			dynamic("hex_#{p.to_s.unpack('H*').first}"){
				with(:consented,"Yes")
				with(:is_eligible,"Yes") } }
		refused = StudySubject.search{
			facet(:reference_date) {
				dates.each { |date|
					row("#{date.month}-#{date.year}"){ with(:reference_date).between([
						date.beginning_of_month, date.end_of_month]) } } } 
			with(:subject_type, 'Case')
			with(:phase, '5')
			dynamic("hex_#{p.to_s.unpack('H*').first}"){
				with(:consented,"No")
				with(:is_eligible,"Yes") } }
		ineligible = StudySubject.search{
			facet(:reference_date) {
				dates.each { |date|
					row("#{date.month}-#{date.year}"){ with(:reference_date).between([
						date.beginning_of_month, date.end_of_month]) } } } 
			with(:subject_type, 'Case')
			with(:phase, '5')
			dynamic("hex_#{p.to_s.unpack('H*').first}"){
				with(:is_eligible,"No") } }

		@total_counts = dates.collect{|date|
			phase5.facet(:reference_date).rows.detect{|row|
				row.value == "#{date.month}-#{date.year}" }.try(:count)||0}
		@consenting_counts = dates.collect{|date|
			consenting.facet(:reference_date).rows.detect{|row|
				row.value == "#{date.month}-#{date.year}" }.try(:count)||0}
		@refused_counts = dates.collect{|date|
			refused.facet(:reference_date).rows.detect{|row|
				row.value == "#{date.month}-#{date.year}" }.try(:count)||0}
		@ineligible_counts = dates.collect{|date|
			ineligible.facet(:reference_date).rows.detect{|row|
				row.value == "#{date.month}-#{date.year}" }.try(:count)||0}



		@labels = dates.collect{|d| d.strftime('%b%y') }
		@max_y = @total_counts.max
	end
	def phase_5_case_enrollment
#		study_subjects = StudySubject.cases
#			.joins( :enrollments )
#			.where( :phase => 5 )
#			.where( 'enrollments.project_id = ?',Project['ccls'].id)
#			.group( 'enrollments.is_eligible, enrollments.consented' )
#			.select('enrollments.is_eligible as is_eligible, enrollments.consented as consented, count(*) as count')
#		@counts = [ study_subjects.collect(&:count).sum,
#			study_subjects.select{|s|
#			(s.is_eligible == 1) && (s.consented == 1)}.collect(&:count).sum,
#			0,0 ]
#		@max_y = study_subjects.collect(&:count).sum

		phase5 = StudySubject.search{
			with(:subject_type, 'Case')
			with(:phase, '5') }
		p = Project['ccls']
		consenting = StudySubject.search{
			with(:subject_type, 'Case')
			with(:phase, '5')
			dynamic("hex_#{p.to_s.unpack('H*').first}"){
				with(:consented,"Yes")
				with(:is_eligible,"Yes") } }
		refused = StudySubject.search{
			with(:subject_type, 'Case')
			with(:phase, '5')
			dynamic("hex_#{p.to_s.unpack('H*').first}"){
				with(:consented,"No")
				with(:is_eligible,"Yes") } }
		ineligible = StudySubject.search{
			with(:subject_type, 'Case')
			with(:phase, '5')
			dynamic("hex_#{p.to_s.unpack('H*').first}"){
				with(:is_eligible,"No") } }
		@counts = [ phase5.total, consenting.total,
			refused.total,ineligible.total ]
		@max_y = phase5.total
	end

	def case_enrollment
#		#	the study_subjects.id is NEEDED to get the organization_id afterwards?
#		study_subjects = StudySubject.cases
#			.joins( :patient => :organization )
#			.joins( :enrollments )
#			.where( 'enrollments.project_id = ?',Project['ccls'].id)
#			.group( 'patients.organization_id, enrollments.is_eligible, enrollments.consented' )
#			.select('study_subjects.id, patients.organization_id, enrollments.is_eligible as is_eligible, enrollments.consented as consented, count(*) as count')
#			.order( 'organizations.key ASC' )
#
#		@orgs = study_subjects.collect(&:organization).uniq
#		#	non-nil needed, at least for testing
#		@max_y = @orgs.collect{|o| 
#			study_subjects.select{|i|
#				i.organization_id == o.id}.collect(&:count).sum}.max || 0 
#		@total_counts = @orgs.collect{|o| 
#			study_subjects.select{|i|
#				i.organization_id == o.id}.collect(&:count).sum}
#		@eligible_counts = @orgs.collect{|o| 
#			study_subjects.select{|i|
#				i.organization_id == o.id && i.is_eligible == 1}.collect(&:count).sum}
#		@consenting_counts =  @orgs.collect{|o| 
#			study_subjects.select{|i|
#				i.organization_id == o.id && i.is_eligible == 1 && i.consented == 1}.collect(&:count).sum}

		all = StudySubject.search{
			facet :hospital_key
			order_by :hospital_key, :asc }	#	not needed as array is sorted?
		p = Project['ccls']
		eligible = StudySubject.search{
			facet :hospital_key
			dynamic("hex_#{p.to_s.unpack('H*').first}"){
				with(:is_eligible,"Yes") } }
#			order_by :hospital_key, :asc }	#	not needed as array is sorted?
		consenting = StudySubject.search{
			facet :hospital_key
			dynamic("hex_#{p.to_s.unpack('H*').first}"){
				with(:consented,"Yes")
				with(:is_eligible,"Yes") } }
#			order_by :hospital_key, :asc }	#	not needed as array is sorted?

		@all_hospital_keys = all.facet(:hospital_key).rows.collect(&:value).sort.uniq
		#	non-nil needed, at least for testing
		@total_counts = @all_hospital_keys.collect{|hospital|
			all.facet(:hospital_key).rows.detect{|row|
				row.value == hospital }.try(:count)||0}
		@eligible_counts = @all_hospital_keys.collect{|hospital|
			eligible.facet(:hospital_key).rows.detect{|row|
				row.value == hospital }.try(:count)||0}
		@consenting_counts = @all_hospital_keys.collect{|hospital|
			consenting.facet(:hospital_key).rows.detect{|row|
				row.value == hospital }.try(:count)||0}
		@max_y = @total_counts.max || 0
	end

	def blood_bone_marrow
		#	the study_subjects.id is NEEDED to get the organization_id afterwards?
#		@study_subjects = StudySubject.cases	#.where( :phase => 5 )
#			.joins( :patient => :organization )
#			.joins( :samples => :sample_type )
#			.group( 'patients.organization_id, sample_types.key' )
#			.select('study_subjects.id, patients.organization_id, sample_types.key as type_key, sample_types.description as type_text, count(*) as count')
#			.order( 'organizations.key ASC' )
##			.having("type_key IN ('marrowdiag','periph')")
# orgs = @study_subjects.collect(&:organization).uniq
# max = orgs.collect{|o| @study_subjects.select{|i|i.organization_id == o.id}.collect(&:c    ount).sum}.max || 0 %><%# non-nil needed for testing %>
#	<%#=orgs.collect{|o|"\"#{o.key}\""}.join(',').html_safe%
#<%#= orgs.collect{|o| @study_subjects.select{|i|i.organization_id == o    .id && i.type_key == 'marrowdiag' }.collect(&:count).sum}.join(',')%>
#	<%#= orgs.collect{|o| @study_subjects.select{|i|i.organization_id == o    .id && i.type_key == 'periph' }.collect(&:count).sum}.join(',')%>

		#	Would be nice to do this in just 1 query
		#	but don't think if I can.
		marrow = StudySubject.search{
			facet :hospital_key
			order_by :hospital_key, :asc	#	not needed as array is sorted?
			with(:sample_types,"bone marrow - diagnostic")}
		blood = StudySubject.search{
			facet :hospital_key
			order_by :hospital_key, :asc	#	not needed as array is sorted?
			with(:sample_types,"peripheral blood - diagnostic")}

		@all_hospital_keys = [blood,marrow].collect{|b| 
			b.facet(:hospital_key) }.collect(&:rows).flatten.collect(&:value).sort.uniq
		#	non-nil needed, at least for testing
		@max_y = [blood,marrow].collect{|b| 
			b.facet(:hospital_key) }.collect(&:rows).flatten.collect(&:count).max || 0
		@marrow_counts = @all_hospital_keys.collect{|hospital| 
			marrow.facet(:hospital_key).rows.detect{|row|
				row.value == hospital }.try(:count)||0}
		@blood_counts  = @all_hospital_keys.collect{|hospital| 
			blood.facet(:hospital_key).rows.detect{|row|
				row.value == hospital }.try(:count)||0}
#	expecting only one so using detect, and in case none exist, try(:count)||0
	end



	def subject_types_by_phase
		@study_subjects = StudySubject
			.joins(:subject_type)
			.group('phase, subject_type_id')
			.select('phase, subject_type_id, count(*) as count, subject_types.*')
	end
	def vital_statuses_by_phase
		@study_subjects = StudySubject
			.joins(:vital_status)
			.group('phase, vital_status_id')
			.select('phase, vital_status_id, count(*) as count, vital_statuses.*')
	end





	def enrollments
		@enrollments = Enrollment
			.select('project_id, count(*) as count')
			.group('project_id')
	end
	def vital_statuses
		@study_subjects = StudySubject
			.joins(:vital_status)
			.group('vital_status_id')
			.where(:phase => 5)
			.select('vital_status_id, count(*) as count, vital_statuses.*')

		@vital_statuses = @study_subjects.collect{|s| s.vital_status }
		@max_y = @study_subjects.collect{|s|s.count.to_i}.max
	end
	def vital_statuses_pie
		@study_subjects = StudySubject
			.joins(:vital_status)
			.group('vital_status_id')
			.select('vital_status_id, count(*) as count, vital_statuses.*')
	end
	def subject_types
		@study_subjects = StudySubject
			.joins(:subject_type)
			.group('subject_type_id')
			.where(:phase => 5)
			.select('subject_type_id, count(*) as count, subject_types.*')
		@subject_types = @study_subjects.collect{|s| s.subject_type }
		@max_y = @study_subjects.collect{|s|s.count.to_i}.max
	end
	def subject_types_pie
		@study_subjects = StudySubject
			.joins(:subject_type)
			.group('subject_type_id')
			.select('subject_type_id, count(*) as count, subject_types.*')
	end
	def case_control_types
		@study_subjects = StudySubject
			.select('case_control_type, count(*) as count')
			.group('case_control_type')
	end
	def case_control_types_pie
		@study_subjects = StudySubject
			.select('case_control_type, count(*) as count')
			.group('case_control_type')
	end
	def childidwho
		@study_subjects = StudySubject
			.select('childidwho, count(*) as count')
			.group('childidwho')
	end
	def is_eligible
		@enrollments = Enrollment
			.select('is_eligible, count(*) as count')
			.group('is_eligible')
	end
	def consented
		@enrollments = Enrollment
			.select('consented, count(*) as count')
			.group('consented')
	end

	def samples_sample_types
		@samples = Sample
			.joins(:sample_type)
			.group('sample_type_id')
			.select('sample_type_id, count(*) as count, sample_types.*')
	end
	def samples_sample_temperatures
		@samples = Sample
			.joins(:sample_temperature)
			.group('sample_temperature_id')
			.select('sample_temperature_id, count(*) as count, sample_temperatures.*')
	end
	def samples_locations
		@samples = Sample
			.joins(:organization)
			.group('location_id')
			.select('location_id, count(*) as count, organizations.*')
	end
	def samples_projects
		@samples = Sample
			.joins(:project)
			.group('project_id')
			.select('project_id, count(*) as count, projects.*')
	end

end
__END__
