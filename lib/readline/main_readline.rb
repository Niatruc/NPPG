require_relative 'ext_readline'

# this_dir = ThisDir

module MainReadline
	extend ExtReadline

	# @candidates = []

	@completion_proc = ->(input) {
		case input
		when /^(\/.*)/ # 文件路径补全
			match_str = $1.sub(/\/$/, '')
			escaped_match_str = Regexp.escape(match_str)
			path = ThisDir + match_str

			begin
				# 若path是个完整目录路径，则列出该路径下的文件
				if File.directory?(path)
					Dir.entries(ThisDir + match_str)
						.reject{ |i| ['.', '..'].include?(i) }
						.collect { |f| "#{match_str}/#{f}" }
						.grep(/#{escaped_match_str}/)

				# 若path是个完整文件路径，不用做什么
				elsif File.file?(path)
					[]

				# 若path是个不完整的路径，则列出其所在目录的所有文件的完整路径，供用户选择
				else
					last_valid_path = /.*\//.match(match_str)[0]
					Dir.entries(ThisDir + last_valid_path)
						.reject{ |i| ['.', '..'].include?(i) }
						.collect { |f| last_valid_path + f }
						.grep(/#{escaped_match_str}/)
				end
			rescue Exception => e
				puts e.message  
  				puts e.backtrace
			end

			
		else
			@candidates.grep(/^#{Regexp.escape(input)}/)
		end
	}

	self.completion_proc = @completion_proc
	self.completion_append_character = nil

	# class << self
	# 	def set_commands(candidates)
	# 		@candidates = candidates
	# 	end

	# 	def read(prompt, add_hist)
	# 		readline(prompt, add_hist)
	# 	end
	# end
end