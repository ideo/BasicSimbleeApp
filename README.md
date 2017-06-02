# Basic Simblee iOS App

SimbleeForMobile is very restricting (you can only connect with one Simblee, the app depends on being connected to the Simblee, minimal customization, etc). This is a basic example on how to connect an iOS app to a Simblee microcontroller. It demonstrates how to connect/disconnect, send/receive data, and get some of the basic information about the connection (RSSI, UUID's, local name, etc). I tried to find something like this when I first needed it, and couldn't find a good all-in-one example, so here it is!

## What you need

* An iOS device (I wrote this using iOS 10.2)
* [An Apple developer account](https://developer.apple.com) (don't wory, it's free)
* Xcode (I wrote this using v8.3.2)
* Arduino IDE with the Simblee library installed (I wrote this using Arduino v1.8.1 and Simblee v1.1.2)
* [Sparkfun Simblee Breakout](https://www.sparkfun.com/products/13632) (or anything with a Simblee microcontroller on it)
* USB to 3.3V Serial ([Sparkfun 3.3V FTDI basic works great!](https://www.sparkfun.com/products/9873))
* A 10k resitor (better than Simblee internal pullups)
* A 6 pin male header for connecting to FTDI basic

## Getting started

### Hardware

Solder or connect the 10k reesistor between D3 (labelled A4/3) and 3.3V to act as the pullup for the onboard button. Solder the 6 pin male header onto the serial pinout side of the board. Connect the FTDI Basic to the Simblee breakout via the serial header and connect that to a USB port on your computer (ready for programming!) Open BasicSimbleeApp.ino in Arduino IDE and upload it to the Simblee breakout.

### Software

Open BasicSimbleeApp.xcodeproj with Xcode. Make sure the provisioning is setup to load it onto your iOS device (doesn't work in simulator). Run it!

## How it works

Make sure you have bluetooth enabled on your iOS device or you'll get a warning when the app starts. When it first starts up, it'll begin searching for the Simblee device and timeout after 5 seconds if it doesn't find one. You can also press the ```Connect``` button to scan for the Simblee device after startup. Once connected, RSSI (updated every 2 seconds), UUID (the UUID will be different than the one specified in the sketch because the iOS app is showing the device UUID, not the service UUID), and Name will be populated with data from the Simblee breakout. You can toggle the LED on the Simblee breakout by pressing the ```Toggle LED``` button in the app. If you press the D3 button on the Simblee breakout, the label under "Simblee Button:" will be updated to say whether or not the button is pressed or released.
