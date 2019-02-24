import torchvision.models as models
import torch
import torch.nn as nn
from einops.layers.torch import Rearrange, Reduce
from torch.utils.data import DataLoader
import torch.nn.functional as F
from functools import reduce
import operator


# Should rewrite the resnet backbone to replace the ReLU and batch norm with ELUs
# since this would help to reduce the computation.
class TrailNet(nn.Module):

    def __init__(self, input_shape):
        super(TrailNet, self).__init__()
        resnet18 = models.resnet18()

        backbone = nn.Sequential(
            # remove last fully connected layer and avg pooling
            *list(resnet18.children())[:-2],
            nn.AvgPool2d(kernel_size=6),
            # not supported by onnx...have to reshape in forward method
            # Rearrange("b n w h -> b (n w h)")
        )
        self.backbone = backbone

        backbone_output_shape = backbone(torch.rand(input_shape)).size(1)

        self.position_head = nn.Sequential(
            nn.Linear(backbone_output_shape, 200),
            nn.Linear(200, 3)
        )
        self.orientation_head = nn.Sequential(
            nn.Linear(backbone_output_shape, 200),
            nn.Linear(200, 3),
        )

    def forward(self, x):

        x = self.backbone(x)
        # must squeeze here since reshape not supported
        x = x.squeeze(-1).squeeze(-1)
        position, orientation = self.position_head(x), self.orientation_head(x)
        return F.softmax(position, dim=1), F.softmax(orientation, dim=1)


def drone_loss(input, target):
    return F.cross_entropy(input, target)
