import csv
import json

import pytest
import torch
from PIL import Image

from pandai_ml.data import eval_transform, make_loaders, write_labels
from pandai_ml.export import load_app_model
from pandai_ml.model import AppModel, build_model
from pandai_ml.train import accuracy, parse_args, train

SPECIES = ["Carica papaya", "Helianthus annuus", "Mimosa pudica"]


@pytest.fixture()
def tiny_dataset(tmp_path):
    colors = [(200, 30, 30), (30, 200, 30), (30, 30, 200)]
    for split, count in (("train", 6), ("val", 2)):
        for name, color in zip(SPECIES, colors):
            folder = tmp_path / split / name
            folder.mkdir(parents=True)
            for i in range(count):
                Image.new("RGB", (48 + i, 40), color).save(folder / f"{i}.jpg")
    return tmp_path


def test_model_has_one_output_per_species():
    model = build_model(len(SPECIES), "mobilenet_v3_small", pretrained=False).eval()
    assert model(torch.rand(2, 3, 64, 64)).shape == (2, len(SPECIES))


def test_unknown_architecture_is_rejected():
    with pytest.raises(ValueError):
        build_model(3, "resnet9000", pretrained=False)


def test_app_model_takes_nhwc_and_returns_probabilities():
    app = AppModel(build_model(len(SPECIES), "mobilenet_v3_small", pretrained=False)).eval()
    probs = app(torch.rand(2, 64, 64, 3))
    assert probs.shape == (2, len(SPECIES))
    assert torch.allclose(probs.sum(dim=1), torch.ones(2), atol=1e-5)


def test_labels_use_the_app_format(tmp_path):
    path = tmp_path / "labels.csv"
    write_labels(path, SPECIES)
    rows = list(csv.reader(path.open()))
    assert rows[0] == ["id", "name"]
    assert rows[1:] == [[str(i), name] for i, name in enumerate(SPECIES)]


def test_eval_transform_crops_to_a_square():
    tensor = eval_transform(32)(Image.new("RGB", (80, 40)))
    assert tensor.shape == (3, 32, 32)


def test_loaders_find_every_species(tiny_dataset):
    train_loader, val_loader, classes = make_loaders(tiny_dataset, batch_size=4, size=32, workers=0)
    assert classes == SPECIES
    images, targets = next(iter(train_loader))
    assert images.shape[1:] == (3, 32, 32)
    assert len(val_loader.dataset) == 6


def test_accuracy_counts_hits():
    logits = torch.tensor([[0.1, 0.9, 0.0], [0.8, 0.1, 0.1]])
    targets = torch.tensor([1, 2])
    assert accuracy(logits, targets, 1) == 1
    assert accuracy(logits, targets, 5) == 2


def test_training_writes_a_checkpoint_labels_and_metrics(tiny_dataset, tmp_path):
    out = tmp_path / "run"
    args = parse_args([
        "--data-dir", str(tiny_dataset), "--output", str(out), "--epochs", "1",
        "--batch-size", "4", "--image-size", "32", "--workers", "0",
        "--arch", "mobilenet_v3_small", "--no-pretrained",
    ])
    best = train(args)
    assert 0 <= best["val_top1"] <= 1
    assert (out / "best.pt").exists()
    assert json.loads((out / "metrics.json").read_text())["epoch"] == 1
    assert (out / "plant_labels.csv").read_text().splitlines()[1] == "0,Carica papaya"

    app_model, data = load_app_model(out / "best.pt")
    assert data["classes"] == SPECIES
    assert app_model(torch.rand(1, 32, 32, 3)).shape == (1, 3)
