<p align="center"><img src="README-images/logo.png"/></p>

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## About

## Compatibility

The library is suitable for applications running on iOS 9 and above. The project is meant to be opened with the latest Xcode version (currently Xcode 9).

## Installation

The library can be added to a project using [Carthage](https://github.com/Carthage/Carthage) by specifying the following dependency in your `Cartfile`:
    
```
github "SRGSSR/srgcontentprotection-ios"
```

Then run `carthage update --platform iOS` to update the dependencies. You will need to manually add the following `.framework`s generated in the `Carthage/Build/iOS` folder to your project:

  * `SRGContentProtection`: The content protection library framework.
  * `SRGNetwork`: A network framework.

For more information about Carthage and its use, refer to the [official documentation](https://github.com/Carthage/Carthage).

## Usage

When you want to use classes or functions provided by the library in your code, you must import it from your source files first.

### Usage from Objective-C source files

Import the global header file using:

```objective-c
#import <SRGContentProtection/SRGContentProtection.h>
```

or directly import the module itself:

```objective-c
@import SRGContentProtection;
```

### Usage from Swift source files

Import the module where needed:

```swift
import SRGContentProtection
```

## License

See the [LICENSE](../LICENSE) file for more information.
