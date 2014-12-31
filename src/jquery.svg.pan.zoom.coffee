###
jQuery SVG Pan Zoom v1.0.0, December 2014

Author: Daniel Hoffmann Bernardes (daniel.hoffmann.bernardes@gmail.com)


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
        panFactor: 100
        initialViewBox: null
        limits: null

    defaultViewBox =
        x: 0
        y: 0
        width: 1000
        height: 1000

    ###
    checks the limits of the view box, returns a new viewBox that respects the limits
    while keeping the original view box size if possible
    If the view box needs to be reduced the returned view box will keep the aspect ratio of
    the original view box
    ###
    checkLimits= (viewBox, limits) ->
        vb = $.extend({}, viewBox)

        limitsWidth = limits.x2 - limits.x
        limitsHeight = limits.y2 - limits.y


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
            else
                vb.width = limitsWidth
        else if vb.height > limitsHeight
            vb.height = limitsHeight


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

    #gets the mouse or first touch position from the event relative to the SVG viewBox
    #svgRoot is the DOM object (not jQuery object)
    #returns an object { x: , y: }
    getViewBoxCoordinatesFromEvent = (svgRoot, event) ->
        pos = svgRoot.createSVGPoint()
        if event.type == "touchstart" or event.type == "touchmove"
            pos.x = event.originalEvent.touches[0].clientX
            pos.y = event.originalEvent.touches[0].clientY
        else #mouse event
            pos.x = event.clientX
            pos.y = event.clientY
        ctm = svgRoot.getScreenCTM()
        ctm = ctm.inverse()
        pos = pos.matrixTransform(ctm);
        return pos

    $.fn.svgPanZoom = (options) ->
        ret= []
        @each ->
            #opts is the object that is returned to the caller with methods.
            #The opts object contains the inital options in addition to methods to manipulate
            #the SVG
            opts = $.extend({}, options, defaultOptions)
            opts.$svg = $(@)

            unless opts.animationTime?
                opts.animationTime = 0

            opts.$svg[0].setAttribute("preserveAspectRatio", "xMidYMid meet");

            vb= $.extend({}, @.viewBox.baseVal)
            unless opts.initialViewBox?
                if vb.x == 0 and vb.y == 0  and vb.width == 0 and vb.height == 0
                    vb = defaultViewBox
                else
                    vb =
                        x: vb.x
                        y: vb.y
                        width: vb.width
                        height: vb.height

            else if typeof opts.initialViewBox == "string"
                vb = opts.initialViewBox.replace("\s+", " ")
                vb = vb.split(" ")
                vb =
                    x: vb[0]
                    y: vb[1]
                    width: vb[2]
                    height: vb[3]

            else if typeof opts.initialViewBox == "object"
                vb = $.extend({}, defaultViewBox, opts.initialViewBox)

            else
                throw "initialViewBox is of invalid type"

            #this viewBox is a private property accessed by the methods
            #it is not exposed directly to the end user, to access it
            #the user must use getViewBox() or setViewBox()
            viewBox = vb
            opts.initialViewBox = $.extend({}, viewBox) #doing this so we can .reset() more easily

            unless opts.limits?
                horizontalSizeIncrement = viewBox.width * 0.15
                verticalSizeIncrement = viewBox.height * 0.15
                opts.limits =
                    x: viewBox.x - horizontalSizeIncrement
                    y: viewBox.y - verticalSizeIncrement
                    x2: viewBox.width + horizontalSizeIncrement
                    y2: viewBox.height + verticalSizeIncrement


            opts.reset = ->
                inivb= @initialViewBox
                @setViewBox(inivb.x, inivb.y, inivb.width, inivb.height, 0)
                return
            opts.getViewBox = ->
                return $.extend({}, viewBox)

            $animationDiv = $("<div></div>")
            firstAnimation = true
            opts.setViewBox = (x, y, width, height, animationTime= @animationTime) ->
                if animationTime > 0 && firstAnimation
                    firstAnimation = false
                    $animationDiv.css
                        left: viewBox.x + "px"
                        top: viewBox.y + "px"
                        width: viewBox.width + "px"
                        height: viewBox.height + "px"

                viewBox =
                    x: if x? then x else viewBox.x
                    y: if y? then y else viewBox.y
                    width: if width then width else viewBox.width
                    height: if height then height else viewBox.height
                viewBox= checkLimits(viewBox, @limits)

                #can't use $.attr because in SVG attributes are case-sensitive and jQuery lowercases the attribute names
                if animationTime > 0
                    #.animate() animates CSS rules, but we are changing the tag attributes
                    #so we instead animate this div that is not inside the DOM
                    #in the step callback of the animate function we set the viewBox on the svg
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
                                @.$svg[0].setAttribute("viewBox", "#{ $div.css("left")[0..-3] } #{ $div.css("top")[0..-3] } #{ $div.css("width")[0..-3] } #{ $div.css("height")[0..-3] }")
                                return
                            ).bind(@)
                else
                    @$svg[0].setAttribute("viewBox", "#{ viewBox.x } #{ viewBox.y } #{ viewBox.width } #{ viewBox.height }")
                return


            opts.panLeft = (amount= @panFactor, animationTime= @animationTime) ->
                @panRight(-amount, animationTime)
            opts.panRight = (amount= @panFactor, animationTime= @animationTime) ->
                @setViewBox(viewBox.x + amount, null, null, null, animationTime)
                return

            opts.panUp = (amount= @panFactor, animationTime= @animationTime) ->
                @panDown(-amount, animationTime)
            opts.panDown = (amount= @panFactor, animationTime= @animationTime) ->
                @setViewBox(null, viewBox.y + amount, null, null, animationTime)
                return

            opts.zoomIn = (amount= @zoomFactor, animationTime= @animationTime) ->
                @zoomOut(-amount, animationTime)
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

            #binding events

            opts.$svg.dblclick ((ev) ->
                if opts.events.doubleClick != true
                    return
                ev.preventDefault()
                ev.stopPropagation()
                @zoomIn()
            ).bind(opts)

            #TODO detect presence of jquery-mousewheel plugin (soon it will merged to core jQuery)
            #use it instead of getting the delta from the original event
            #maybe use the mouse wheel delta as zoomFactor?
            opts.$svg.on "mousewheel", ((ev) ->
                delta = ev.originalEvent.wheelDeltaY
                if delta == 0 or opts.events.mouseWheel != true
                    return

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
                else
                    @zoomOut(undefined, 0)

                newMousePosition = getViewBoxCoordinatesFromEvent(@$svg[0], ev)

                newcenter =
                    x: oldcenter.x + (oldMousePosition.x - newMousePosition.x)
                    y: oldcenter.y + (oldMousePosition.y - newMousePosition.y)

                @setCenter(newcenter.x, newcenter.y)
                return
            ).bind(opts)

            dragStarted = false

            opts.$svg.on "mousedown touchstart", ((ev) ->
                if dragStarted #a drag operation is already happening
                    return
                dragStarted = true
                if opts.events.drag != true or ev.which == 3 #right click
                    return

                ev.preventDefault()
                ev.stopPropagation()

                initialViewBox = $.extend({}, viewBox)

                $body = $(window.document.body)
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

                    $body[0].removeEventListener("mousemove", mouseMoveCallback, true)
                    $body[0].removeEventListener("touchmove", mouseMoveCallback, true)
                    $body[0].removeEventListener("mouseup", mouseUpCallback, true)
                    $body[0].removeEventListener("touchend", mouseUpCallback, true)
                    $body[0].removeEventListener("touchcancel", mouseUpCallback, true)
                    $body[0].removeEventListener("mouseout", mouseUpCallback, true)

                    if @events.dragCursor?
                        $body.css("cursor", oldCursor)

                    dragStarted = false
                    return
                ).bind(opts)

                $body[0].addEventListener("mousemove", mouseMoveCallback, true)
                $body[0].addEventListener("touchmove", mouseMoveCallback, true)
                $body[0].addEventListener("mouseup", mouseUpCallback, true)
                $body[0].addEventListener("touchend", mouseUpCallback, true)
                $body[0].addEventListener("touchcancel", mouseUpCallback, true)
                $body[0].addEventListener("mouseout", mouseUpCallback, true)
            ).bind(opts)


            opts.setViewBox(vb.x, vb.y, vb.width, vb.height, 0)

            ret.push(opts)
            return

        if ret.length == 0
            return null
        if ret.length == 1
            return ret[0]
        else return ret
