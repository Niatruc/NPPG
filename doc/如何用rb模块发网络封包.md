# 如何用rb模块发网络封包
- [要记住的事情](#要记住的事情)
- [本项目定义网络协议的方法](#本项目定义网络协议的方法)
- [生成数据包并发送](#生成数据包并发送)
  - [config_con_var.rb文件](#config_con_var.rb文件)
  - [写ruby代码生成并发送数据包](#写ruby代码生成并发送数据包)
- [接收数据包](#接收数据包)
  

## 要记住的事情
可以赋予网络协议字段的值只有以下三种形式：
1. 只包含0和1的字符串（例如`"01001000"`）
2. 只包含正整数的数组（例如`[192, 168, 1, 1]`）
3. 正整数
因此如果值的形式不是以上三种形式，需要先利用/lib/support/kernel.rb中定义的一些方法将值转换为上面三种形式(用法未写)。
**有一个例外是给以太网协议的mac地址字段赋值，值的形式是ASCII字符串（如，`"\xFF\xFF\xFF\xFF\xFF\xFF"`）。这是历史遗留问题……后续可能会改。**

## 本项目定义网络协议的方法
项目在/lib/protocol目录下放置与网络协议有关的类的定义文件，其中：
1. 定义协议头部的文件命名格式为：`<协议简称>_head.rb`，其中的协议头部对应的类名格式为`<协议简称>H`。（例如，IPv4协议头部类的定义放在`ipv4_head.rb`中，其协议头部类名为`IPv4H`）。
2. 定义协议报文的文件命名格式为：`<协议简称>_pac.rb`，其中的协议头部对应的类名格式为`<协议简称>P`。（例如，IPv4协议报文类的定义放在`ipv4_pac.rb`中，其协议报文类名为`IPv4P`）。
3. **协议报文（或称为协议包）类跟协议头部类的区别在于，协议包类包含其协议头部类的实例变量以及其下层协议的协议头部类的实例变量（如，由IPv4P类生成的报文实例中，包含EtherH类的实例变量和IPv4H类的实例变量）。这个项目就是通过面向对象编程中类的继承来表示网络报文各层协议的衔接关系。如，因为IP报文中，IP协议层的下层是链路层，项目中默认为以太网协议，所以`IPv4P`的父类为`EtherP`类。当然，这样表示项目认为IPv4协议只能基于Ether协议，这也是历史遗留的设计问题，以后可能会作修改调整。**
4. `common.rb`定义了协议头部类的公用方法，在定义协议头部类的时候需要引用该文件，并在协议头部类中包含`Common`类。
5. `common_pac.rb`定义了协议报文类的公用方法，在定义协议报文类的时候需要引用该文件，并在协议头部类中包含`CommonPac`类。
6. 协议头部类中定义字段的方式是`define_field_func({<字段名称>: <字段长度（多少个bit位）>})`。如，IPv4协议头部类中：
```ruby
class IPv4H
	include Common
	define_field_func({version:4, head_len:4, tos:8, total_len:16,
						id:16, flags:3, frag_offset:13,
						ttl:8, protocol:8, checksum:16,
						src_addr:32,
						dst_addr:32,
						opt_padding:32})
end
```

引用字段和赋值的示例如下：
```ruby
# 生成一个IPv4报文实例
my_ip_pac = IPv4P.new

# 修改该报文实例的协议字段值
my_ip_pac.etherh.src_mac = "\xFF\xFF\xFF\xFF\xFF\xFF"
my_ip_pac.ipv4h.src_addr = [192, 168, 1, 100]
```

## 生成数据包并发送
### config_con_var.rb文件
运行项目根目录下的`main.rb`文件，其会读取`config_con_var.rb`文件中定义的`CONFIG`常量（一个`Hash`实例），其中的键值对表示程序的配置项。在各协议报文类`new`一个实例变量时就会使用这些配置值作为默认值，比如`IPv4P`类创建的实例变量的IP头中的src_addr的值默认为`CONFIG[:src_ip]`的值。

### 写ruby代码生成并发送数据包
可以在运行项目根目录下的main.rb文件后，键入`rb`或`ruby`命令，进入本项目提供的ruby交互环境，键入ruby代码并回车执行。尝试使用`tab`按键使用本项目提供的有限的代码补全功能。
<br>
以下为生成并发送一个数据包的完整示例：
```ruby
# 协议报文类的new
my_pac = TCPP.new

# 设置tcp协议头的标志位中的rst标志为1
my_pac.tcph.control_flag = '00000100'

# 发送数据包十次
10.times do
  $pcap.send_packet my_pac
end
```
**注意：在进入main.rb后需要先执行`ni`命令选择要用的网卡接口。如果在ruby交互环境中运行ruby代码时发生意想不到的错误而导致不能再发送/接收数据包时，可以执行`q`命令退回到主交互环境，然后重新执行`ni`命令选择网卡接口。**

## 接收数据包
本项目使用[https://github.com/sophsec/ffi-pcap](https://github.com/sophsec/ffi-pcap)提供的类来发送和接收网络数据包，其readme.md文件中有介绍该项目的用法。
<br>
本项目在运行环境中提供了一个全局变量`$pcap`，是使用`FFI::PCap::Live`类生成的实例，可以在由用户选择的网卡接口上收发网络数据。用户在主界面执行`ni`命令选择网络接口后，该全局变量便会被重置。
以下代码为使用`$pcap`变量收包的示例：
```ruby

  # timeout为5，表示最多会在5秒后停止dispatch（其实我目前还没搞懂这个参数的真正意义）
  pcap.dispatch(timeout: 5) do|t, pkt|
    # pkt.body得到的是pkt包中的原生数据。下面用本项目提供的方法将原生数据转成一个ARPP实例
    arpp = ARPP.build_arp_pac(pkt.body)
    
    # 打印该报文的协议字段数据信息
    p arpp.pac_info
  end
  
  # 除了dispatch方法，还可以使用loop方法。二者不一样的地方是，dispatch在将网卡缓冲区的数据取完后就会跳出do..end块，但是loop方法默认不跳出，会一直尝试从网卡缓冲区读取接受的数据，没有数据的时候就一直等待（卡着不动）。
  pcap.loop do |this, pkt|
    # 一有数据就打印
    p pkt.body
  end
  
  # 可以设置条件，让loop方法在达到某些条件时跳出do..end块。如下，获取10个数据包后就跳出来。
  pcap.loop(count: 10) do |this, pkt|
    # do something
  end
  
  # 或者调用breakloop方法跳出来
  pcap.loop do |this, pkt|
    pac = TCPP.build_tcp_pac(pkt.body)
    
    # 收到了RST报文就跳出loop
    if pac.tcph.control_flag[5] == '1'
					this.breakloop
    end
  end
```
ffi-pcap提供过滤器按一定规则过滤数据后再由`dispatch`或`loop`获取。规则的写法和wireshark过滤器一样。
```ruby
# 设置filter（跟wireshark里filter的语法一样），过滤arp包。
pcap.set_filter("arp")
   
# do somgthing 
  
# 用完后就重新设置为nil
pcap.set_filter(nil)
```
