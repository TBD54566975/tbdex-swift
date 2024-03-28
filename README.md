# tbdex-swift

[![SPI Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FTBD54566975%2Ftbdex-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/TBD54566975/tbdex-swift)
[![SPI Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FTBD54566975%2Ftbdex-swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/TBD54566975/tbdex-swift)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/TBD54566975/tbdex-swift/badge)](https://securityscorecards.dev/viewer/?uri=github.com/TBD54566975/tbdex-swift)

> ⚠️ tbDEX SWIFT SDK IS CURRENTLY A WIP! ⚠️

## Prerequisites

### Cloning

After cloning this repository, run:

```
make bootstrap
```

This will configure the repository's submodules properly, and ensure you're all set to go!

## Release Guidelines

### Pre-releases

With Swift Package Manager, pre-releases are not necessary as it can directly utilize the repository's revision or branch name. For instance, to test the current version of the tbDEX package, you can specify either:

```swift
  // Use the main branch
  .package(url: "https://github.com/TBD54566975/tbdex-swift.git", .branch("main")),

  // Use a specific commit
  .package(url: "https://github.com/TBD54566975/tbdex-swift.git", .revision("28b3c865742f3b0cb9813f84e9c547425a06ac1d")),
```

### Releasing New Versions

To release a new version, initiate the `Release` workflow:

1. Select the version type: `major`, `minor`, `patch`, or `manual`.

   - For instance, if the latest version is `0.1.2`:
     - `major` will update to `1.0.0`
     - `minor` will update to `0.2.0`
     - `patch` will update to `0.1.3`
     - For `manual`, input the desired version in the Custom Version field, e.g., `0.9.0`

2. The workflow will automatically create a git tag and a GitHub release, including an automated changelog.

### Publishing Docs

API reference documentation is automatically updated and available at [https://swiftpackageindex.com/TBD54566975/tbdex-swift/{latest-version}/documentation/tbdex](https://swiftpackageindex.com/TBD54566975/tbdex-swift/main/documentation/tbdex) following each release.

### Additional Links

- [API Reference Guide](https://swiftpackageindex.com/TBD54566975/tbdex-swift/main/documentation/tbdex)
- [Developer Docs](https://developer.tbd.website/docs/tbdex/)
