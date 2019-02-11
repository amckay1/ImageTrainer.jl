# ImageTrainer

## Objective
Create a GUI for annotating images for downstream ML approaches

## Quickstart
1. add this package using Julia v1.1 Pkg manager
2. run "using ImageTrainer" then "ImageTrainer.example()" to annotate an example tif file
3. Once image is open (takes 20 seconds currently):
    * Add marker by left clicking with the left command button
    * Move the marker by left clicking with the left shift button
    * Remove the marker by left clicking with the left alt button
    * Use the slider above to change the size of the marker/bounding box
4. When done, click on the "Save Annotations" button to save to the predefined "pathout"

## To Do
* Change the marker by button press
* When opening a directory, the "Next Image" button will move to the next image in the directory, or a sampled subset
* Allow for multiple markers/types
* Save data with more informative csv and annotated images.
* Improve slow startup time: "IMKClient Stall detected" issue
