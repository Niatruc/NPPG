require 'readline'

module ExtReadline
	# CRuby跟JRuby不兼容，没法extend Readline后使用completion_proc=
	# include Readline

	attr_accessor :candidates

	# readline库的一个bug： tab时会用最近使用的completion_proc。 所以每次用新的自定义Readline模块时重新给completion_proc赋值。
	def reset_readline_completion
		self.completion_proc = @completion_proc
		self.completion_append_character = nil
	end

	def read(prompt, add_hist)
		Readline.readline(prompt, add_hist)
	end

	def completion_proc=(proc)
		Readline.completion_proc = proc
	end

	def completion_append_character=(c)
		Readline.completion_append_character = c
	end

	# self.completer_word_break_characters = " "
end