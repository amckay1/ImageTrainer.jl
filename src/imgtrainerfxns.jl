function relay1(imgpath, pathout, markertype, markersize, x)
    x = x+ 1
    println("Next Image: $x")
    imagetrain(imgpath, pathout, markertype, markersize, x)
end

function imagetrain(imgpath, pathout, markertype, markersize)
    imgs = [f for f in readdir(imgpath) if occursin(".jpg", f)]
    x = Node(1)
    imgname = lift(p -> imgs[p], x)
    fullimgname = lift(p -> joinpath(imgpath, imgname.val), x)
    #csvpath = lift(p -> joinpath(pathout, p*".csv"), imgname)
    csvpath = lift(p -> joinpath(pathout, string(p[1:end-4], ".csv")), imgname)

    # first, load our image (need to make this an observable)
    img = lift(p -> load(p), fullimgname)

    # then, setup environment
    scene = image(img,scale_plot=false, show_axis = false)
    points = Node(Point2f0[])
    clicks = Node(Point2f0[(0,0)])
    text!(scene,imgname,textsize = 20, color = :black, position = (490.0, 590.1))

    #points[] = points[]

    on(events(scene).keyboardbuttons) do but
        if ispressed(but, Keyboard.s)
            println("saving to $(csvpath.val)")
            pout = map(p -> convert(Array{Float64}, p), points.val)
            pout = map(p -> permutedims(p[:,:], (2,1)), pout)
            pout = vcat(pout...)
            forout = hcat(pout, fill(markersize, size(points.val,1) ))
            writedlm(csvpath.val, forout, ',')
        end
        if ispressed(but, Keyboard.b)
            println("saving to $(csvpath.val)")
            pout = map(p -> convert(Array{Float64}, p), points.val)
            pout = map(p -> permutedims(p[:,:], (2,1)), pout)
            pout = vcat(pout...)
            forout = hcat(pout, fill(markersize, size(points.val,1) ))
            writedlm(csvpath.val, forout, ',')
            
            println("moving to next image")
            # need to bring up next image here
            x[] = to_value(x)+1
            clicks[] = Point2f0[(0,0)]
            points[] = Point2f0[]  
            # not there yet, might need to lift
            #img[] = load(imgname) 
        end

    end

    idx = Ref(0); dragstart = Ref(false); startpos = Base.RefValue(Point2f0(0))
    on(events(scene).mousedrag) do drag
        if ispressed(scene, Mouse.left) && ispressed(scene, Keyboard.left_shift)
            if drag == Mouse.down
                plot, _idx = Makie.mouse_selection(scene)
                idx[] = _idx; dragstart[] = true
                p = Point2f0(scene.events.mouseposition[])
                startpos[] = to_world(scene, p)
            elseif drag == Mouse.pressed && dragstart[] && checkbounds(Bool, points[], idx[])
                p = Point2f0(scene.events.mouseposition[])
                pos = to_world(scene, p)
                points[][idx[]] = pos
                points[] = points[]
            end
        else
            dragstart[] = false
        end
    end

    on(events(scene).mousebuttons) do but
        if ispressed(but, Mouse.left) && ispressed(scene, Keyboard.left_control)
            p = Point2f0(scene.events.mouseposition[])
            pos = to_world(scene, p)
            push!(points[], pos)
            points[] = points[]
        elseif ispressed(but, Mouse.left) && ispressed(scene, Keyboard.left_alt)
            plot, idx = Makie.mouse_selection(scene)
            if checkbounds(Bool, points[], idx)
                deleteat!(points[], idx)
                points[] = points[]
            end
            #=
            elseif ispressed(but, Mouse.left)
            p = Point2f0(scene.events.mouseposition[])
            pos = to_world(scene, p)
            push!(clicks, push!(clicks[], pos))
            =#
        end
    end

    scatter!(scene, points, color = :red, marker = markertype, markersize = markersize)
    # left command + left mouse button adds, left mouse button + left alt removes, left mouse button + left shift drags  
end

function example()
    include(joinpath(@__DIR__, "..", "examples/example.jl"))
end

function visualizelabel(imgpath, imgcsv; box = true)
    img = load(imgpath)
    scene = image(img,scale_plot=false, show_axis = false)
    boxes = readdlm(imgcsv, ',')

    if box
        segs = []
        for i in 1:size(boxes, 1)
            row = boxes[i, :]
            blx = row[3]/2
            bly = row[3]/2
            push!(segs, Point2f0(row[1]-blx, row[2]-bly) => Point2f0(row[1]+blx, row[2]-bly))
            push!(segs, Point2f0(row[1]+blx, row[2]-bly) => Point2f0(row[1]+blx, row[2]+bly) )
            push!(segs, Point2f0(row[1]+blx, row[2]+bly) => Point2f0(row[1]-blx, row[2]+bly))
            push!(segs, Point2f0(row[1]-blx, row[2]+bly) => Point2f0(row[1]-blx, row[2]-bly) )
        end
        segs =convert(Array{Pair{Point{2,Float32},Point{2,Float32}},1}, segs)
        linesegments!(segs, color=:red, linewidth = 2)
    else
        for i in 1:size(boxes,1)
            row = boxes[i, :]
            println("test")
            scatter!(scene, [row[1] row[2]], markersize = 8, color = :red, marker= '+')
        end
    end
scene
end

#=
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
            lx = b[3]/2
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
=#
