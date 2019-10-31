require_relative '../lib/support/kernel.rb'
require_relative '../lib/readline/repl_readline.rb'

exp=nil
mark = "[ruby]>> "
ReplReadline.candidates = %w{ml ok}
ReplReadline.reset_readline_completion_proc

while (exp = ReplReadline.read(mark, true)) != "ok" #输入ok时退出repl
	begin
		if exp == "ml" #多行输入
			line_num = 1
			str = ""
			while (exp = ReplReadline.read("#{line_num}: > ", true))!="ok" #输入ok时退出多行模式
				str << exp + "\n"
				line_num += 1
			end
			p TOPLEVEL_BINDING.eval str
		elsif !exp.empty? # 排除空字符串
			p TOPLEVEL_BINDING.eval exp
		end
	rescue Exception => e
		puts e
	end
end