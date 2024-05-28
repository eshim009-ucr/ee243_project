#!/usr/bin/env python3

"""
Extracts the weights from a the pretrained MobileNetv2 model from TorchVision
and dumps them in a JSON file.
"""

from sys import argv
import json
import torch

model = torch.hub.load('pytorch/vision:v0.10.0', 'mobilenet_v2', pretrained=True)
model.eval()

outfile = argv[1] if len(argv) > 1 else "weights.json"
with open(outfile, "w") as fout:
	outjson = {}
	for key, val in model.state_dict().items():
		print(f"Parsing {key}...")
		outjson[key] = val.numpy().tolist()
	json.dump(outjson, fp=fout, indent='\t')

print("Done!")
