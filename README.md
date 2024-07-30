# Cronet: Chromium's networking stack for your iOS applications

**Depreacted: This package was relevant when iOS didn't support QUIC/HTTP3. iOS15 onwards has native support.**

[![Build Status](https://app.bitrise.io/app/d53aeedb8c8301c3/status.svg?token=Ru7JcjzoqI86H9vtHgTweQ&branch=master)](https://app.bitrise.io/app/d53aeedb8c8301c3)
[![Version](https://img.shields.io/cocoapods/v/Cronet.svg?style=flat)](https://cocoapods.org/pods/Cronet)
[![License](https://img.shields.io/cocoapods/l/Cronet.svg?style=flat)](https://cocoapods.org/pods/Cronet)
[![Platform](https://img.shields.io/cocoapods/p/Cronet.svg?style=flat)](https://cocoapods.org/pods/Cronet)

[Cronet](https://chromium.googlesource.com/chromium/src/+/master/components/cronet) is the [Chromium network stack](https://chromium.googlesource.com/chromium/src/+/master/net/docs/life-of-a-url-request.md) made available to iOS apps as a library.

Cronet takes advantage of multiple technologies that reduce the latency and increase the throughput of the network requests that your app needs to work.

This is the same networking stack that is used in the Chrome browser by over a billion people.
Cronet has support for both [Android](https://developer.android.com/guide/topics/connectivity/cronet) and iOS.

This package makes it easy to use Cronet in your iOS apps.

**Note: You will have to disable bitcode on your target.**

## Table of contents
<!--ts-->
* [Features](#features)
* [What is this repo?](#what-is-this-repo)
* [Installing](#installing)
    * [Using Cocoapods](#using-cocoapods)
    * [Manual Installataion](#manual-installataion)
* [Usage](#usage)
* [Known Issues](#known-issues)
* [License](#license)
<!--te-->

## Features
* **Protocol support**

    Cronet natively supports the HTTP, HTTP/2, and [QUIC](https://www.chromium.org/quic) protocols.

* **Request prioritization**

    The library allows you to set a priority tag for the requests. The server can use the priority tag to determine the order in which to handle the requests.

* **Resource caching**

    Cronet can use an in-memory or disk cache to store resources retrieved in network requests. Subsequent requests are served from the cache automatically.

* **Asynchronous requests**

    Network requests issued using the Cronet Library are asynchronous by default. Your worker threads aren't blocked while waiting for the request to come back.

* **Data compression**

    Cronet supports data compression using the [Brotli Compressed Data Format](https://tools.ietf.org/html/rfc7932).

## What is this repo?

You may be wondering, if Cronet is a chromium libary, what is this repo about?

That is right, Cronet is a chromium library and this repo doesn't add or modify any chromium code. For that fact this repo doesn't even have any code.
This repo is about making Cronet easier to use in your iOS app if you are not a google employee.

As some one of HN succiently said:

> Chromium is a fairly typical google project where the recommended first step to building it is to become a google employee but some alternative workarounds are also available if that's not practical.

More precisely this repo:

1. Fetches unofficial [cronet build artificats](https://console.cloud.google.com/storage/browser/chromium-cronet/ios) that chromium publishes.
1. Merge the iphoneos and iphonesimulator frameworks together using `lipo` for both static and dynamic builds
1. Publishes a github release with the static, dymanic and dysm archives attached to the release on github
1. Publishes the static version of the module to cocoapods under [Cronet](https://cocoapods.org/pods/Cronet)

## Installing

1. **Make sure bitcode is disabled** on the target you want to link `Cronet` with.
1. Link `Cronet.framework` into your iOS app's workspace/project either using `cocoapods` or manually linking the framework.

### Using Cocoapods

1. Add `pod 'Cronet'` under your desired target in your `Podfile`:
1. Run `pod install`

### Manual Installataion

1. Download the appropriate archive that you want to use from the [latest release](https://github.com/akshetpandey/Cronet.framework/releases/latest)
1. Extarct the archive and copy the `Cronet.framewrok` folder into your project by dragging the folder into your project in **Xcode**.
    Make sure to select **Copy items if needed** in the dialog that pops up
1. In your `Target` -> `Build Phase` -> `Link Binary With Libraries` add `SystemConfiguration.framework`
1. In your `Target` -> `Build Settings` -> `Other Linker Flags` add `-lc++`


## Usage

Initialize cronet somewhere in your app's start flow. For example, in:

```objc
- (BOOL)application:... didFinishLaunchingWithOptions:...
```

Add:
```objc
[Cronet setHttp2Enabled:YES];
[Cronet setQuicEnabled:YES];
[Cronet setBrotliEnabled:YES];
[Cronet start];
[Cronet registerHttpProtocolHandler];
```

For a complete list of initilization options see [Cronet.h](https://chromium.googlesource.com/chromium/src/+/master/components/cronet/ios/Cronet.h)

## Known Issues

1. Cronet library is not available in a bitcode enabled version. So you **must disable bitcode** in your target to use it.
1. Some `NSURLSession*Delegate` callback's don't work when cronet is registered as a protocol handler in that session.
1. Dsym is only available for dynamic framework.

## License

See the [LICENSE](https://github.com/akshetpandey/Cronet.framework/blob/master/LICENSE) file for more info.
