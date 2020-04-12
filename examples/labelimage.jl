using ImageTrainer

# need to make this relative
path = joinpath(ENV["HOME"], "path to your dir")
imgpath = joinpath(path, "path to your image dir")
pathout = joinpath(path, "path where you want to put the labels in csv")
    
# make sure paths are there
ispath(pathout) ? true : mkpath(pathout)

# start annotating with square of 30 markersize
imagetrain(imgpath, pathout, '□', 30)

# confirm annotation with visualization
ImageTrainer.visualizelabel(joinpath(imgpath, "image of interest.jpg"), joinpath(pathout, "image of interest.csv"))
 

