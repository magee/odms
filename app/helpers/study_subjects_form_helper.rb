module StudySubjectsFormHelper

	#	May be able to implement this simplicity for the races as well
	#	Simplicity?  This has gotten rather complicated.
	def subject_languages_select( languages )
		#		self.object  #	<-- the subject
		sl_params = @template.params.dig('study_subject','subject_languages_attributes')||{}

		#	"0"=>{"language_id"=>"1"}.to_a 
		#	=> [0,{"language_id"=>"1"}] 
		#	hence l[1] 
		#	=> {"language_id"=>"1"}
		#	and l[1]['language_id']
		#	=> "1"
		#	As working with params, treat these all as strings.
		selected_language_ids = sl_params.collect{ |l| l[1]['language_id'] }

		s =  "<div id='study_subject_languages'>"
		#	TODO would be nice, but not currently needed, to have a label option.
		s << "<div class='languages_label'>Language of parent or caretaker:</div>\n"
		s << "<div id='languages'>\n"
		languages.each do |l|
			sl = self.object.subject_languages.detect{|sl|sl.language_id == l.id } ||
				self.object.subject_languages.build(:language => l)
			classes = ['subject_language']
			classes << ( ( sl.id.nil? ) ? 'creator' : 'destroyer' )
			s << "<div class='#{classes.join(' ')}'>"
			self.fields_for( :subject_languages, sl ) do |sl_fields|
				s << "<div id='other_language'>" if( l.is_other? )

#	I would rather not be picking from the params, but for the moment it seems the only way.
#	I'd prefer to base it on the existing object, saved or unsaved, but don't know how to do that.
#	Perhaps once this is working, I can change it up, but I don't foresee that.

				if sl.id.nil?	#	not currently existing subject_language
					s << sl_fields.subject_language_creator(selected_language_ids.include?(sl.language_id.to_s))
				else	#	language exists, this is for possible destruction
#	sl_params ...
# {"0"=>{"id"=>"1", "language_id"=>"1", "_destroy"=>"0"}, "1"=>{"language_id"=>""}, "2"=>{"language_id"=>"", "other"=>""}}

					attrs = sl_params.detect{|p| p[1]['language_id'] == sl.language_id.to_s }
#					["0", {"id"=>"1", "language_id"=>"1", "_destroy"=>"1"}]

					#	only uncheck the checkbox if it was unchecked.
					language_checked = ( !attrs.nil? and attrs[1].has_key?('_destroy') ) ?
						( attrs[1]['_destroy'] == '0' ) : true
					
					s << sl_fields.subject_language_destroyer(language_checked)
				end
				s << sl_fields.specify_other_language() if l.is_other?
				s << "</div>"	if( l.is_other? ) # id='other_language'>" 
			end
			s << "</div>\n"	# class='subject_language'>"
		end
		s << "</div>\n"	#	languages
		s << "</div><!-- study_subject_languages -->\n"	#	study_subject_languages
	end
	alias_method :subject_languages_selector, :subject_languages_select

	def subject_races_select
	end
	alias_method :subject_races_selector, :subject_races_select

protected

	def race_label
	end

	def subject_race_creator
	end

	def subject_race_destroyer
	end

	def language_label
		label =  self.object.language.key.dup.capitalize
		label << (( self.object.language.is_other? ) ? ' (not eligible)' : ' (eligible)')
	end

	def subject_language_creator(checked=false)
		#	self.object is a subject_language
		#	If exists, the hidden id tag is actually immediately put in the html stream!
		#	Don't think that it will be a problem, but erks me.
		s = self.check_box( :language_id, { :checked => checked }, self.object.language_id, '' ) << "\n"
		s << self.label( :language_id, self.language_label ) << "\n"
	end

	def subject_language_destroyer(checked=true)
		#	self.object is a subject_language
		#	KEEP ME for finding _destroy to determine if checked
		s =  self.hidden_field( :language_id, :value => self.object.language_id )
		#	check_box(object_name, method, options = {}, 
		#		checked_value = "1", unchecked_value = "0")
		#	when checked, I want it to do nothing (0), when unchecked I want destroy (1)
		#	Here, I only want existing language_ids
		#	Yes, this is very backwards.
		s << self.check_box( :_destroy, { :checked => checked }, 0, 1 ) << "\n"
		s << self.label( :_destroy, self.language_label ) << "\n"
	end

	def specify_other_language
		s =  "<div id='specify_other_language'>"
		s << self.label( :other, 'specify:' ) << "\n"
		s << self.text_field( :other, :size => 12 ) << "\n"
		s << "</div>"	# id='other_language'>"
	end

end
ActionView::Helpers::FormBuilder.send(:include, StudySubjectsFormHelper)