from dataset import get_dataloaders, WIDTH, HEIGHT
from model import TrailNet, drone_loss
from torch.optim import Adam, SGD
from sklearn.metrics import classification_report, accuracy_score
import torch
from tqdm import tqdm
import torch.onnx
import onnx
import onnx_coreml
from pathlib import Path


DEVICE = "cuda"
EPOCHS = 50
input_shape = [1, 3, HEIGHT, WIDTH]


train_loader, val_loader = get_dataloaders()

model = TrailNet(input_shape).to(device=DEVICE)
optimizer = SGD(model.parameters(), lr=0.1)


# need to give a sensible name
def f(tensor):
    if tensor.is_cuda:
        tensor = tensor.cpu()
    if tensor.requires_grad:
        tensor = tensor.detach()

    return tensor


def val_loop(model, val_loader):
    position_pred = []
    orientation_pred = []

    position = []
    orientation = []

    for batch in val_loader:
        x = batch["image"].to(device=DEVICE)
        pos, ori = model(x)

        position_pred.append(f(pos))
        orientation_pred.append(f(ori))
        position.append(batch["position"])
        orientation.append(batch["orientation"])

    position_pred = torch.cat(position_pred)
    orientation_pred = torch.cat(orientation_pred)
    position = torch.cat(position)
    orientation = torch.cat(orientation)

    pos_acc = accuracy_score(position, position_pred.argmax(dim=1))
    ori_acc = accuracy_score(orientation, orientation_pred.argmax(dim=1))

    tqdm.write(
        f"| Position Accuracy: {pos_acc:2f} | Orientation Accuracy: {ori_acc:2f} |")


# training loop - needs checkpointing and to add visdom

desc = "Epoch: {epoch} | Loss: {loss:.2f} "

for epoch in range(EPOCHS):
    epoch_loss = 0
    with tqdm(initial=0, total=len(train_loader), desc=desc.format(epoch=0, loss=0)) as pbar:
        for batch in train_loader:

            optimizer.zero_grad()

            for k, v in batch.items():
                batch[k] = v.to(device=DEVICE)

            x = batch["image"]

            position, orientation = model(x)

            position_loss = drone_loss(position, batch["position"])
            orientation_loss = drone_loss(orientation, batch["orientation"])

            loss = position_loss + orientation_loss
            loss.backward()
            optimizer.step()

            epoch_loss += float(loss)
            pbar.update(1)
            pbar.desc = desc.format(epoch=epoch, loss=epoch_loss)
        # valdation loop - need to add visdom
        val_loop(model, val_loader)


def save_model(model, model_bin):

    dummy_input = torch.randn(10, 3, HEIGHT, WIDTH).to(device=DEVICE)
    torch.onnx.export(model, dummy_input,
                      model_bin/"model.onnx", export_params=True)
    model = onnx.load(model_bin/"model.onnx")
    coreml = onnx_coreml.convert(model, add_custom_layers=True)
    coreml.save(model_bin/"model.mlmodel")


model_bin = Path("model_bin")
save_model(model, model_bin)
