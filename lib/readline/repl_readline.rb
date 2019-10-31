require_relative 'ext_readline'

module ReplReadline
	extend ExtReadline
	
	# @candidates = []
	@pac_classes = Object.constants.reject { |i| 
		j = eval("#{i.to_s}")
		!(j.class == Class and j.superclass <= FFI::PCap::Packet)
	}.collect(&:to_s)

	@completion_proc = ->(input) {
		r = /#{Regexp.escape(input)}/

		case input

		# 作用域中的常量、变量
		when /^[a-zA-Z][^.]*$/, ""
			candidates = @candidates + TOPLEVEL_BINDING.send(:local_variables) + @pac_classes
			candidates.grep(r)

		# 全局变量（readline不识别$，暂时用不了）
		when /^\$.*/
			global_variables.grep(r)

		# 方法补全
	    when /^([^."].*)(\.|::)([^.]*)$/
	    	receiver = $1
	        sep = $2
	        message = Regexp.quote($3)

	        TOPLEVEL_BINDING.eval(%Q{
	        	if defined?(#{receiver})
					# 如果是FFI::PCap::Packet的子类（如TCPP）的实例
		        	if #{receiver}.class <= FFI::PCap::Packet
			        	(#{receiver}.methods - FFI::PCap::Packet.instance_methods).collect(&:to_s)

			        # 如果是头部类（如TCPH）的实例变量
			        elsif #{receiver}.class.included_modules.include?(Common)
			        	(#{receiver}.methods - Object.instance_methods).collect(&:to_s)

			        # 如果是包类（如TCPP）
			        elsif #{receiver}.class == Class and #{receiver} <= FFI::PCap::Packet
			        	(#{receiver}.methods - FFI::PCap::Packet.methods).collect(&:to_s) + ['new']

		        	else
		        		[]
		        	end
	        	else
	        		[]
	        	end
	        }).collect { |m| 
	        	"#{receiver}#{sep}#{m}"
	        }.grep(r)
		end
	}

	self.completion_proc = @completion_proc
	self.completion_append_character = nil
end
