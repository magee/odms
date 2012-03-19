module ActiveSupportExtension; end
module ActiveSupportExtension::TestCase

	def self.included(base)
		base.extend(ClassMethods)
		base.send(:include, InstanceMethods)
		base.alias_method_chain :method_missing, :create_object

#	I can't seem to find out how to confirm that 
#	method_missing_without_create_object
#	doesn't already exist! WTF
#	We don't want to alias it if we already have.
#	tried viewing methods, instance_methods, etc.
#	seems to only work when "inherited" and since 
#	some thing are inherited from subclasses it
#	might get a bit hairy.  No problems now, just
#	trying to avoid them in the future.

		base.class_eval do
#alias_method(:method_missing_without_create_object,:method_missing)
#alias_method(:method_missing,:method_missing_with_create_object)
#			class << self
#				alias_method_chain :method_missing, :create_object #unless
#					respond_to?(:method_missing_without_create_object)
#			end
			class << self
				alias_method_chain( :test, :verbosity ) unless method_defined?(:test_without_verbosity)
			end
		end #unless base.respond_to?(:test_without_verbosity)
#puts base.respond_to?(:method_missing_without_create_object)
#puts base.method_defined?(:method_missing_without_create_object)
#	apparently medding with method_missing is also a bit of an issue
	end

	module ClassMethods

		#	I don't like this quick and dirty name
		def st_model_name
			self.name.demodulize.sub(/Test$/,'')
		end

		def test_with_verbosity(name,&block)
			test_without_verbosity(name,&block)

			test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
			define_method("_#{test_name}_with_verbosity") do
				print "\n#{self.class.name.gsub(/Test$/,'').titleize} #{name}: "
				send("_#{test_name}_without_verbosity")
			end
			#
			#	can't do this.  
			#		alias_method_chain test_name, :verbosity
			#	end up with 2 methods that begin
			#	with 'test_' so they both get run
			#
			alias_method "_#{test_name}_without_verbosity".to_sym,
				test_name
			alias_method test_name,
				"_#{test_name}_with_verbosity".to_sym
		end

		def assert_should_act_as_list(*args)
			options = args.extract_options!
			scope = options[:scope]

			test "#{brand}should act as list" do
				model = create_object.class.name

#	NOTE I don't like this technique
				model.constantize.destroy_all

#	will be problematic with regards to scope
#				current_max = model.constantize.maximum(:position)

				object = create_object
				assert_equal 1, object.position
				attrs = {}
				Array(scope).each do |attr|
					attrs[attr.to_sym] = object.send(attr)
				end if scope
				object = create_object(attrs)
				assert_equal 2, object.position

				# gotta be a relative test as there may already
				# by existing objects (unless I destroy them)
#				assert_difference("#{model}.last.position",1) do
#	TODO another assert difference that seems to cache?
#				assert_difference("#{model}.maximum(:position)",1) do
#puts "JAKE"
#puts model.constantize.all.inspect
#puts model.constantize.maximum(:position)
#					object = create_object(attrs)
#puts object.inspect
#puts model.constantize.all.inspect
#puts model.constantize.maximum(:position)
#puts "JAKE"
#				end

#[#<AddressType id: 63, position: 1, key: "Key58", description: "Desc58", created_at: "2012-03-19 01:40:24", updated_at: "2012-03-19 01:40:24">, #<AddressType id: 64, position: 2, key: "Key59", description: "Desc59", created_at: "2012-03-19 01:40:24", updated_at: "2012-03-19 01:40:24">]
#2
##<AddressType id: 65, position: 2, key: "Key60", description: "Desc60", created_at: "2012-03-19 01:40:25", updated_at: "2012-03-19 01:40:25">
#[#<AddressType id: 63, position: 1, key: "Key58", description: "Desc58", created_at: "2012-03-19 01:40:24", updated_at: "2012-03-19 01:40:24">, #<AddressType id: 64, position: 2, key: "Key59", description: "Desc59", created_at: "2012-03-19 01:40:24", updated_at: "2012-03-19 01:40:24">, #<AddressType id: 65, position: 2, key: "Key60", description: "Desc60", created_at: "2012-03-19 01:40:25", updated_at: "2012-03-19 01:40:25">]
#2

# Still need to get acts_as_list test assert_difference working
pending 
			end

		end

