<p align="center"><img src="README-images/logo.png"/></p>

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## About

The SRG Content Protection framework contains the sensitive logic required for protected media playback. The following protection measures are currently supported:

* Akamai secure token.
* Digital Rights Management via FairPlay.

## Compatibility

The library is suitable for applications running on iOS 9 and above. The project is meant to be opened with the latest Xcode version (currently Xcode 9).

## Installation

The library can be added to a project using [Carthage](https://github.com/Carthage/Carthage) by specifying the following dependency in your `Cartfile`:
    
```
github "SRGSSR/srgcontentprotection-ios"
```

Then run `carthage update --platform iOS` to update the dependencies. You will need to manually add the following `.framework`s generated in the `Carthage/Build/iOS` folder to your project:

  * `SRGContentProtection`: The content protection library framework.
  * `SRGNetwork`: A networking framework.

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

### Playing a protected media with AVPlayer

To play a protected media with AVPlayer, create an asset through one of the methods from the `AVURLAsset (SRGContentProtection)` category, and use it to instantiate the `AVPlayerItem` which will be played. Based on the content protection you choose, and provided it matches the one of the stream, the SRG Content Provider ensures the stream can be played, whether on the device or using AirPlay.

### Playing a protected media outside AVPlayer context

The SRG Content Protection framework does not provide any kind of integration for playback without `AVPlayer`, e.g. when using Google Cast. In such cases you are responsible of retrieving a playable resource and associated credentials to supply to the external context, depending on what it requires (please refer to the associated vendor documentation):

* For Akamai token-protected streams: Use the `SRGAkamaiTokenService` to retrieve a tokenized URL you can play. Note that a token has a limited lifetime and that the tokenized URL must be played as early as possible after it has been retrieved. If you wait too much the URL might become unplayable.
* For streams protected with DRMs (except FairPlay which requires the use of `AVPlayer`, see above), your application is responsible of getting credentials to be supplied to the external context, depending on which DRMs are available and supported. Please get in touch with the team delivering streams and metadata for your application.

## License

See the [LICENSE](../LICENSE) file for more information.
