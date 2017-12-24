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

RJBadgeKit是一套完整的小红点(消息推送提示)解决方案，使用场景为App某个功能块有内容更新或有未读消息时右上角会有小红点提示。RJBadgeKit支持**小红点**和**数字**显示两种形式，小红点也可以是**自定义图片**。 另外，提供多层级小红点的关联显示逻辑，比如微信tab上的小红点显示数字为聊天列表里未读消息的总和，只有所有未读消息都清空的情况下tab上的小红点才会消失。

![image](https://github.com/RylanJIN/RJBadgeKit/blob/master/Example/demo.gif)

RJBadgeKit的小红点所支持的路径格式为`root.xx.xx`, 小红点原则是父节点的小红点为子节点的小红点并集。`root`为默认的根路径。如下图所示，`root.first`为子路径，`root.second`为同级子路径。在纯红点模式下，`root`的小红点显示为`root.first`, `root.second`和`root.third`的并集，同理在数字显示模式下，`root`的badge数量为`root.first`, `root.second`和`root.third`的badge数量之和。而`root.first`的badge数量则又为`root.first.firstA`和`root.first.firstB`的和。

![image](https://github.com/RylanJIN/RJBadgeKit/blob/master/Example/path.png)

## Useage

RJBadgeKit的用法包括a)add observer b)set/clear badge c)show/hide badge, 接口分别如下所示:

#### Add observer




## Author

Ryan Jin, xiaojun.jin@outlook.com

## License

RJBadgeKit is available under the MIT license. See the LICENSE file for more info.