#
#
#	What? No assert_requires_absence method???
#	Its usually conditional so would be pretty pointless
#

		def assert_requires_past_date(*attr_names)
			options = { :allow_today => true }
			options.update(attr_names.extract_options!)

			attr_names.each do |attr_name|
				if options[:allow_today]
					test "#{brand}should allow #{attr_name} to be today" do
						object = create_object( attr_name => Date.today )
						assert !object.errors.matching?(attr_name,
							'is in the future and must be in the past')
					end
				else
					test "#{brand}should NOT allow #{attr_name} to be today" do
						object = create_object( attr_name => Date.today )
						assert object.errors.matching?(attr_name,
							'is in the future and must be in the past')
					end
				end
				test "#{brand}should require #{attr_name} be in the past" do
					#	can't assert difference of 1 as may be other errors
					object = create_object( attr_name => Date.yesterday )
					assert !object.errors.matching?(attr_name,
						'is in the future and must be in the past')
					#	However, can assert difference of 0 as shouldn't create.
					assert_difference( "#{model_name}.count", 0 ) do
						object = create_object( attr_name => Date.tomorrow )


#					puts "JAKE"
#					puts object.errors.inspect
#					puts "JAKE"
#	TODO this fails
						assert object.errors.matching?(attr_name,
							'is in the future and must be in the past')



					end
				end
			end
		end
	
		def assert_requires_complete_date(*attr_names)
			attr_names.each do |attr_name|
				test "#{brand}should require a complete date for #{attr_name}" do
#
#	Cannot assert that one was created as there may be other errors.
#	We can only assert that there isn't a not_complete_date error.
#					assert_difference( "#{model_name}.count", 1 ) do
						object = create_object( attr_name => "Sept 11, 2001")
						assert !object.errors.matching?(attr_name,'is not a complete date')
#					end
#
					assert_difference( "#{model_name}.count", 0 ) do
						object = create_object( attr_name => "Sept 2010")



#					puts "JAKE"
#					puts object.errors.inspect
#					puts "JAKE"
						assert object.errors.matching?(attr_name,'is not a complete date')




					end
					assert_difference( "#{model_name}.count", 0 ) do
						object = create_object( attr_name => "9/2010")
						assert object.errors.matching?(attr_name,'is not a complete date')
					end
				end
			end
		end

	end

	module InstanceMethods

		at_exit { 
			puts Dir.pwd() 
			puts Time.now
		}

		def model_name
#			self.class.name.sub(/Test$/,'')
#			self.class.name.demodulize.sub(/Test$/,'')
			self.class.st_model_name
		end

		def method_missing_with_create_object(symb,*args, &block)
			method = symb.to_s
#			if method =~ /^create_(.+)(\!?)$/
			if method =~ /^create_([^!]+)(!?)$/
				factory = if( $1 == 'object' )
#	doesn't work for controllers yet.  Need to consider
#	singular and plural as well as "tests" method.
#	Probably should just use the explicit factory
#	name in the controller tests.
#				self.class.name.sub(/Test$/,'').underscore
					model_name.underscore
				else
					$1
				end
				bang = $2
				options = args.extract_options!
				if bang.blank?
					record = Factory.build(factory,options)
					record.save
					record
				else
					Factory(factory,options)
				end
			else
#				super(symb,*args, &block)
				method_missing_without_create_object(symb,*args, &block)
			end
		end

		#	basically a copy of assert_difference, but
		#	without any explicit comparison as it is 
		#	simply stating that something will change
		#	(designed for updated_at)
		def assert_changes(expression, message = nil, &block)
			b = block.send(:binding)
			exps = Array.wrap(expression)
			before = exps.map { |e| eval(e, b) }
			yield
			exps.each_with_index do |e, i|
				error = "#{e.inspect} didn't change"
				error = "#{message}.\n#{error}" if message
				assert_not_equal(before[i], eval(e, b), error)
			end
		end

		#	Just a negation of assert_changes
		def deny_changes(expression, message = nil, &block)
			b = block.send(:binding)
			exps = Array.wrap(expression)
			before = exps.map { |e| eval(e, b) }
			yield
			exps.each_with_index do |e, i|
				error = "#{e.inspect} changed"
				error = "#{message}.\n#{error}" if message
				assert_equal(before[i], eval(e, b), error)
			end
		end

	end	#	InstanceMethods
end	#	ActiveSupportExtension::TestCase
ActiveSupport::TestCase.send(:include, ActiveSupportExtension::TestCase)