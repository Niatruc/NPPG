module CommonPac

	# 拷贝Packet实例，将Packet实例中各个尾部为‘h’且响应dup_head方法的实例变量即“协议头部”实例
	def dup_pac
		pac = self.dup
		self.instance_variables.each do |iv|
			iv = iv.to_s.delete('@')
			eval "pac.#{iv} = self.#{iv}.dup_head if pac.#{iv}.respond_to?(:dup_head)" if iv =~ /.+h$/
		end
		pac
	end

	# 将所有协议头部实例pack并加入self.body
	def renew
		self.body = ""
		self.instance_variables.each do |iv|
			iv = iv.to_s
			eval "self.body += #{iv}.pack if #{iv}.respond_to?(:pack)" if iv =~ /.+(h|_data)$/
		end
		self.body
	end

	def pac_info
		pac_info = {}
		self.instance_variables.each do |iv|
			iv = iv.to_s.delete('@')
			eval "pac_info[:#{iv}] = self.#{iv}.field_info if self.#{iv}.respond_to?(:dup_head)" if iv =~ /.+h$/
		end
		pac_info
	end

	# def self.included(c)
	# 	def c.singleton_method_added(f)
			
	# 	end
	# end
end