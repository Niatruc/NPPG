# NPPG
Network Protocol Package Generator. I have tried to develop it to a framework. 
* You can simply define a ruby class for a network protocol and pass something like `{field1: field1_length}` to a method(I will talk about this method afterward) to define the data format of this protocol's head, then NPPG will generate the class for this protocol's head. 
