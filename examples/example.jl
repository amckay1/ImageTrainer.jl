using ImageTrainer

# need to make this relative
imgpath = joinpath(@__DIR__, "test.tif")
pathout = joinpath(@__DIR__, "testout/test.csv")

imagetrain(imgpath, pathout, '□')
    
