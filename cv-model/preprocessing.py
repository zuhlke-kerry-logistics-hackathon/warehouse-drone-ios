import pathlib
import subprocess
from tqdm import tqdm


path = pathlib.Path("/home/dom/Videos/drone")
vid_folder = path/"videos"
pic_folder = path/"pics"

if not pic_folder.is_dir():
    pic_folder.mkdir()

labels = ["center", "left", "right"]

for i in labels:
    for j in labels:
        # position-orientation
        p = pic_folder/f"{i}-{j}"
        if not p.is_dir():
            p.mkdir()


vids = list(vid_folder.glob("*.MP4"))
pics = list(pic_folder.glob("*"))
vids.sort(key=lambda x: x.stem)
pics.sort(key=lambda x: x.stem)
fps = 0.5

for (vid, folder) in tqdm(zip(vids, pics), total=9, desc="Converting videos into pictures"):
    # should really output images at a smaller resolution
    cmd = f"ffmpeg -i {str(vid)} -vf fps={fps} {str(folder)}/out%d.png"
    process = subprocess.Popen(cmd.split(), stderr=subprocess.DEVNULL)
    output, error = process.communicate()
