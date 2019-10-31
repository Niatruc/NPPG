require_relative 'ext_readline'

module NewProcessReadline
	extend ExtReadline
	
	# @candidates = []

	@completion_proc = ->(input) {
		@candidates.grep(/#{Regexp.escape(input)}/)
	}

	self.completion_proc = @completion_proc
	self.completion_append_character = nil
end