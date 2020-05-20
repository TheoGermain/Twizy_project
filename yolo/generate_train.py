import os

image_files = []
for filename in os.listdir("obj"):
    if filename.endswith(".png"):
        print(filename)
        image_files.append("darknet/data/obj/" + filename)
#os.chdir("..")
with open("train.txt", "w") as outfile:
    for image in image_files:
        outfile.write(image)
        outfile.write("\n")
    outfile.close()
#os.chdir("..")
