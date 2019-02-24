import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import pathlib
from einops import rearrange
from torch.utils.data import Dataset, DataLoader
import torch
from skimage import io, transform
from tqdm import tqdm


# Globals
WIDTH = 1080 // 6
HEIGHT = 1920 // 6


def read_image(path, dtype='float32'):
    img = io.imread(path)
    img = transform.resize(img, (HEIGHT, WIDTH), mode='constant')
    img = rearrange(img, "w h c -> c w h")
    return img.astype(dtype) / 255


class DroneDataset(Dataset):
    def __init__(self, root_dir, resize=None):
        l = []
        pic_folder = pathlib.Path(root_dir)
        pics = pic_folder.glob("*")

        for folder in pics:
            for pic in folder.glob("*"):
                position, orientation = folder.stem.split("-")
                d = {"path": str(pic),
                     "position": position,
                     "orientation": orientation
                     }
                l.append(d)

        label2idx = {"center": 1, "left": 0, "right": 2}
        df = pd.DataFrame.from_dict(l)
        df.position = df.position.map(label2idx)
        df.orientation = df.orientation.map(label2idx)
        tqdm.pandas(desc="Loading images into dataloader")
        df["image"] = df.path.progress_apply(read_image)

        self.root_dir = root_dir
        self.transform = transform  # should do the resizing
        self.df = df
        self.resize = resize

    def __len__(self):
        return len(self.df)

    def __getitem__(self, idx):

        image, position, orientation = self.df.loc[idx, [
            "image", "position", "orientation"]]
        sample = {'image': image, 'position': position,
                  "orientation": orientation}

        return sample


# New to handle train test split properly
def get_dataloaders():
    drone_dataset = DroneDataset("/home/dom/Videos/drone/pics/")
    dataloader = DataLoader(drone_dataset, batch_size=64,
                            shuffle=False, num_workers=4)
    return dataloader, dataloader
