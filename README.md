<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# interactive_gallery

A flutter package to view a image gallery inspired on Discord, with:

* Zoom images.
* Slide between different images.
* Dismissable pages on up or down drag.
* Visualizing miniatures of the images.
* Sharing the selected image to other apps.
* Highly customizable miniature views on the botomsheet.

## Platform Support

* [X] Android
* [X] iOS
* [X] MacOS
* [X] Web
* [X] Linux
* [X] Windows

It may show limited capabilities to desktop applications, given the unexistance to swipe.

## Getting started

<video 
    src="https://github.com/vcadillog/interactive-gallery/blob/master/assets/image_gallery.mp4" 
    
>
</video>





This package relies on share_plus to share your images.

## Usage

Import the library.

```dart
import 'package:interactive_gallery/interactive_gallery.dart';
```

Invoke the Widget with your image list. Your list has to be List `<File> `for local images or `<String>` for network images.

```dart
InteractiveGallery(imageList: networkImages)                            

```

## Additional information

Arguments of the package:

* imageList;
  Your image data, required data, `<File> `type for local image,`<String>` type for network images.
* index:
  The initial index of your list, default 0.
* minScale:
  The smallest image scale, default 1.
* maxScale:
  The highest imag scale, default 5.
* minStiffness:
  The minimum swiping stiffness, keep it low, to avoid diagonal movements on changing the images when sliding, default 0.1
* maxStiffness:

  The maximum swiping stiffness, default 1.5
* heightWindowPop:

  The window height proportion to pop the navigator when sliding up or down, default 0.6
* backgroundColor:

  The color of the empty space of your screen, default is black.
* firstBottomsheetColor:

  The color of the default bottomsheet on tap, default is black with 0.3 oppacity.
* firstBottomsheetHeight:

  The height of the default bottomsheet on tap, default is 100.
* firstBottomsheetBorderRadius:

  The border radius of the default bottomsheet on tap, default is 0.
* miniatureWidth:

  The width of the miniatures of the default bottomsheet images.
* Widget? singleTapBottomsheetWidget:

  Customizable bottomsheet Widget when doing simple tap on the screen, default is the ImageScroller Widget, to show miniatures
* Widget? longTapBottomsheetWidget:

  Customizable bottomsheet Widget when doing long tap on the screen or when taping more options, default is the ModalSheet Widget, to share your picture to other apps.

## Customizing bottomsheet Widgets

Import the library.

```dart
InteractiveGallery(  
                imageList: networkImages,  
		singleTapBottomsheWidget: Container(height: 100, color: Colors.red),
                longTapBottomsheetWidget: Container(height: 100, color: Colors.yellow),                                                   
                )              

```
