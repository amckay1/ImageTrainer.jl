function add_remove_add!(scene, points, pplot,clicks)
    on(events(scene).mousebuttons) do but
        if ispressed(but, Mouse.left) && ispressed(scene, Keyboard.left_control)
            pos = to_world(scene, Point2f0(events(scene).mouseposition[]))
            push!(points[], pos)
            points[] = points[]
        elseif ispressed(but, Mouse.left) && ispressed(scene, Keyboard.left_alt)
            plot, idx = Makie.mouse_selection(scene)
            if checkbounds(Bool, points[], idx)#plot == pplot && checkbounds(Bool, points[], idx)
                deleteat!(points[], idx)
                points[] = points[]
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
                idx[] = _idx; dragstart[] = true
                startpos[] = to_world(scene, Point2f0(scene.events.mouseposition[]))
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

function imagetrain(imgpath, pathout, markertype)
    imgname = split(split(imgpath, '/')[end], '.')[1]
    csvpath = joinpath(pathout, imgname*".csv")
    # first, load our image
    img = load(imgpath)

    # then, setup environment
    # http://makie.juliaplots.org/stable/examples-interaction.html
    i1 = image(img, show_axis = false);
    points = Node(Point2f0[])
    clicks = Node(Point2f0[(0,0)])
    
    pplot = i1

    points[] = points[]

    # buttons for output and slider for square size
    nextimg= button(raw = true, camera = campixel!, "Next Image")
    saveout = button(raw = true, camera = campixel!, "Save Annotations")
    markerb = button(raw = true, camera = campixel!, "Change Marker")
    s1 = slider(LinRange(1, 1000, 1000), raw = true, camera = campixel!, start = 300)

    on(nextimg[end][:clicks]) do c
        # need to bring up next image here
        println("clicked Next Image")
    end

    on(saveout[end][:clicks]) do c
        println("saving to $csvpath")
        pout = map(p -> convert(Array{Float64}, p), points.val)
        pout = map(p -> permutedims(p[:,:], (2,1)), pout)
        pout = vcat(pout...)
        forout = hcat(pout, fill(s1[end][:value].val, size(points.val,1) ))
        writedlm(csvpath, forout, ',')
    end

    add_move!(i1, points, pplot)
    add_remove_add!(i1, points, pplot, clicks)
    scatter!(i1, points, color = :red, marker = markertype, markersize = s1[end][:value])
    # left command + left mouse button adds, left mouse button + left alt removes, left mouse button + left shift drags  
    RecordEvents(hbox(i1, vbox(nextimg, saveout, s1),  parent = Scene(resolution = (1000,1000))), pathout)
end

function example()
    include(joinpath(@__DIR__, "..", "examples/example.jl"))
end

function visualizelabel(imgpath, imgcsv)
    img = load(imgpath)
    scene = image(img, show_axis = false)
    boxes = readdlm(imgcsv, ',')
    #segs = Array{Pair{Point{2,Float32},Point{2,Float32}},1}[]
    segs = []
    for i in 1:size(boxes, 1)
        row = boxes[i, :]
        blx = row[3]/4
        bly = row[3]/2
        push!(segs, Point2f0(row[1]-blx, row[2]-bly) => Point2f0(row[1]+blx, row[2]-bly))
        push!(segs, Point2f0(row[1]+blx, row[2]-bly) => Point2f0(row[1]+blx, row[2]+bly) )
        push!(segs, Point2f0(row[1]+blx, row[2]+bly) => Point2f0(row[1]-blx, row[2]+bly))
        push!(segs, Point2f0(row[1]-blx, row[2]+bly) => Point2f0(row[1]-blx, row[2]-bly) )
    end
    segs =convert(Array{Pair{Point{2,Float32},Point{2,Float32}},1}, segs)
    linesegments!(segs, color=:red, linewidth = 2)
end

function createtestset(imgpath, imgcsv, samplesize)
    # going to say what is pos_label, what is neg_label, and what is labeless
    # first, randomly sample the image:
    img = load(imgpath)
    imgsamples = Array{Point2f0}(undef, samplesize)
    for i in 1:samplesize
        imgsamples[i] = Point2f0(rand(1:size(img, 1)), rand(1:size(img,2)))
    end
    
    # second, read boxes from file
    boxes = readdlm(imgcsv, ',')

    labels = [] # 0 is non, 1 is inbetween, 2 is pos
    buffer = 2

    # loop through samples and label
    for p in imgsamples
        # is in box?
        l = false
        for b in eachrow(boxes)
            x = b[1]
            y = b[2]
            lx = b[3]/4
            ly = b[3]/2
            if x-lx < p[1] < x+lx  && y-ly < p[2] < y+ly
                push!(labels, 2)
                l = true
                break
            end
        end
        if l == false
            push!(labels, 0)
        end
    end
    return hcat(imgsamples, labels)
end

function visualizelabels(imgpath, labels)
    img = load(imgpath)
    scene = image(img, show_axis = false)
    lx= map(p -> p[1], labels[:,1])
    ly= map(p -> p[2], labels[:,1])
    #lc = replace(labels[:, 2], 0 => :black, 2 => :red)
    lc = convert(Array{Float64}, labels[:,2])
    lc = replace(lc, 0.0 => 0.4, 2.0 => 0.9)
    scatter!(lx, ly, color = lc, markersize = 2)

end
