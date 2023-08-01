 * 工作概述
 
   我们通过python对心音的波形文件进行预处理和生成二阶谱图，并对图像按照进行二分类训练模型。最后将模型参数文件进行保存然后通过串口传给开发板上的寄存器进行，同时我们也在协处理器上实现了卷积神经网络加速器来对心音图像进行分类运算。
 
 # 协处理器
 
 ## 设计内容概述
 
 同时设计了一款小面积低功耗的卷积神经网络加速器，通过同时计算双层卷积的协处理器以及减少访问次数，进而减少系统的功耗和硬件资源，同时通过加速卷积的乘法运算，来提高其运行效率。
 
 ## 具体内容
 
 协处理器指令设计：我们一共拓展了五条指令集都是custom-3指令组：
 
 | 指令  | func3 | func7   | 32位的指令                 | 读取    | 写回 |
 | ----- | ----- | ------- | -------------------------- | ------- | ---- |
 | jlsd  | 110   | 0000000 | {7'h00,rs2,rs1,7'h6,7'h7b} | rs1,rs2 | 0    |
 | fconv | 110   | 0000001 | {7'h01,rs2,rs1,7'h6,7'h7b} | rs1,rs2 | 0    |
 | sconv | 110   | 0000010 | {7'h02,rs2,rs1,7'h6,7'h7b} | rs1,rs2 | 0    |
 | jact  | 101   | 0000110 | {7'h06,rs2,rs1,7'h5,7'h7b} | rs1     | rd   |
 | jconv | 001   | 0000111 | {7'h07,rs2,rs1,7'h1,7'h7b} |         | rd   |
 
 JSLD：指令负责将卷积操作的原图像数据加载到协处理器内部，rs1代表图像的长和宽（高16位为长，低16位为宽）rs2代表原图像的起始地址
 
 ![image-20230529170052552](C:\Users\xy\AppData\Roaming\Typora\typora-user-images\image-20230529170052552.png)
 
 ​                                                  原始图像数据                                      ----------------》       按行存储数据
 
 ![image-20230530174057780](C:\Users\xy\AppData\Roaming\Typora\typora-user-images\image-20230530174057780.png)
 
 Fconv指令：将第一卷积层所需的卷积核加载到协处理器 rs1代表图像的长和宽（高16位为长，低16位为宽）rs2代表卷积核的起始地址
 
 ![image-20230530174112509](C:\Users\xy\AppData\Roaming\Typora\typora-user-images\image-20230530174112509.png)
 
 Sconv指令：将第二层卷积核参数加载到协处理器内部。
 
 
 
 ![image-20230530174140994](C:\Users\xy\AppData\Roaming\Typora\typora-user-images\image-20230530174140994.png)
 
 Jact指令：负责启动处理器完成激活         rs1为需要进行激活函数的原数值
 
 ![image-20230530174155379](C:\Users\xy\AppData\Roaming\Typora\typora-user-images\image-20230530174155379.png)
 
 jconv:负责启动卷积操作    卷积和全连接
 
 
 
 ![image-20230530174206773](C:\Users\xy\AppData\Roaming\Typora\typora-user-images\image-20230530174206773.png)
 
 sresult:取出结果（还在写）
 
 协处理器硬件设计：我们设计的卷积神经网络协处理器由NICE接口，特征图存储器，权重存储器，Tanh模块，MAX模块，结果存储器，加法树组成。
 
 特征图存储器为：9个深度为7的32位处理器
 
 权重处理器为：五个深度为5的32位处理器
 
 偏置存储器为 ：一个32位存储器
 
 PE设计：行固定脉动阵列模块    
 
 ![image-20230530172918043](C:\Users\xy\AppData\Roaming\Typora\typora-user-images\image-20230530172918043.png)
 
 通过这种方法对协处理器的第一层卷积进行加速运算，该单元除第一列外每一个PE单元由特征图输入，权重输入，特征图输出，部分和输出，权重输出，乘法器，加法器，以及三个寄存器。乘法器对特征图和权重值进行乘法操作，乘法结果和暂存于REG1的数据输入给加法器，得到结果再返给REG1,循环如此直到以为卷积完成加法器结果将通过部分和输出端口输出，这样一行PE就可以参数一行二维卷积的计算结果。5行PE就可以计算二维卷积。
 
 ![image-20230530173725245](C:\Users\xy\AppData\Roaming\Typora\typora-user-images\image-20230530173725245.png)
 
 
 
 池化设计：设计了最大值\最小值池化
 
 
 
 ![image-20230530173905095](C:\Users\xy\AppData\Roaming\Typora\typora-user-images\image-20230530173905095.png)
 
 加法树设计

$$
x_t = x_0e^{-θt}+μ(1-e^{-θt}+σ\sqrt{  ({1-e^{-\theta t}})/2\theta*Φ}
$$

