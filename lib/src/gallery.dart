import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

/// THIS PACKAGE WAS DESIGNED TO WORK IN A NAVIGATOR WIDGET

class ImageScroller extends StatefulWidget {
  final List<dynamic> imageList;
  final int index;
  final double height;
  final double borderRadius;
  final Color color;

  final double miniatureWidth;
  final Function(int index)? onChangedIndex;
  const ImageScroller(
      {Key? key,
      required this.imageList,
      required this.color,
      required this.height,
      required this.borderRadius,
      this.index = 0,
      this.miniatureWidth = 20,
      this.onChangedIndex})
      : super(key: key);

  @override
  State<ImageScroller> createState() => _ImageScrollerState();
}

class _ImageScrollerState extends State<ImageScroller>
    with TickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  int activeImageIdx = 1;
  int onChangeIdx = 1;
  double imagePadding = 4;
  int imageLength = 0;
  double bottomSheetHeight = 0;
  double miniatureWidth = 0;

  @override
  void initState() {
    imageLength = widget.imageList.length;
    activeImageIdx = widget.index + 1;
    bottomSheetHeight = widget.height;
    miniatureWidth = widget.miniatureWidth;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      double initialScrollPosition = imagePosition(activeImageIdx);
      _controller.jumpTo(initialScrollPosition);
    });
    super.initState();
  }

  /// CALCULATING THE POSITION OF THE SCROLL CONTROLED BASED ON THE IMAGE INDEX

  double imagePosition(int index) {
    setState(() {});
    return (2 * imagePadding + miniatureWidth) * (index - 1 / 2);
  }

  /// CALCULATING THE INDEX OF THE IMAGE BASED ON THE SCROLL CONTROLED POSITION

  int imageIndex(double position) {
    int index = (position / (2 * imagePadding + miniatureWidth) + 0.5).round();
    if (index > imageLength) {
      index = imageLength;
    }
    return index;
  }

  /// CHANGING THE POSITION OF THE SCROLL CONTROLLER

  void _scrollPosition(int index) {
    double position = imagePosition(index);

    _controller.animateTo(
      position,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return false;
      },
      child: Row(
        children: [
          SizedBox(
            width: width,
            height: bottomSheetHeight,
            child: imageLength > 1
                ? NotificationListener(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        setState(() {
                          activeImageIdx = 0;
                          onChangeIdx = imageIndex(notification.metrics.pixels);
                          widget.onChangedIndex!(onChangeIdx);
                        });
                      } else if (notification is ScrollEndNotification) {
                        setState(() {
                          activeImageIdx =
                              imageIndex(notification.metrics.pixels);
                          widget.onChangedIndex!(activeImageIdx);
                        });
                      }
                      return false;
                    },
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageLength + 2,
                      controller: _controller,
                      itemBuilder: (BuildContext context, int index) {
                        return index == 0
                            ? SizedBox(width: width / 2)
                            : index == imageLength + 1
                                ? SizedBox(width: width / 2)
                                : Padding(
                                    padding: EdgeInsets.all(imagePadding),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (index != 0 ||
                                              index != imageLength) {
                                            activeImageIdx = index;
                                            _scrollPosition(activeImageIdx);
                                            widget.onChangedIndex!(
                                                activeImageIdx);
                                          }
                                        });
                                      },
                                      child: SizedBox(
                                        width: index != activeImageIdx
                                            ? miniatureWidth
                                            : null,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: widget.imageList[index - 1]
                                                  is File
                                              ? Image.file(
                                                  widget.imageList[index - 1],
                                                  color: index != onChangeIdx
                                                      ? Colors.black54
                                                      : null,
                                                  colorBlendMode:
                                                      index != onChangeIdx
                                                          ? BlendMode.darken
                                                          : null,
                                                  fit: BoxFit.cover,
                                                  alignment: Alignment.center,
                                                )
                                              : Image.network(
                                                  widget.imageList[index - 1],
                                                  color: index != onChangeIdx
                                                      ? Colors.black54
                                                      : null,
                                                  colorBlendMode:
                                                      index != onChangeIdx
                                                          ? BlendMode.darken
                                                          : null,
                                                  fit: BoxFit.cover,
                                                  alignment: Alignment.center,
                                                ),
                                        ),
                                      ),
                                    ),
                                  );
                      },
                    ),
                  )
                : SizedBox(
                    width: miniatureWidth,
                    child: widget.imageList[0] is File
                        ? Image.file(
                            widget.imageList[0],
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                          )
                        : Image.network(
                            widget.imageList[0],
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// SHARE OPTION FOR SHOWMODALBOTTOMSHEET
class ModalSheet extends StatefulWidget {
  final String imagePath;
  const ModalSheet({super.key, required this.imagePath});

  @override
  State<ModalSheet> createState() => _ModalSheetState();
}

class _ModalSheetState extends State<ModalSheet> {
  bool isValidUrl(String url) {
    final Uri uri = Uri.tryParse(url)!;
    return uri.isAbsolute && uri.hasAuthority;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: () async {
          if (isValidUrl(widget.imagePath)) {
            final response = await http.get(Uri.parse(widget.imagePath));
            final Uint8List uint8list = response.bodyBytes;

            await Share.shareXFiles([
              XFile.fromData(uint8list, name: 'image', mimeType: 'image.jpg')
            ]);
          } else {
            await Share.shareXFiles([XFile(widget.imagePath)]);
          }
        },
        title: const Row(
          children: [
            Expanded(
              flex: 1,
              child: Icon(Icons.share),
            ),
            Expanded(
              flex: 9,
              child: Text(
                'Share',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// MAIN WIDGET OF THE GALLERY

class InteractiveGallery extends StatefulWidget {
  /// The image list of the gallery.
  final List<dynamic> imageList;

  ///  The initial index of your list.
  final int index;

  /// The smallest image scale.
  final double minScale;

  /// The highest imag scale.
  final double maxScale;

  /// The minimum swiping stiffness, keep it low, to avoid diagonal movements on changing the images when sliding.
  final double minStiffness;

  /// The maximum swiping stiffness.
  final double maxStiffness;

  /// The window height proportion to pop the navigator when sliding up or down.
  final double heightWindowPop;

  /// The color of the empty space of your screen.
  final Color backgroundColor;

  /// The color of the default bottomsheet on tap.
  final Color firstBottomsheetColor;

  /// The height of the default bottomsheet on tap.
  final double firstBottomsheetHeight;

  /// The border radius of the default bottomsheet on tap.
  final double firstBottomsheetBorderRadius;

  /// Customizable bottomsheet Widget when doing simple tap on the screen.
  final Widget? singleTapBottomsheetWidget;

  /// Customizable bottomsheet Widget when doing long tap on the screen or when taping more options.
  final Widget? longTapBottomsheetWidget;

  /// The width of the miniatures images.
  final double miniatureWidth;
  final VoidCallback? onBack;

  const InteractiveGallery({
    Key? key,
    required this.imageList,
    this.index = 0,
    this.minScale = 1.0,
    this.maxScale = 5.0,
    this.minStiffness = 0.1,
    this.maxStiffness = 1.5,
    this.heightWindowPop = 0.6,
    this.backgroundColor = Colors.black,
    this.firstBottomsheetColor = const Color.fromRGBO(0, 0, 0, 0.3),
    this.firstBottomsheetHeight = 100,
    this.firstBottomsheetBorderRadius = 0,
    this.miniatureWidth = 20,
    this.singleTapBottomsheetWidget,
    this.longTapBottomsheetWidget,
    this.onBack,
  }) : super(key: key);

  @override
  State<InteractiveGallery> createState() => _InteractiveGalleryState();
}

class _InteractiveGalleryState extends State<InteractiveGallery>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  final scrollController = ScrollController();

  late PageController _pageController;
  late List<dynamic> imageList;
  late AnimationController _controller;
  late TapDownDetails _doubleTapDetails;

  ScrollPhysics pagePhysics = const NeverScrollableScrollPhysics();
  double dragStiffness = 0.5;
  bool isOpenBottom = false;
  int _pointersCount = 0;
  double scale = 1;
  double y = 0;
  bool isClosing = false;

  @override
  void initState() {
    imageList = widget.imageList;

    _pageController = PageController(initialPage: widget.index);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();
    super.initState();
  }

  /// CLOSING THE INVOKED NAVIGATOR

  void _closeSingleBottom() {
    if (isOpenBottom) {
      Navigator.pop(context);
      isOpenBottom = !isOpenBottom;
    }
  }

  /// COUNTING THE NUMBER OF FINGERS ON THE SCREEN

  void _incrementDown(PointerEvent details) {
    setState(() {
      _pointersCount++;
      y = 0;
      if (isOpenBottom) {
        isClosing = true;
        _closeSingleBottom();
      }
    });
  }

  /// DECREASING THE COUNT OF THE NUMBER OF FINGERS ON RELEASE

  void _incrementUp(PointerEvent details) {
    setState(() {
      _pointersCount--;
      y = 0;
    });
  }

  /// CALCULATING THE POSITION OF THE IMAGE WHEN DRAG UP OR DOWN

  void _updateLocation(PointerEvent details) {
    setState(() {
      isClosing = false;
      if (y.abs() < 10) {
        dragStiffness = widget.minStiffness;
      } else {
        dragStiffness = widget.maxStiffness;
      }
      y += dragStiffness * details.delta.dy;
      if (y.abs() >
          widget.heightWindowPop * MediaQuery.of(context).size.height) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: widget.backgroundColor,
            body: Stack(
              children: [
                Listener(
                  onPointerDown: _incrementDown,
                  onPointerUp: _incrementUp,
                  onPointerMove: scale == 1 ? _updateLocation : null,
                  child: PageView(
                      controller: _pageController,
                      physics: _pointersCount == 2 || scale > 1
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      children: [
                        for (int i = 0; i < imageList.length; i++)
                          Stack(children: [
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (_, child) {
                                return Transform.translate(
                                  offset: scale == 1
                                      ? Offset(0, y)
                                      : const Offset(0, 0),
                                  child: child,
                                );
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: Builder(builder: (context) {
                                  return GestureDetector(
                                    onDoubleTapDown: (d) =>
                                        _doubleTapDetails = d,
                                    onDoubleTap: _handleDoubleTap,
                                    onTap: () => _handleSimpleTap(context),
                                    onLongPress: () {
                                      showModalBottomSheet<void>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          var image = imageList[
                                              _pageController.page!.round()];
                                          return widget
                                                      .longTapBottomsheetWidget ==
                                                  null
                                              ? ModalSheet(
                                                  imagePath: image is File
                                                      ? image.path
                                                      : image)
                                              : widget
                                                  .longTapBottomsheetWidget!;
                                        },
                                      );
                                    },
                                    child: InteractiveViewer(
                                      transformationController:
                                          _transformationController,
                                      minScale: widget.minScale,
                                      maxScale: widget.maxScale,
                                      child: imageList[i] is File
                                          ? Image.file(imageList[i])
                                          : Image.network(imageList[i]),
                                      onInteractionUpdate: (details) {
                                        setState(() {
                                          scale = _transformationController
                                              .value
                                              .getMaxScaleOnAxis();
                                        });
                                      },
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ]),
                      ]),
                ),
                isOpenBottom
                    ? Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50))),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: onBack ?? () {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                              setState(() {});
                            },
                          ),
                        ),
                      )
                    : Container(),
                isOpenBottom
                    ? Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50))),
                          child: IconButton(
                            icon: const Icon(Icons.more_vert,
                                color: Colors.white),
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  var image =
                                      imageList[_pageController.page!.round()];
                                  return widget.longTapBottomsheetWidget == null
                                      ? ModalSheet(
                                          imagePath: image is File
                                              ? image.path
                                              : image)
                                      : widget.longTapBottomsheetWidget!;
                                },
                              );
                            },
                          ),
                        ),
                      )
                    : Container(),
              ],
            )));
  }

  /// OPENING A BOTTOMSHEET WITH THE MINIATURES OF THE IMAGE LIST

  void _handleSimpleTap(BuildContext theContext) {
    if (!isClosing) {
      if (!isOpenBottom && scale == 1) {
        setState(() {
          isOpenBottom = true;
        });
        Scaffold.of(theContext).showBottomSheet(
          enableDrag: false,
          backgroundColor: widget.firstBottomsheetColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.firstBottomsheetBorderRadius),
                  topRight:
                      Radius.circular(widget.firstBottomsheetBorderRadius))),
          (BuildContext context) {
            return widget.singleTapBottomsheetWidget == null
                ? ImageScroller(
                    imageList: imageList,
                    color: widget.firstBottomsheetColor,
                    height: widget.firstBottomsheetHeight,
                    borderRadius: widget.firstBottomsheetBorderRadius,
                    index: _pageController.page!.round(),
                    onChangedIndex: (index) {
                      setState(() {
                        _pageController.animateToPage(index - 1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.fastOutSlowIn);
                      });
                    },
                  )
                : widget.singleTapBottomsheetWidget!;
          },
        );
      } else if (isOpenBottom) {
        setState(() {
          isOpenBottom = false;
        });
        Navigator.pop(context);
      }
    } else {
      isClosing = false;
    }
  }

  /// ZOOM IN OR ZOOM OUT THE IMAGE

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();

      setState(() {
        scale = widget.minScale;
      });
    } else {
      scale = widget.maxScale;

      final position = _doubleTapDetails.localPosition;

      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * (widget.maxScale - 1),
            -position.dy * (widget.maxScale - 1))
        ..scale(scale);

      if (isOpenBottom) {
        isOpenBottom = !isOpenBottom;

        Navigator.pop(context);
      }
      setState(() {});
    }
  }
}
