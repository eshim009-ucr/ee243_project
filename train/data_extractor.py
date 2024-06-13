#!/usr/bin/env python3

import numpy as np
import torch
import torchvision
import torchvision.transforms as transforms
import pathlib
from weight_compiler import bytes_to_coe, float_to_fixed


transform = transforms.Compose([
	transforms.Resize(32),
	transforms.ToTensor(),
	transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))
])

trainset = torchvision.datasets.CIFAR10(
	root='./data', train=True,
	download=True, transform=transform
)
trainloader = torch.utils.data.DataLoader(
	trainset
)

testset = torchvision.datasets.CIFAR10(
	root='./data', train=False,
	download=True, transform=transform
)
testloader = torch.utils.data.DataLoader(
	trainset
)


def write_set(dataset, dataloader, train, int_bits=4, frac_bits=4):
	stage_str = "train" if train else "test"
	print(f"Writing {stage_str}ing data...")
	pathlib.Path(f"{stage_str}_data").mkdir(exist_ok=True)
	for i, entry in enumerate(dataloader, 0):
		# get the inputs
		data, label = entry
		np_data = float_to_fixed(data.numpy(), int_bits, frac_bits)
		# Reorder axes so indices match expected
		np_data = np.transpose(np_data, (2, 3, 1, 0))
		binary_data = np_data.tobytes()
		with open(f"{stage_str}_data/i{i}_l{int(label)}.coe", "w") as fout:
			fout.write(bytes_to_coe(binary_data))
		if i % 1000 == 999:
			print(f"\t{(i+1)/len(dataset):0.1f}%")
	print("Done!")

write_set(testset, testloader, False)
write_set(trainset, trainloader, True)
