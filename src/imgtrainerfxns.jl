function imagetrain(imgpath, pathout)
    # first, load our image
    # imgpath = "/Users/am/Dropbox/imagetrainertest/test.tif"
    # pathout = "/Users/am/Dropbox/imagetrainertest/testoutput/test.csv"
    img = load(imgpath)

    # then, setup environment
    # http://makie.juliaplots.org/stable/examples-interaction.html
    #scene = Scene()#raw = true, camera = campixel!, resolution = (2500,1300))
    i1 = image(img);

    clicks = Node(Point2f0[(0,0)])
    on(i1.events.mousebuttons) do buttons
        if ispressed(i1, Mouse.left)
            pos = to_world(i1, Point2f0(i1.events.mouseposition[]))
            println(clicks)
            push!(clicks, push!(clicks[], pos))
        end
        return
     end

    #t = Theme(raw = true, camera = campixel!, resolution = (2500,1300))
    nextimg= button(raw = true, camera = campixel!, "Next Image")
    saveout = button(raw = true, camera = campixel!, "Save Annotations")


    on(nextimg[end][:clicks]) do c
        println("")
        println("clicked Next Image")
         #p1[:color] = rand(RGBAf0)
    end

    on(saveout[end][:clicks]) do c
        println("saving to $pathout")
         writedlm(pathout, clicks.val, ',')
         #p2[:marker] = markers[rand(1:5)]
    end

    scatter!(i1, clicks, color = :red, marker = '+', markersize = 50)
    RecordEvents(hbox(i1, vbox(nextimg, saveout),  parent = Scene(resolution = (500,500))), pathout)
end
