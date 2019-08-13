# JKDrawer

A Maps like drawer for iOS.

Features:

- control drawer size
- snap to preferred sizes
- multiple stacked drawers
- dragging and closing using gestures
- handling nested scroll views
- subtle animations
- no need to subclass view controllers

[![CocoaPods Compatible](https://img.shields.io/badge/CocoaPods-compatible-brightgreen?style=flat)](https://cocoapods.org/pods/JKDrawer)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager Compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen?style=flat)](https://github.com/Carthage/Carthage)

## Requirements

- iOS 10.0+
- Xcode 10.2+
- Swift 4+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate JKDrawer into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'JKDrawer', '~> 0.6.0'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate JKDrawer into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "johankool/JKDrawer" "0.6.0"
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is included with Xcode 11+. To integrate JKDrawer into your Xcode project using Swift Package Manager, paste this URL into Xcode via File > Packages > Add Package:

```
https://github.com/johankool/Drawer.git
```

## Usage

To be able to present a view controller as a drawer it must conform to the `DrawerPresentable` protocol. This protocol requires that configuration variable is present. This is a `DrawerConfiguration` struct specifying certain aspects like initial offset and allowed range. 

```swift
class DrawerViewController: UIViewController, DrawerPresentable {

    var configuration = DrawerConfiguration(offset: 300, isDraggable: true, isClosable: false)

}
```

The presenting view controller must conform to the `DrawerPresenting` protocol. Some methods have default implementations, others are callbacks for your convenience.

```swift
class HostViewController: UIViewController, DrawerPresenting {

    func someAction() {
        let drawerViewController = DrawerViewController()
        openDrawer(drawerViewController, animated: true)
    }

    func willOpenDrawer(_ drawer: DrawerPresentable) {

    }

    func didOpenDrawer(_ drawer: DrawerPresentable) {

    }

    func willCloseDrawer(_ drawer: DrawerPresentable) {

    }

    func didCloseDrawer(_ drawer: DrawerPresentable) {

    }

    func didChangeHeightOfDrawer(_ drawer: DrawerPresentable, to height: CGFloat) {

    }

}
```

### Navigation Controllers

Since you can't open a drawer over a `UINavigationController`. Consider using a custom view controller wrapping the `UINavigationController` instead or use `DrawerNavigationController`.

## License

Copyright (c) 2018-2019 Johan Kool

Licensed under [BSD-2-Clause-Patent](LICENSE)
