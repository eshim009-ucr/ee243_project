#!/usr/bin/env python3

"""
Converts floating point weights from a JSON file into fixed point weights
"""

from sys import argv
from math import ceil
import os
import json
import numpy as np
import pathlib


def get_bit_range(bits):
	return (-(2 ** (bits-1)), (2 ** (bits-1)) - 1)

def find_split(weights, bits):
	# Calculate how to partition bits to capture most precision
	total_max = 0
	total_min = 0
	for layer, values in weights.items():
		npvals = np.array(values)

		local_min = np.min(npvals)
		local_max = np.max(npvals)
		if local_min < total_min:
			total_min = local_min
		if local_max > total_max:
			total_max = local_max

		print(f"\t{layer} has shape {npvals.shape} and range {local_min:0.2f} to {local_max:0.2f}")

	print(f"Overall range of data is {total_min:0.2f} to {total_max:0.2f}")

	# Calculate split point
	int_bits = None
	for i in range(bits):
		n_min, n_max = get_bit_range(i)
		if int(total_min) > n_min and int(total_max) < n_max:
			int_bits = i+1
			break
	if int_bits == None:
		print(f"Not enough bits ({bits}) to store maximum range")
		exit(1)
	print(f"Integer portion will use {int_bits} bits to capture range {n_min} to {n_max}")
	frac_bits = bits - int_bits
	print(f"Fraction portion use {frac_bits} bits to capture maximum precision of {2**(-frac_bits)}")

	return int_bits, frac_bits


def np_int_type(int_bits, frac_bits):
	bits = ceil((int_bits + frac_bits) / 8) * 8
	if bits == 8:
		return np.int8
	elif bits == 16:
		return np.int16
	elif bits == 32:
		return np.int32
	elif bits == 64:
		return np.int64
	elif bits == 128:
		return np.int128
	else:
		print(f"Needs too many ({bits}) bits")
		exit(1)

def float_to_fixed(floating, int_bits, frac_bits):
	np_floating = np.array(floating)
	shape = np_floating.shape
	dtype = np_int_type(int_bits, frac_bits)
	scale = 2 ** int_bits

	np_floating = np_floating.flatten()
	np_fixed = np.zeros_like(np_floating, dtype=dtype)
	err = np.zeros_like(np_floating)
	
	for i in range(len(np_floating)):
		np_fixed[i] = round(np_floating[i] * scale)
		err[i] = np.abs((np.float64(np_fixed[i])/scale) - np_floating[i])
	print(f"\tMaximum error was {np.max(err):0.3f}")
	print(f"\tTotal error was {np.sum(err):0.2f}")
	print(f"\tAverage error was {np.sum(err)/len(np_floating):0.2f}")

	return np_fixed.reshape(shape)


def bytes_to_coe(byte_arr):
	lines = ""
	for i in range(ceil(len(byte_arr)/4)):
		b = None
		if (i+1)*4 <= len(byte_arr):
			b = byte_arr[i*4 : (i+1)*4]
		else:
			b = bytearray(byte_arr[i*4 : len(byte_arr)])
			while len(b) < 4:
				b.append(0)
		n = int.from_bytes(b)
		lines += f"{n:0{32}b}\n"
	return lines

def compile_weights(infile="weights.json", bits=8):
	print(f"Loading weight file {infile}...")
	weights = None
	with open(infile) as fin:
		weights = json.load(fin)
	print("Done!")
	
	int_bits, frac_bits = find_split(weights, bits)
	
	print("Writing to new files...")
	pathlib.Path("fixed_weights").mkdir(exist_ok=True)
	total_bytes = 0
	for layer, values in weights.items():
		print(f"Converting {layer}...")
		with open(f"fixed_weights/{layer}.coe", "w") as fout:
			binary_weights = float_to_fixed(values, int_bits, frac_bits).tobytes()
			total_bytes += len(binary_weights)
			fout.write(bytes_to_coe(binary_weights))
	print(f"{total_bytes} bytes written in total")
	print("Done!")

if __name__ == "__main__":
	if len(argv) > 1:
		compile_weights(infile=argv[1])
	else:
		compile_weights()
