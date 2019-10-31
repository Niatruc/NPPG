require 'readline'

module ExtReadline
	include Readline

	attr_accessor :candidates

	# readline库的一个bug： tab时会用最近使用的completion_proc。 所以每次用新的自定义Readline模块时重新给completion_proc赋值。
	def reset_readline_completion_proc
		self.completion_proc = @completion_proc
	end

	def read(prompt, add_hist)
		readline(prompt, add_hist)
	end

	# self.completer_word_break_characters = " "
end