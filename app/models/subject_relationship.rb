class SubjectRelationship < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	#	Returns description
	def to_s
		description
	end

	#	Returns boolean of comparison
	#	true only if key == 'other'
	def is_other?
		key == 'other'
	end

end
