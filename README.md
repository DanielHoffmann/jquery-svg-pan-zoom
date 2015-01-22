jquery-svg-pan-zoom
=============

jQuery plugin to enable pan and zoom in SVG images either programatically or through mouse/touch events.

[Demo page](http://danielhoffmann.github.io/jquery-svg-pan-zoom/)

# Requirements

jQuery

SVG-enabled browser (does not work with SVG work-arounds that use Flash)

# The viewBox
The viewBox is an attribute of SVG images that define which parts of the image are visible, it is defined by 4 numbers: X, Y, Width, Height. These numbers together specify the visible area. This plugin works by manipulating these four numbers. For example, moving the image to the right alters the X value while zooming in reduces Width and Height.


# Usage
```javascript
var svgPanZoom= $("svg").svgPanZoom(options)
```
If the selection has more than one element `svgPanZoom` will return an array with an SvgPanZoom object for each image in the same order of the selection. If only one element is selected then the return is a single SvgPanZoom object. If no elements are selected the above call returns `null`

The returned SvgPanZoom object contains all options, these options can be overriden at any time directly, for example to disable mouseWheel events simply:
```javascript
svgPanZoom.events.mouseWheel= false
```

the SvgPanZoom object also has methods for manipulating the viewBox programatically. For example:
```javascript
svgPanZoom.zoomIn()
```
will zoomIn the image using options.zoomFactor.



# Options
```javascript
Options:
{
    events: {
        mouseWheel: boolean (true), // enables mouse wheel zooming events
        doubleClick: boolean (true), // enables double-click to zoom-in events
        drag: boolean (true), // enables drag and drop to move the SVG events
        dragCursor: string "move" // cursor to use while dragging the SVG
    },
    animationTime: number (300) // time in milliseconds to use as default for animations. Set 0 to remove the animation
    zoomFactor: 0.25 // how much to zoom-in or zoom-out
    panFactor: 100 // how much to move the viewBox when calling .panDirection() methods
    initialViewBox: { // the initial viewBox, if null or undefined will try to use the viewBox set in the svg tag. Also accepts string in the format "X Y Width Height"
        x: number (0) // the top-left corner X coordinate
        y: number (0) // the top-left corner Y coordinate
        width: number (1000) // the width of the viewBox
        height: number (1000) // the height of the viewBox
    },
    limits: { // the limits in which the image can be moved. If null or undefined will use the initialViewBox plus 15% in each direction
        x: number (-150)
        y: number (-150)
        x2: number (1150)
        y2: number (1150)
    }
}
```

# Methods

#### pan
```javascript
svgPanZoom.panLeft(amount, animationTime)
svgPanZoom.panRight(amount, animationTime)
svgPanZoom.panUp(amount, animationTime)
svgPanZoom.panDown(amount, animationTime)
```
Moves the SVG viewBox in the specified direction. Parameters:
 - amount: Number, optional. How much to move the viewBox, defaults to options.panFactor.
 - animationTime: Number, optional. How long the animation should last, defaults to options.animationTime.


#### zoom
```javascript
svgPanZoom.zoomIn(animationTime)
svgPanZoom.zoomOut(animationTime)
```
Zooms the viewBox. Parameters:
 - animationTime: Number, optional. How long the animation should last, defaults to options.animationTime.


#### reset
```javascript
svgPanZoom.reset()
```
Resets the SVG to options.initialViewBox values.

#### getViewBox
```javascript
svgPanZoom.getViewBox()
```
Returns the viewbox in this format:
```javascript
{
    x: number
    y: number
    width: number
    height: number
}
```

#### setViewBox
```javascript
svgPanZoom.setViewBox(x, y, width, height, animationTime)
```
Changes the viewBox to the specified coordinates. Will respect the `options.limits` adapting the viewBox if needed (moving or reducing it to fit into `options.limits`
 - x: Number, the new x coodinate of the top-left corner
 - y: Number, the new y coodinate of the top-left corner
 - width: Number, the new width of the viewBox
 - height: Number, the new height of the viewBox
 - animationTime: Number, optional. How long the animation should last, defaults to options.animationTime.

#### setCenter
```javascript
svgPanZoom.setCenter(x, y, animationTime)
```
Sets the center of the SVG. Parameters:
 - x: Number, the new x coodinate of the center
 - y: Number, the new y coodinate of the center
 - animationTime: Number, optional. How long the animation should last, defaults to options.animationTime.




# Notes:

 - Only works in SVGs inlined in the HTML. You can use $.load() to load the SVG image in the page using AJAX and call $().svgPanZoom() in the callback
 - Touch pinch events to zoom not yet supported
 - This plugin does not create any controls (like arrows to move the image) on top of the SVG. These controls are simple to create manually and they can call the methods to move the image.
