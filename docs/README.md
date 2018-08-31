<p align="center"><img src="README-images/logo.png"/></p>

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## About

The SRG Content Protection framework contains the sensitive logic required for protected media playback. The following protection measures are currently supported:

* Akamai secure token.
* Digital Rights Management via FairPlay.

## Compatibility

The library is suitable for applications running on iOS 9 and above. The project is meant to be opened with the latest Xcode version (currently Xcode 9).

## Installation

The library can be added to a project using [Carthage](https://github.com/Carthage/Carthage) by adding the following dependency to your `Cartfile`:
    
```
github "SRGSSR/srgcontentprotection-ios"
```

Until Carthage 0.30, only dynamic frameworks could be integrated. Starting with Carthage 0.30, though, frameworks can be integrated statically as well, which avoids slow application startups usually associated with the use of too many dynamic frameworks.

For more information about Carthage and its use, refer to the [official documentation](https://github.com/Carthage/Carthage).

### Dependencies

The library requires the following frameworks to be added to any target requiring it:

* `SRGContentProtection`: The content protection library framework.
* `SRGNetwork`: A networking framework.

### Dynamic framework integration

1. Run `carthage update` to update the dependencies (which is equivalent to `carthage update --configuration Release`). 
2. Add the frameworks listed above and generated in the `Carthage/Build/iOS` folder to your target _Embedded binaries_.

If your target is building an application, a few more steps are required:

1. Add a _Run script_ build phase to your target, with `/usr/local/bin/carthage copy-frameworks` as command.
2. Add each of the required frameworks above as input file `$(SRCROOT)/Carthage/Build/iOS/FrameworkName.framework`.

### Static framework integration

1. Run `carthage update --configuration Release-static` to update the dependencies. 
2. Add the frameworks listed above and generated in the `Carthage/Build/iOS/Static` folder to the _Linked frameworks and libraries_ list of your target.
3. Also add any resource bundle `.bundle` found within the `.framework` folders to your target directly.
4. Add the `-all_load` flag to your target _Other linker flags_.

## Building the project

A [Makefile](../Makefile) provides several targets to build and package the library. The available targets can be listed by running the following command from the project root folder:

```
make help
```

Alternatively, you can of course open the project with Xcode and use the available schemes.

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

To play a protected media with AVPlayer, create an asset through one of the methods from the `AVURLAsset (SRGContentProtection)` category, and use it to instantiate the `AVPlayerItem` which will be played.

### Playing a protected media outside AVPlayer context

The SRG Content Protection framework does not provide any kind of integration for playback without `AVPlayer`, e.g. when using Google Cast with the standard receiver. In such cases you are responsible of retrieving a playable resource and associated credentials to supply to the external context, depending on what it requires (please refer to the associated vendor documentation):

* For Akamai token-protected streams: Use `SRGAkamaiToken` to create a request for a playable tokenized URL. Note that a token has a limited lifetime and that the tokenized URL must be played as early as possible after it has been retrieved. If you wait too much the URL might become unplayable.
* For streams protected with DRMs (except FairPlay which requires the use of `AVPlayer`, see above), your application is responsible of getting credentials to be supplied to the external context, depending on which DRMs are available and supported. Please get in touch with the team delivering streams and metadata for your application.

## Known limitations

FairPlay stream playback requires a physical iOS device. Streams will not play in the simulator.

## License

See the [LICENSE](../LICENSE) file for more information.
