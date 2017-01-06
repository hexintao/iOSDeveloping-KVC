# iOSDeveloping-KVC
[简书地址：iOS开发-KVC问答](http://www.jianshu.com/p/2e02eabd8049)
## 1. KVC 用来做什么？
和对象的点语法类似，都是用来赋值和取值的。

## 2. 为什么要用 KVC？
通常，两种情况下我们需要重新审视自己的赋值方式。
* 访问私有属性/变量。正常的情况下，我们根据设计原型，开开心心的搭建面，初始化各种控件，`UIView / UIButton / UILabel`，然后设置其相应的属性，以使界面满足我们的需求。假如界面很简单，效果不是很炫酷，那我们只需要通过设置子控件的各种属性，调整背景颜色，切个圆角，改变透明度等等，就可以将界面搞定。可是，有些效果，偏偏是通过苹果暴露给我们的接口不能满足的，比如，修改文字输入框(UITextField)的占位文字的颜色，这个时候怎么办？想要 `textField.placeholederLabel.textColor = [UIColor redColor]` 没有这个属性啊，怎么实现？另外还有一些只读属性，无法通过点语法正常赋值，怎么办？
* 请求服务器数据之后的处理。没有KVC，我们如果想给某个属性赋值，则需要通过 `object.property = value`; 这种方式进行赋值。试想一下，如果是一个对象的几个属性这样设置还行得通，可是通常客户端的数据都是从服务器端获取，格式一般是 json/xml，我们需要通过字典转模型，将字符串化的键值对转换成对象的属性值进行保存和使用，通常这种数据量是很大的，而且还是带各种嵌套的，难道这个时候我们还要先创建各种对象，然后根据键值对的键，创建对应的属性，之后再手动一个个 `model.property = value; `保存吗？肯定是不现实的。那怎么办？

## 3. 有了 KVC 之后，上述问题怎么解决？
- `[textField setValue:[UIColor purpleColor] forKeyPath:@"_placeholderLabel.textColor"];` 当然，这里边，找到正确的没有暴露的接口也是个问题，以后再说吧，大致就是利用 Runtime ，给程序打断点，然后将 UITextFiled 的所有变量（包括未暴露的私有变量）打印，之后根据名字猜测+尝试+运气通常就能找到我们需要修改的属性了。
这里为什么要使用 `setValue: forKeyPath: ` 而不是`setValue: forKey: `呢？因为 `_placeholederLabel` 是 `UITextField`的属性，而我们要设置的是`_placeholederLabel` 的属性，像这种有多层属性嵌套的情况就需要使用 `setValue: forKeyPath: `。
经过上边一行简单的代码我们就可以很优雅的实现修改占位文字的颜色问题了。这里需要说明的一点是：占位文字的颜色和大小还可以通过设置 `attributedPlaceholder` 属性设置，也是比较方便的。代码如下：
``` mm
    NSString *placeholder = @"我是占位文字";
    NSDictionary *attr = @{NSForegroundColorAttributeName : [UIColor orangeColor],
                           NSFontAttributeName : [UIFont systemFontOfSize:15] };
    textField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:placeholder attributes:attr];
```
- 关于字典转模型。这里先以很简单的单层数据为例：

![JSON 数据](http://upload-images.jianshu.io/upload_images/1659311-20aad23735dafe76.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
然后是模型`TestModel`的头文件：
``` mm
@interface TestModel : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *detail;
@property (copy, nonatomic) NSString *postscript;

- (instancetype)initWithDict:(NSDictionary *)dict;
@end
```
`TestModel`的实现文件：
``` mm
@implementation TestModel
- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end
```
最后是`ViewController`控制器中的调用代码：
``` mm
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 加载本地 json 数据，正常应是请求服务器
    [self loadData];
}

- (void)loadData {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"test.json" ofType:nil];
    // 2. 解析数据
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:NSJSONReadingMutableContainers error:nil];
    // 3. 转换，只要属性定义好，直接调用初始化方法即可
    TestModel *model = [[TestModel alloc]initWithDict:jsonDict];
    // 4. 打印验证
    NSLog(@"name - %@, detail - %@, postscript - %@", model.name, model.detail, model.postscript);
}
@end
```
打印结果验证：

![打印结果](http://upload-images.jianshu.io/upload_images/1659311-d3f646c7f966e698.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
通过上边这个十分简单的例子，我们就可以看到 KVC 在数据转模型时的便捷了。
不过这么简单的数据实际开发中很难遇到，这里这里只是演示一下，如果有多层嵌套的话，就需要在模型类中重写`setValue: forKey`方法，然后通过判断`key`，对嵌套的字段再进行转换。

![嵌套的 JSON 数据](http://upload-images.jianshu.io/upload_images/1659311-20cdf140ee8431fb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
最外层模型`TestModel`的头文件：
``` mm
@interface TestModel : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *detail;
@property (copy, nonatomic) NSString *postscript;
// 多了一个嵌套的模型属性
@property (strong, nonatomic) NestedTestModel *nestedModel;

- (instancetype)initWithDict:(NSDictionary *)dict;
@end
```
最外层模型`TestModel`的实现文件：
``` mm
@implementation TestModel
- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    // 单独处理嵌套的 key
    if ([key isEqualToString:@"nested"]) {
        self.nestedModel = [[NestedTestModel alloc]initWithDict:value];
    } else {
        // 别忘了调用父类的方法，否则其他不需要单独处理的属性就不解析了
        [super setValue:value forKey:key];
    }
}
@end
```
控制器的代码：
``` mm
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 加载本地 json 数据，正常应是请求服务器
    [self loadData];
}

- (void)loadData {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"test.json" ofType:nil];
    // 2. 解析数据
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:NSJSONReadingMutableContainers error:nil];
    // 3. 转换，只要属性定义好，直接调用初始化方法即可
    TestModel *model = [[TestModel alloc]initWithDict:jsonDict];
    // 4. 打印验证
    NSLog(@"name - %@, detail - %@, postscript - %@, nestedName - %@, nestedDetail - %@, nestedPostscript - %@, ", model.name, model.detail, model.postscript, model.nestedModel.nestedName, model.nestedModel.nestedDetail, model.nestedModel.nestedPostscript);
}
@end
```

![打印结果](http://upload-images.jianshu.io/upload_images/1659311-739eb501c3c81961.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这里嵌套内部的模型`NestedTestModel `基本跟单层 JSON 中的模型的代码一致，也就是打印验证那一点，也就不再贴代码了。文章最底有git地址。

其实，例子中的数据解析跟实际的复杂度也差好多，这时候我们往往会使用第三方框架，简单方便。这里推荐一个比较小众的第三方框架：[NSObject-ObjectMap](https://github.com/uacaps/NSObject-ObjectMap)，可以看一下它的源文件，写的很规整，就一个分类，可以实现 `json/xml` 到对象的转换，当然集合类的属性也可以自动转换（需要多写一点代码），里边有好多方法用都牵扯到了 `Runtime` 和 OC 中的反射机制。

## 4. KVC 这么牛掰，系统是怎么实现的呢？
当我们调用`setValue: forKey:testKey`方法时，系统会通过以下查找顺序进行赋值：

![setValue:forKey:顺序官方文档](http://upload-images.jianshu.io/upload_images/1659311-607fba29ad903029.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

由上图可以看出，在使用 KVC 赋值时的查找顺序依次为：
`setTestKey`方法 --> `_testKey` --> `_isTestKey` --> `testKey` --> `isTestKey`。
后边寻找实例变量的过程，有一个大的前提：对象的`accessInstanceVariablesDirectly`方法返回`YES`，当然默认情况下这个方法就是返回`YES`的，所以并不需要我们担心。如果都找不到，那就调用 `setValue:forUndefinedKey`直接抛出异常。有时候如果我们不想让程序因为这个原因抛出异常，可以在类的实现文件中重写该方法即可。
