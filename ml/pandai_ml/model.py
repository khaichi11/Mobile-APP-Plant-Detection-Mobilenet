"""Model definitions."""

import torch
from torch import nn
from torchvision import models

from .data import MEAN, STD

ARCHITECTURES = ("mobilenet_v3_small", "mobilenet_v3_large")


def build_model(num_classes: int, arch: str = "mobilenet_v3_large", pretrained: bool = True) -> nn.Module:
    """A MobileNetV3 with a new classification head.

    MobileNet is small and fast enough to run on the cheap Android phones that
    many students use.
    """
    if arch not in ARCHITECTURES:
        raise ValueError(f"Unknown architecture {arch!r}, use one of {ARCHITECTURES}")
    weights = None
    if pretrained:
        weights = (
            models.MobileNet_V3_Large_Weights.IMAGENET1K_V2
            if arch == "mobilenet_v3_large"
            else models.MobileNet_V3_Small_Weights.IMAGENET1K_V1
        )
    model = getattr(models, arch)(weights=weights)
    last = model.classifier[-1]
    model.classifier[-1] = nn.Linear(last.in_features, num_classes)
    return model


class AppModel(nn.Module):
    """Wraps a trained model with the input and output the app expects.

    Input: float32 NHWC images with values between 0 and 1.
    Output: class probabilities.
    """

    def __init__(self, model: nn.Module):
        super().__init__()
        self.model = model
        self.register_buffer("mean", torch.tensor(MEAN).view(1, 3, 1, 1))
        self.register_buffer("std", torch.tensor(STD).view(1, 3, 1, 1))

    def forward(self, images: torch.Tensor) -> torch.Tensor:
        x = images.permute(0, 3, 1, 2)
        x = (x - self.mean) / self.std
        return torch.softmax(self.model(x), dim=1)
