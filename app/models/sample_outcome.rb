# don't know exactly
class SampleOutcome < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	has_many :homex_outcomes

	#	Returns description
	def to_s
		description
	end

end
