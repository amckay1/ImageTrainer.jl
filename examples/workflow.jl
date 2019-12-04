using ImageTrainer

imgdir = joinpath(homedir(), "test")

pathout = joinpath(homedir(), "test/test.csv")


img = readdir(imgdir)[1]
imagetrain(joinpath(imgdir, img), pathout, '□')
for img in readdir(imgdir)
    if occursin(".png", img)
        imagetrain(joinpath(imgdir, img), pathout, '□')
    end
end

