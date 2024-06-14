SystemVerilog CNN Accelerator
=============================

File Heirarchy
--------------

 - `proposal` contains the LaTeX source for the initial project proposal.
 - `presentation` contains the LaTeX source for the slides.
 - `train` contains the Python code used to train the model, then extract and
   convert its weights.
 - `verilog` contains the source files and corresponding testbench files for the
   accelerator itself.


Current Project State
---------------------

 - An issue with `yosys` and `$readmemb` is preventing the weight files from
   being loaded during synthesis.
 - Branch `main` implements a model for the CIFAR10 dataset, while branch
  `mnist` implements a model for the MNIST dataset.
	 - The underlying Verilog is the same in both with the exception of
	   adjustments to the top module for differently sized weight files.
