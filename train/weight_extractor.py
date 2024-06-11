#!/usr/bin/env python3

"""
Extracts the weights from a the pretrained MobileNetv2 model from TorchVision
and dumps them in a JSON file.
"""

import json
import torch

def extract_weights(model=None, outfile="weights.json"):
	if model == None:
		model = torch.hub.load('pytorch/vision:v0.10.0', 'mobilenet_v2', pretrained=True)
		model.eval()

	with open(outfile, "w") as fout:
		outjson = {}
		for key, val in model.state_dict().items():
			print(f"Parsing {key}...")
			outjson[key] = val.numpy().tolist()
		json.dump(outjson, fp=fout, indent='\t')

	print("Done!")
