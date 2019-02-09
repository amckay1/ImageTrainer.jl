function add_remove_add!(scene, points, pplot,clicks)
    on(events(scene).mousebuttons) do but
        if ispressed(but, Mouse.left) && ispressed(scene, Keyboard.left_control)
            pos = to_world(scene, Point2f0(events(scene).mouseposition[]))
            push!(points[], pos)
            points[] = points[]
        elseif ispressed(but, Mouse.left) && ispressed(scene, Keyboard.left_alt)
            plot, idx = Makie.mouse_selection(scene)
            if checkbounds(Bool, points[], idx)#plot == pplot && checkbounds(Bool, points[], idx)
                #println(typeof(points[]))
                #println(length(points[]))
                deleteat!(points[], idx)
                points[] = points[]
                #println(length(points[]))
            end
        elseif ispressed(but, Mouse.left)
            pos = to_world(scene, Point2f0(events(scene).mouseposition[]))
            push!(clicks, push!(clicks[], pos))
         end
    end
    return
end

function add_move!(scene, points, pplot)
    idx = Ref(0); dragstart = Ref(false); startpos = Base.RefValue(Point2f0(0))
    on(events(scene).mousedrag) do drag
        if ispressed(scene, Mouse.left) && ispressed(scene, Keyboard.left_shift)
            if drag == Mouse.down
                plot, _idx = Makie.mouse_selection(scene)
                println(_idx)
                #if plot == pplot
                    idx[] = _idx; dragstart[] = true
                    startpos[] = to_world(scene, Point2f0(scene.events.mouseposition[]))
                #end
            elseif drag == Mouse.pressed && dragstart[] && checkbounds(Bool, points[], idx[])
                pos = to_world(scene, Point2f0(scene.events.mouseposition[]))
                points[][idx[]] = pos
                points[] = points[]
            end
        else
            dragstart[] = false
        end
    end
    return
end

function imagetrain(imgpath, pathout)
    # first, load our image
    img = load(imgpath)

    # then, setup environment
    # http://makie.juliaplots.org/stable/examples-interaction.html
    i1 = image(img);
    points = Node(Point2f0[])
    clicks = Node(Point2f0[(0,0)])
    
    pplot = i1

    points[] = points[]

    nextimg= button(raw = true, camera = campixel!, "Next Image")
    saveout = button(raw = true, camera = campixel!, "Save Annotations")
    on(nextimg[end][:clicks]) do c
        println("")
        println("clicked Next Image")
    end

    on(saveout[end][:clicks]) do c
        println("saving to $pathout")
        println(points.val)
        println(length(points.val))
        #writedlm(pathout, points.val, ',')
    end

    add_move!(i1, points, pplot)
    add_remove_add!(i1, points, pplot, clicks)
    scatter!(i1, points, color = :red, marker = '+', markersize = 50)
    # left command + left mouse button adds, left mouse button + left alt removes, left mouse button + left shift drags  
    RecordEvents(hbox(i1, vbox(nextimg, saveout),  parent = Scene(resolution = (1000,1000))), pathout)
end
