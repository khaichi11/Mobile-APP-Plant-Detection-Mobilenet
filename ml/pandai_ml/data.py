"""Datasets and image transforms.

The dataset is a folder per split with one sub-folder per species:

    data/train/Helianthus annuus/001.jpg
    data/val/Helianthus annuus/014.jpg
"""

from pathlib import Path

import torch
from torch.utils.data import DataLoader
from torchvision import datasets, transforms

IMAGE_SIZE = 224
MEAN = (0.485, 0.456, 0.406)
STD = (0.229, 0.224, 0.225)


def train_transform(size: int = IMAGE_SIZE):
    """Augmentations that mimic photos taken outdoors by children."""
    return transforms.Compose([
        transforms.RandomResizedCrop(size, scale=(0.5, 1.0)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(15),
        transforms.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.3),
        transforms.ToTensor(),
    ])


def eval_transform(size: int = IMAGE_SIZE):
    """Center crop, like the app does before classifying."""
    return transforms.Compose([
        transforms.Resize(size),
        transforms.CenterCrop(size),
        transforms.ToTensor(),
    ])


def make_loaders(data_dir: Path, batch_size: int, size: int = IMAGE_SIZE, workers: int = 2):
    """Returns the train and validation loaders and the class names."""
    train = datasets.ImageFolder(Path(data_dir) / "train", train_transform(size))
    val = datasets.ImageFolder(Path(data_dir) / "val", eval_transform(size))
    if train.classes != val.classes:
        raise ValueError("train/ and val/ must contain the same species folders")
    loader_args = {"batch_size": batch_size, "num_workers": workers, "pin_memory": torch.cuda.is_available()}
    return (
        DataLoader(train, shuffle=True, drop_last=len(train) > batch_size, **loader_args),
        DataLoader(val, shuffle=False, **loader_args),
        train.classes,
    )


def write_labels(path: Path, classes: list[str]) -> None:
    """Writes the label map in the `id,name` format the app reads."""
    lines = ["id,name"] + [f"{i},{name}" for i, name in enumerate(classes)]
    Path(path).write_text("\n".join(lines) + "\n", encoding="utf-8")
