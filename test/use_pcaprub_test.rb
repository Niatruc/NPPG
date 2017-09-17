require 'ffi/pcap'

P = FFI::PCap
L = P::Live


pcap =
  L.new(:dev => P.dump_devices[0][0],
        :timeout => 1,
        :promisc => true,
        :handler => P::Handler)

# pcap.setfilter("ip src 10.30.31.199")

a=1
pcap.dispatch(:count=>2) do |this,pkt|
  puts "#{pkt.time}:"

  pkt.body.each_byte {|x| print "%0.2x " % x }
  a = pkt
  putc "\n"
end
p a


# Packet实例，header获取pcap文件头部（ts：时间戳；caplen：在线抓到的包的长度；len:离线包的长度），
# body获取包中数据（以一个字符串表示,也就是数据的每个字节都表示成了ascii码）

# Packet.from_string(data):使用字符串data构建Packet实例，此时header由Packet类自动创建，其中包含len等
# 
# Packet.new(hdr, body, opts={})：hdr：pcap pkthdr结构体
# opts：:time,:timestamp
# 
# Packet#copy：拷贝包，返回新的Packet实例
# Packet#set_body(data, opts={})：用字符串data作为包数据
# opts：
# :caplen,:len：最大捕获长度
# :len,:length：包总长
# 
# Packet#time：获取时间戳
# Packet#time=：设置时间戳





# Live实例
# new方法选项:
# promisc:是否设置混杂模式

# dispatch(opts={}, &block): 在块block中对捕捉到的包进行加工
# opts：
# :count表示要完成处理的包的个数（不设置:count则默认为DEFAULT_COUNT）（为0或-1则会处理所有包）
#（对loop来说，则是过滤后得到包的个数要达到:count指定的个数才能跳出loop）
# 返回成功处理的包的个数。如果在开始处理包之前就调用了CommonWrapper#stop而终止了块，则返回nil

# dispatch方法可以用来“清空接收缓存”