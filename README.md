# RJBadgeKit

[![CI Status](http://img.shields.io/travis/RylanJIN/RJBadgeKit.svg?style=flat)](https://travis-ci.org/RylanJIN/RJBadgeKit)
[![Version](https://img.shields.io/cocoapods/v/RJBadgeKit.svg?style=flat)](http://cocoapods.org/pods/RJBadgeKit)
[![License](https://img.shields.io/cocoapods/l/RJBadgeKit.svg?style=flat)](http://cocoapods.org/pods/RJBadgeKit)
[![Platform](https://img.shields.io/cocoapods/p/RJBadgeKit.svg?style=flat)](http://cocoapods.org/pods/RJBadgeKit)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

RJBadgeKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RJBadgeKit'
```

## Introduction

This is the code repository associated with blog article: https://juejin.im/post/5b80265de51d4538a31b4165

RJBadgeKit是一套完整的小红点(消息推送提示)解决方案，使用场景为App某个功能块有内容更新或有未读消息时右上角会有小红点提示。RJBadgeKit支持**小红点**和**数字**显示两种形式，小红点也可以是**自定义图片**。 另外，提供多层级小红点的关联显示逻辑，比如微信tab上的小红点显示数字为聊天列表里未读消息的总和，只有所有未读消息都清空的情况下tab上的小红点才会消失。

![image](https://github.com/RylanJIN/RJBadgeKit/blob/master/Example/demo.gif)

RJBadgeKit的小红点所支持的路径格式为`root.xx.xx`, 小红点原则是父节点的小红点为子节点的小红点并集。root为默认的根路径。如下图所示，root.first为子路径，root.second为同级子路径。在纯红点模式下，root的小红点显示为root.first, root.second和root.third的并集，同理在数字显示模式下，root的badge数量为root.first, root.second和root.third的badge数量之和。而root.first的badge数量则又为root.first.firstA和root.first.firstB的和。

![image](https://github.com/RylanJIN/RJBadgeKit/blob/master/Example/path.png)

## Useage

RJBadgeKit的用法包括**a)** add observer **b)** set/clear badge **c)** show/hide badge, 接口分别如下所示:

#### Add observer

假设我们有个促销页面，该促销有两个商品参与活动，则促销页面的路径可设置为root.promotion，促销页面内两个商品的路径分别设为root.promotion.item1, root.promotion.item2. 现在需要推送小红点消息给用户，在promotion的入口处的button需要显示小红点提示，当用户进入到promotion页面且分别点击了item1和item2后，promotion的小红点提示才消失。

首先我们在RJPromotionViewController里面对promotionButton添加路径的观察者，当该路径被set badge时候则显示小红点，clear badge时则隐藏小红点:

```
[self.badgeController observePath:@"root.promotion" 
                        badgeView:promotionButton 
                            block:^(RJPromotionViewController *observer, NSDictionary *info) {
    // Use [observer doSomething] instead of [self doSomething] to avoid retain cycle in block
    // key path     -> info[RJBadgePathKey] : badgeContoller所observe的路径
    // badge status -> info[RJBadgeShowKey] : 当前路径所对应的badge是否处于set状态(是否应该显示小红点)
    // badge count  -> info[RJBadgeCountKey]: 当前路径所对应的badge数值(仅在badge为数值模式下有效)
}];
```

这里需要注意的几点是:

1. self.badgeController为动态生成的属性，无需自己定义和初始化，RJBadgeKit为所有NSObject对象通过category添加了badgeController
2. 无需调用remove observer, RJBadgeKit通过自释放机制自动移除observer. 如果确实需要提前移除观察者，可以调用unobservePath接口
3. 为防止循环引用，在badge的block里面用参数observer来代替self, RJBadgeKit对observer(即self.badgeController的self)进行了weak化处理并通过block回调参数传出

#### Set/clear badge

在上述例子中，当网络请求返回时发现有两个促销数据，则调用:

```
[RJBadgeController setBadgeForKeyPath:@"root.promotion.item1"];
[RJBadgeController setBadgeForKeyPath:@"root.promotion.item2"];
```

子节点的badge状态变化会触发父节点observe的block回调，所以上述两行代码执行后promotionButton会触发显示小红点。当然如果希望promotionButton不显示小红点，而是显示具体的促销数量，则可以直接如下调用:

```
[RJBadgeController setBadgeForKeyPath:@"root.promotion" count:2];
```

如果promotion item下面还有子节点, 则调用:

```
[RJBadgeController setBadgeForKeyPath:@"root.promotion.item1" count:5];
```

在这个情况下，promotionButton上显示的数值(亦即root.promotion路径对应的badge值)为root.promotion.item1和root.promotion.item2及其所有子节点的数值之和。当用户点击查看item1和item2后，分别调用clear badeg接口:

```
[RJBadgeController clearBadgeForKeyPath:@"root.promotion.item1"];
[RJBadgeController clearBadgeForKeyPath:@"root.promotion.item2"];
```

这时父节点root.promotion的badge自动clear, promotionButton的小红点会自动隐藏。如果希望在item1被clear后就强制清除root.promotion的badge, 则可以在clear item1后调用:

```
[RJBadgeController clearBadgeForKeyPath:@"root.promotion" force:YES];
```

这样即使子节点的badge尚未全部清除，父节点也会被强制clear. P.S 正常情况下不应该去调用force:YES, 如果非要调用，可能是路径结构设计不合理了。

#### Show/hide badge

RJBadgeKit支持UIView, UITabBarItem和UIBarButtonItem的小红点显示。小红点类型则支持默认圆形小红点，数值和自定义view/图片。显示的优先级为number > custom view > red dot

```
promotionButton.badgeOffset = CGPointMake(-50, 0); // 调整小红点的显示位置offset, 相对于右上角

[self.promotionButton setBadgeImage:[UIImage imageNamed:@"badgeNew"]]; // 显示自定义的badge icon

[self.promotionButton setCustomView:self.customBadgeView]; // 显示自定义的badge view
```

更详细的使用示例请参考RJBadgeKit的Example工程

## Author

Ryan Jin, xiaojun.jin@outlook.com

## License

RJBadgeKit is available under the MIT license. See the LICENSE file for more info.
