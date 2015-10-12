###
jQuery SVG Pan Zoom v1.0.3, October 2015

Author: Daniel Hoffmann Bernardes (daniel.hoffmann.bernardes@gmail.com)

Repository: https://github.com/DanielHoffmann/jquery-svg-pan-zoom/

jQuery plugin to enable pan and zoom in SVG images either programmatically or through mouse/touch events.

[Demo page](http://danielhoffmann.github.io/jquery-svg-pan-zoom/)

# Features
 - Programmatically manipulate the SVG viewBox
 - Mouse and touch events to pan the SVG viewBox
 - Mousewheel events to zoom in or out the SVG viewBox
 - Animations
 - Mousewheel zooming keeps the cursor over the same coordinates relative to the image (A.K.A. GoogleMaps-like zoom)
 - Limiting the navigable area

# Requirements

jQuery

SVG-enabled browser (does not work with SVG work-arounds that use Flash)

# The viewBox
The viewBox is an attribute of SVG images that defines the area of the SVG that is visible, it is defined by 4 numbers: X, Y, Width, Height. These numbers together specify the visible area. This plugin works by manipulating these four numbers. For example, moving the image to the right alters the X value while zooming in reduces Width and Height.


# Usage
```javascript
var svgPanZoom= $("svg").svgPanZoom(options)
```

If the selection has more than one element `svgPanZoom` will return an array with a SvgPanZoom object for each image in the same order of the selection. If only one element is selected then the return is a single SvgPanZoom object. If no elements are selected the above call returns `null`

The returned SvgPanZoom object contains all options, these options can be overriden at any time directly, for example to disable mouseWheel events simply:

```javascript
svgPanZoom.events.mouseWheel= false
```


the SvgPanZoom object also has methods for manipulating the viewBox programmatically. For example:

```javascript
svgPanZoom.zoomIn()
```

will zoomIn the image using options.zoomFactor.

# Building
This project requires coffeescript to be installed in order to build.

 `coffee -m --compile --output compiled/ src/`

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
    animationTime: number (300), // time in milliseconds to use as default for animations. Set 0 to remove the animation
    zoomFactor: number (0.25), // how much to zoom-in or zoom-out
    maxZoom: number (3), //maximum zoom in, must be a number bigger than 1
    panFactor: (number (100), // how much to move the viewBox when calling .panDirection() methods
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

 - pan

```javascript
svgPanZoom.panLeft(amount, animationTime)
svgPanZoom.panRight(amount, animationTime)
svgPanZoom.panUp(amount, animationTime)
svgPanZoom.panDown(amount, animationTime)
```

Moves the SVG viewBox in the specified direction. Parameters:
 - amount: Number, optional. How much to move the viewBox, defaults to options.panFactor.
 - animationTime: Number, optional. How long the animation should last, defaults to options.animationTime.


 - zoom

```javascript
svgPanZoom.zoomIn(animationTime)
svgPanZoom.zoomOut(animationTime)
```

Zooms the viewBox. Parameters:
 - animationTime: Number, optional. How long the animation should last, defaults to options.animationTime.


 - reset

```javascript
svgPanZoom.reset()
```

Resets the SVG to options.initialViewBox values.

 - getViewBox

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

 - setViewBox

```javascript
svgPanZoom.setViewBox(x, y, width, height, animationTime)
```

Changes the viewBox to the specified coordinates. Will respect the `options.limits` adapting the viewBox if needed (moving or reducing it to fit into `options.limits`
 - x: Number, the new x coodinate of the top-left corner
 - y: Number, the new y coodinate of the top-left corner
 - width: Number, the new width of the viewBox
 - height: Number, the new height of the viewBox
 - animationTime: Number, optional. How long the animation should last, defaults to options.animationTime.

 - setCenter

```javascript
svgPanZoom.setCenter(x, y, animationTime)
```

Sets the center of the SVG. Parameters:
 - x: Number, the new x coordinate of the center
 - y: Number, the new y coordinate of the center
 - animationTime: Number, optional. How long the animation should last, defaults to options.animationTime.




# Notes:

 - Only works in SVGs inlined in the HTML. You can use $.load() to load the SVG image in the page using AJAX and call $().svgPanZoom() in the callback
 - Touch pinch events to zoom not yet supported
 - This plugin does not create any controls (like arrows to move the image) on top of the SVG. These controls are simple to create manually and they can call the methods to move the image.
 - Do not manipulate the SVG viewBox attribute manually, use SvgPanZoom.setViewBox() instead

Copyright (C) 2014 Daniel Hoffmann Bernardes, Ícaro Technologies
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###

do ($ = jQuery) ->
    defaultOptions =
        events:
            mouseWheel: true
            doubleClick: true
            drag: true,
            dragCursor: "move"
        animationTime: 300
        zoomFactor: 0.25
        maxZoom: 3
        panFactor: 100
        initialViewBox: null
        limits: null

    defaultViewBox =
        x: 0
        y: 0
        width: 1000
        height: 1000

    ###*
    # Check the limits of the view box, return a new viewBox that respects the limits while keeping
    # the original view box size if possible. If the view box needs to be reduced, the returned view
    # box will keep the aspect ratio of the original view box.
    #
    # @param {Object} viewBox
    #   The original view box. Takes numbers, in the format `{x, y, width, height}`.
    #
    # @param {Object} limits
    #   Extents which can be shown, in the view box coordinate system. Takes numbers in the format
    #   `{x, y, x2, y2}`.
    #
    # @return {Object} viewBox
    #   A new view box object, squeezed into the limits. Contains numbers, in the format `{x, y,
    #   width, height}`.
    ###
    checkLimits= (viewBox, limits) ->
        vb = $.extend({}, viewBox)

        limitsWidth = Math.abs(limits.x2 - limits.x)
        limitsHeight = Math.abs(limits.y2 - limits.y)

        #reducing the view box size if it no longer fits within the limits
        if vb.width > limitsWidth
            if vb.height > limitsHeight
                if limitsWidth > limitsHeight #reduce to fit height
                    reductionFactor = limitsHeight / vb.height
                    vb.height = limitsHeight
                    vb.width = vb.width * reductionFactor
                else #reduce to fit width
                    reductionFactor = limitsWidth / vb.width
                    vb.width = limitsWidth
                    vb.height = vb.height * reductionFactor
            else #reduce to fit width
                reductionFactor = limitsWidth / vb.width
                vb.width = limitsWidth
                vb.height = vb.height * reductionFactor
        else if vb.height > limitsHeight #reduce to fit height
            reductionFactor = limitsHeight / vb.height
            vb.height = limitsHeight
            vb.width = vb.width * reductionFactor


        #moving the view box if its bounds are outside the specified limits
        if vb.x < limits.x
            vb.x = limits.x

        if vb.y < limits.y
            vb.y = limits.y

        if vb.x + vb.width > limits.x2
            vb.x = limits.x2 - vb.width

        if vb.y + vb.height > limits.y2
            vb.y = limits.y2 - vb.height

        return vb

    ###*
    # Parse the viewbox string as defined in the spec for the svg tag.
    #
    # @param {String} viewBoxString
    #   A valid value of the `viewBox` attribute.
    #
    # @return {Object} viewBox
    #   A view box object. Contains numbers, in the format `{x, y, width, height}`.
    ###
    parseViewBoxString = (string) ->
        vb = string.replace("\s+", " ").split(" ")
        vb =
            x: parseFloat(vb[0])
            y: parseFloat(vb[1])
            width: parseFloat(vb[2])
            height: parseFloat(vb[3])


    ###*
    # Get the mouse or first touch position from the `event`, relative to the SVG viewBox.
    #
    # @param {SVGElement} svgRoot
    #   The `<svg>` DOM object
    #
    # @param {MouseEvent|TouchEvent|jQueryEvent} event
    #   The DOM or jQuery event.
    #
    # @return {Object}
    #   Coordinates of the event. Contains numbers, in the format `{x, y}`.
    ###
    getViewBoxCoordinatesFromEvent = (svgRoot, event) ->
        foo=
            x: null
            y: null
        if event.type == "touchstart" or event.type == "touchmove"
            #in this method event can be a DOM event or a jQuery normalized event
            #jQueryEvents do not expose the touches property
            #so we need to go in the original event
            if event.originalEvent? and not event.touches?
                foo.x = event.originalEvent.touches[0].clientX
                foo.y = event.originalEvent.touches[0].clientY
            else
                foo.x = event.touches[0].clientX
                foo.y = event.touches[0].clientY
        else #mouse event
            #for some reason mouse events binded using jQuery
            #set clientX and clientY as undefined so we need to go
            #into the original event
            if event.clientX?
                foo.x = event.clientX
                foo.y = event.clientY
            else
                foo.x = event.originalEvent.clientX
                foo.y = event.originalEvent.clientY

        pos = svgRoot.createSVGPoint()

        #we are calling parseInt() because otherwise firefox SVGPoint implementation gives
        #TypeError: Value being assigned to SVGPoint.x is not a finite floating-point value.
        pos.x= parseInt(foo.x, 10)
        pos.y= parseInt(foo.y, 10)
        ctm = svgRoot.getScreenCTM()
        ctm = ctm.inverse()
        pos = pos.matrixTransform(ctm);
        return pos

    $.fn.svgPanZoom = (options) ->
        ret= []
        @each ->
            #opts is the object that is returned to the caller with methods.
            #The opts object contains the initial options in addition to methods to manipulate
            #the SVG
            opts = $.extend(true, {}, defaultOptions, options)
            opts.$svg = $(@)

            unless opts.animationTime?
                opts.animationTime = 0

            opts.$svg[0].setAttribute("preserveAspectRatio", "xMidYMid meet");

            vb = $.extend({}, @.viewBox.baseVal)

            #firefox returns empty object if no viewBox is set in the element
            unless vb.x?
                vb.x = 0
            unless vb.y?
                vb.y = 0
            unless vb.width?
                vb.width = 0
            unless vb.height?
                vb.height = 0

            if opts.initialViewBox?
                if typeof opts.initialViewBox == "string"
                    vb = parseViewBoxString(opts.initialViewBox)
                else if typeof opts.initialViewBox == "object"
                    vb = $.extend({}, defaultViewBox, opts.initialViewBox)
                else
                    throw "initialViewBox is of invalid type"
            else if vb.x == 0 and vb.y == 0 and vb.width == 0 and vb.height == 0
                    vb = defaultViewBox

            #this viewBox variable is a private property accessed by the methods
            #it is not exposed directly to the end user, to access it
            #the user must use getViewBox() and setViewBox()
            viewBox = vb
            opts.initialViewBox = $.extend({}, viewBox)

            unless opts.limits?
                horizontalSizeIncrement = viewBox.width * 0.15
                verticalSizeIncrement = viewBox.height * 0.15
                opts.limits =
                    x: viewBox.x - horizontalSizeIncrement
                    y: viewBox.y - verticalSizeIncrement
                    x2: viewBox.x + viewBox.width + horizontalSizeIncrement
                    y2: viewBox.y + viewBox.height + verticalSizeIncrement


            opts.reset = ->
                inivb= @initialViewBox
                @setViewBox(inivb.x, inivb.y, inivb.width, inivb.height, 0)
                return
            opts.getViewBox = ->
                return $.extend({}, viewBox)

            $animationDiv = $("<div></div>")
            opts.setViewBox = (x, y, width, height, animationTime= @animationTime) ->
                if animationTime > 0
                    $animationDiv.css
                        left: viewBox.x + "px"
                        top: viewBox.y + "px"
                        width: viewBox.width + "px"
                        height: viewBox.height + "px"

                #the parameters in this method can be undefined/null
                #in that case we keep the current values
                viewBox =
                    x: if x? then x else viewBox.x
                    y: if y? then y else viewBox.y
                    width: if width then width else viewBox.width
                    height: if height then height else viewBox.height
                viewBox= checkLimits(viewBox, @limits)

                if animationTime > 0
                    #.animate() animates CSS rules, but we are changing the tag attributes
                    #so we instead animate this div that is not inside the DOM
                    #in the step callback of the animate function we set the viewBox on the svg
                    #to be the same as the values set in this placeholder div
                    $animationDiv.stop().animate
                            left: viewBox.x
                            top: viewBox.y
                            width: viewBox.width
                            height: viewBox.height
                        ,
                            duration: animationTime
                            easing: "linear"
                            step: ((value, properties) ->
                                $div= $animationDiv
                                #we can't use $.attr because in SVG attributes are case-sensitive and jQuery lowercases the attribute names
                                #the -3 removes the "px" from the string
                                @.$svg[0].setAttribute("viewBox", "#{ $div.css("left")[0..-3] } #{ $div.css("top")[0..-3] } #{ $div.css("width")[0..-3] } #{ $div.css("height")[0..-3] }")
                                return
                            ).bind(@)
                else
                    @$svg[0].setAttribute("viewBox", "#{ viewBox.x } #{ viewBox.y } #{ viewBox.width } #{ viewBox.height }")
                return


            opts.panLeft = (amount= @panFactor, animationTime= @animationTime) ->
                @panRight(-amount, animationTime)
                return
            opts.panRight = (amount= @panFactor, animationTime= @animationTime) ->
                @setViewBox(viewBox.x + amount, null, null, null, animationTime)
                return

            opts.panUp = (amount= @panFactor, animationTime= @animationTime) ->
                @panDown(-amount, animationTime)
                return
            opts.panDown = (amount= @panFactor, animationTime= @animationTime) ->
                @setViewBox(null, viewBox.y + amount, null, null, animationTime)
                return

            opts.zoomIn = (amount= @zoomFactor, animationTime= @animationTime) ->
                @zoomOut(-amount, animationTime)
                return
            opts.zoomOut = (amount= @zoomFactor, animationTime= @animationTime) ->
                if amount == 0
                    return
                else if amount < 0
                    amount= Math.abs(amount)
                    newWidth =  viewBox.width / (1+amount)
                    newHeight = viewBox.height / (1+amount)
                else
                    newWidth =  viewBox.width * (1+amount)
                    newHeight = viewBox.height * (1+amount)

                #keeping the same overall center of the image
                center=
                    x: viewBox.x + viewBox.width/2
                    y: viewBox.y + viewBox.height/2
                @setViewBox(center.x - newWidth/2, center.y - newWidth/2, newWidth, newHeight, animationTime)
                return

            opts.setCenter = (x, y, animationTime= @animationTime) ->
                @setViewBox(x - viewBox.width/2, y - viewBox.height/2, viewBox.width, viewBox.height, animationTime)
                return

            #binding the methods to the opts object
            for own key, value of opts
                if typeof value == "function"
                    opts.key= value.bind(opts)

            ###################################
            # binding events
            ###################################

            #TODO detect presence of jquery-mousewheel plugin (soon it will merged to core jQuery)
            #use it instead of getting the delta from the original event
            #maybe use the mouse wheel delta as zoomFactor?
            opts.$svg.on "mousewheel DOMMouseScroll MozMousePixelScroll", ((ev) ->
                delta = parseInt(ev.originalEvent.wheelDelta or -ev.originalEvent.detail)
                if delta == 0 or opts.events.mouseWheel != true
                    return

                oldViewBox = @getViewBox()

                ev.preventDefault()
                ev.stopPropagation()

                oldMousePosition = getViewBoxCoordinatesFromEvent(@$svg[0], ev)
                oldcenter =
                    x: viewBox.x + viewBox.width/2
                    y: viewBox.y + viewBox.height/2
                oldDistanceFromCenter =
                    x: oldcenter.x - oldMousePosition.x
                    y: oldcenter.y - oldMousePosition.y

                if delta > 0
                    @zoomIn(undefined, 0)
                    #checking if maxzoom was overflowed
                    minWidth= @initialViewBox.width / @maxZoom
                    minHeight= @initialViewBox.height / @maxZoom
                    if viewBox.width < minWidth
                        reductionFactor = minWidth / viewBox.width
                        viewBox.width = minWidth
                        viewBox.height = viewBox.height * reductionFactor
                    if viewBox.height < minHeight
                        reductionFactor = minHeight / viewBox.height
                        viewBox.height = minHeight
                        viewBox.width = viewBox.width * reductionFactor
                else
                    @zoomOut(undefined, 0)


                newMousePosition = getViewBoxCoordinatesFromEvent(@$svg[0], ev)

                newcenter =
                    x: oldcenter.x + (oldMousePosition.x - newMousePosition.x)
                    y: oldcenter.y + (oldMousePosition.y - newMousePosition.y)

                @setCenter(newcenter.x, newcenter.y, 0)
                newViewBox = @getViewBox()
                @setViewBox(oldViewBox.x, oldViewBox.y, oldViewBox.width, oldViewBox.height, 0) #turns back the viewBox to the original position
                @setViewBox(newViewBox.x, newViewBox.y, newViewBox.width, newViewBox.height) #sets the viewBox to the new calculated position but shows animation if enabled
                return
            ).bind(opts)



            opts.$svg.dblclick ((ev) ->
                if opts.events.doubleClick != true
                    return
                ev.preventDefault()
                ev.stopPropagation()
                @zoomIn()
            ).bind(opts)

            opts.$svg[0].addEventListener("click", (ev) ->
                if preventClick
                    preventClick = false
                    ev.stopPropagation()
                    ev.preventDefault()
            , true)

            dragStarted = false

            preventClick = false

            opts.$svg.on "mousedown touchstart", ((ev) ->
                if dragStarted #a drag operation is already happening
                    return
                if opts.events.drag != true or (ev.type == "mousedown" and ev.which != 1)
                    return
                dragStarted = true
                preventClick = false

                ev.preventDefault()
                ev.stopPropagation()

                initialViewBox = $.extend({}, viewBox)

                $body = $(window.document.body)
                domBody= $body[0]
                oldCursor = $body.css("cursor")
                if @events.dragCursor?
                    $body.css("cursor", @events.dragCursor)

                mouseMoveCallback = ((ev2) ->
                    ev2.preventDefault()
                    ev2.stopPropagation()

                    #The initalMousePositioin calculation needs to be done here because it requires
                    #the current viewbox, not the viewbox at the time the mousedown was triggered
                    initialMousePosition = getViewBoxCoordinatesFromEvent(@$svg[0], ev)

                    currentMousePosition = getViewBoxCoordinatesFromEvent(@$svg[0], ev2)

                    if Math.sqrt(Math.pow(ev.pageX + ev2.pageX, 2) + Math.pow(ev.pageY + ev2.pageY, 2)) > 3 #mouse moved at least 3 pixels
                        preventClick = true

                    @setViewBox(
                        initialViewBox.x + initialMousePosition.x - currentMousePosition.x,
                        initialViewBox.y + initialMousePosition.y - currentMousePosition.y,
                        null,
                        null,
                        0
                    )
                    return
                ).bind(opts)

                mouseUpCallback = ((ev2) ->
                    if ev2.type == "mouseout" and ev2.target != ev2.currentTarget #mouse out on an element that is not the body
                        return

                    ev2.preventDefault()
                    ev2.stopPropagation()

                    #we want to trigger the events in the capture phase as opposed to the bubble phase
                    #so we can not use jQuery here
                    domBody.removeEventListener("mousemove", mouseMoveCallback, true)
                    domBody.removeEventListener("touchmove", mouseMoveCallback, true)
                    domBody.removeEventListener("mouseup", mouseUpCallback, true)
                    domBody.removeEventListener("touchend", mouseUpCallback, true)
                    domBody.removeEventListener("touchcancel", mouseUpCallback, true)
                    domBody.removeEventListener("mouseout", mouseUpCallback, true)

                    if @events.dragCursor?
                        $body.css("cursor", oldCursor)

                    dragStarted = false
                    return
                ).bind(opts)

                domBody.addEventListener("mousemove", mouseMoveCallback, true)
                domBody.addEventListener("touchmove", mouseMoveCallback, true)
                domBody.addEventListener("mouseup", mouseUpCallback, true)
                domBody.addEventListener("touchend", mouseUpCallback, true)
                domBody.addEventListener("touchcancel", mouseUpCallback, true)
                domBody.addEventListener("mouseout", mouseUpCallback, true)
                return
            ).bind(opts)


            opts.setViewBox(vb.x, vb.y, vb.width, vb.height, 0)

            ret.push(opts)
            return

        if ret.length == 0
            return null
        if ret.length == 1
            return ret[0]
        else
            return ret
