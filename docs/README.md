[![SRG Content Protection logo](README-images/logo.png)](https://github.com/SRGSSR/srgcontentprotection-apple)

[![GitHub releases](https://img.shields.io/github/v/release/SRGSSR/srgcontentprotection-fake-apple)](https://github.com/SRGSSR/srgcontentprotection-apple/releases) [![platform](https://img.shields.io/badge/platfom-ios%20%7C%20tvos-blue)](https://github.com/SRGSSR/srgcontentprotection-apple) [![SPM compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager) [![GitHub license](https://img.shields.io/badge/license-(c)%20SRG%20SSR-lightgrey)](https://github.com/SRGSSR/srgcontentprotection-apple/blob/master/LICENSE)

## About

The SRG Content Protection framework contains the sensitive logic required for protected media playback. The following protection measures are currently supported:

* Akamai secure token.
* Digital Rights Management via FairPlay.

## Compatibility

The library is suitable for applications running on iOS 9, tvOS 12 and above. The project is meant to be compiled with the latest Xcode version.

## Contributing

If you want to contribute to the project, have a look at our [contributing guide](CONTRIBUTING.md).

## Integration

The library must be integrated using [Swift Package Manager](https://swift.org/package-manager) directly [within Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app). You can also declare the library as a dependency of another one directly in the associated `Package.swift` manifest.

## Usage

When you want to use classes or functions provided by the library in your code, you must import it from your source files first. In Objective-C:

```objective-c
@import SRGContentProtection;
```

or in Swift:

```swift
import SRGContentProtection
```

### Playing a protected media

To play a protected content with `AVPlayer`, create an asset through one of the methods from the `AVURLAsset (SRGContentProtection)` category, and use it to instantiate the `AVPlayerItem` which will be played.

If the protection used does not match the one required by the content, playback will likely fail.

## Known limitations

FairPlay stream playback requires a physical iOS device. Streams will not play in the simulator.

## License

See the [LICENSE](../LICENSE) file for more information.
