"""Export a trained checkpoint to TensorFlow Lite for the app.

    python -m pandai_ml.export --checkpoint runs/latest/best.pt --output runs/latest

Copy plant_classifier.tflite and plant_labels.csv into assets/models/ to ship
the new model. The app detects the float input automatically.
"""

import argparse
from pathlib import Path

import torch

from .data import write_labels
from .model import AppModel, build_model


def load_app_model(checkpoint: Path) -> tuple[AppModel, dict]:
    data = torch.load(checkpoint, map_location="cpu")
    model = build_model(len(data["classes"]), data["arch"], pretrained=False)
    model.load_state_dict(data["state_dict"])
    return AppModel(model).eval(), data


def export(checkpoint: Path, output: Path) -> Path:
    import ai_edge_torch

    app_model, data = load_app_model(checkpoint)
    size = data["image_size"]
    sample = (torch.rand(1, size, size, 3),)
    edge_model = ai_edge_torch.convert(app_model, sample)
    output.mkdir(parents=True, exist_ok=True)
    target = output / "plant_classifier.tflite"
    edge_model.export(str(target))
    write_labels(output / "plant_labels.csv", data["classes"])
    return target


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--checkpoint", type=Path, required=True)
    parser.add_argument("--output", type=Path, default=Path("runs/latest"))
    args = parser.parse_args()
    print(f"Wrote {export(args.checkpoint, args.output)}")
