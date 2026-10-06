"""Fine-tune the plant classifier.

    python -m pandai_ml.train --data-dir data --epochs 15 --wandb

Weights & Biases logging is optional: pass --wandb and set WANDB_API_KEY.
"""

import argparse
import json
import math
import time
from pathlib import Path

import torch
from torch import nn

from .data import IMAGE_SIZE, make_loaders, write_labels
from .model import ARCHITECTURES, build_model


def accuracy(logits: torch.Tensor, targets: torch.Tensor, k: int) -> float:
    k = min(k, logits.shape[1])
    top = logits.topk(k, dim=1).indices
    return (top == targets.unsqueeze(1)).any(dim=1).float().sum().item()


def evaluate(model, loader, device):
    model.eval()
    loss_fn = nn.CrossEntropyLoss(reduction="sum")
    totals = {"loss": 0.0, "top1": 0.0, "top5": 0.0, "count": 0}
    with torch.no_grad():
        for images, targets in loader:
            images, targets = images.to(device), targets.to(device)
            logits = model(images)
            totals["loss"] += loss_fn(logits, targets).item()
            totals["top1"] += accuracy(logits, targets, 1)
            totals["top5"] += accuracy(logits, targets, 5)
            totals["count"] += targets.numel()
    count = max(totals["count"], 1)
    return {"val_loss": totals["loss"] / count, "val_top1": totals["top1"] / count, "val_top5": totals["top5"] / count}


def train(args) -> dict:
    torch.manual_seed(args.seed)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)

    train_loader, val_loader, classes = make_loaders(args.data_dir, args.batch_size, args.image_size, args.workers)
    model = build_model(len(classes), args.arch, pretrained=not args.no_pretrained).to(device)
    optimizer = torch.optim.AdamW(model.parameters(), lr=args.lr, weight_decay=1e-4)
    steps = max(1, args.epochs * len(train_loader))
    scheduler = torch.optim.lr_scheduler.LambdaLR(
        optimizer, lambda step: 0.5 * (1 + math.cos(math.pi * min(step, steps) / steps))
    )
    loss_fn = nn.CrossEntropyLoss(label_smoothing=0.1)

    run = None
    if args.wandb:
        import wandb

        run = wandb.init(project=args.wandb_project, config=vars(args) | {"classes": len(classes)})

    write_labels(output / "plant_labels.csv", classes)
    best = {"val_top1": -1.0}
    for epoch in range(1, args.epochs + 1):
        model.train()
        started, seen, running = time.time(), 0, 0.0
        for images, targets in train_loader:
            images, targets = images.to(device), targets.to(device)
            optimizer.zero_grad()
            loss = loss_fn(model(images), targets)
            loss.backward()
            optimizer.step()
            scheduler.step()
            running += loss.item() * targets.numel()
            seen += targets.numel()
        metrics = {"epoch": epoch, "train_loss": running / max(seen, 1), **evaluate(model, val_loader, device)}
        metrics["seconds"] = round(time.time() - started, 1)
        print(json.dumps(metrics))
        if run is not None:
            run.log(metrics)
        if metrics["val_top1"] > best["val_top1"]:
            best = metrics
            torch.save(
                {"arch": args.arch, "classes": classes, "image_size": args.image_size, "state_dict": model.state_dict()},
                output / "best.pt",
            )
    (output / "metrics.json").write_text(json.dumps(best, indent=2) + "\n")
    if run is not None:
        run.summary.update(best)
        run.finish()
    return best


def parse_args(argv=None):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--data-dir", type=Path, required=True)
    parser.add_argument("--output", type=Path, default=Path("runs/latest"))
    parser.add_argument("--arch", choices=ARCHITECTURES, default="mobilenet_v3_large")
    parser.add_argument("--epochs", type=int, default=15)
    parser.add_argument("--batch-size", type=int, default=32)
    parser.add_argument("--lr", type=float, default=1e-3)
    parser.add_argument("--image-size", type=int, default=IMAGE_SIZE)
    parser.add_argument("--workers", type=int, default=2)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--no-pretrained", action="store_true", help="Start from random weights")
    parser.add_argument("--wandb", action="store_true", help="Log the run to Weights & Biases")
    parser.add_argument("--wandb-project", default="pandai-plant-classifier")
    return parser.parse_args(argv)


if __name__ == "__main__":
    train(parse_args())
