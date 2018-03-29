require_relative '../lib/support/kernel.rb'

exp=nil
m("[ruby]")
while (exp=readline)!="ok\n" #输入ok时退出repl
	begin
		if exp == "ml\n" #多行输入
			str = ""
			while (exp=readline)!="ok\n" #输入ok时退出多行模式
				str << exp
			end
			p eval str
		else
			p eval exp
		end
	rescue Exception => e
		puts e
	end
	m("[ruby]")
end