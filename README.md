
# react-native-nexmo-verify

## Getting started

`$ npm install react-native-nexmo-verify --save`

### Mostly automatic installation

`$ react-native link react-native-nexmo-verify`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-nexmo-verify` and add `RNNexmoVerify.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNNexmoVerify.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import io.artechs.rn.nexmoverify.RNNexmoVerifyPackage;` to the imports at the top of the file
  - Add `new RNNexmoVerifyPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-nexmo-verify'
  	project(':react-native-nexmo-verify').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-nexmo-verify/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-nexmo-verify')
  	```


## Usage
```javascript
import RNNexmoVerify from 'react-native-nexmo-verify';

// TODO: What do with the module?
RNNexmoVerify;
```
  