require_relative 'ext_readline'

module NewProcessReadline
	extend ExtReadline

	
	@candidates = %w{quit show-options show-configs set desc config run}

	@completion_proc = ->(input) {
		current_line = Readline.line_buffer
		r = /#{Regexp.escape(input)}/

		case current_line
		when /^(set|desc)\s+/
			@vars.grep(r)
		else
			@candidates.grep(r)
		end
	}

	class << self
		attr_accessor :vars

		def reset_readline_completion
			super
			self.completion_append_character = " "
		end
	end
end