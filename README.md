# Micro-architecture modification in RTL for RISC-V
![Schematic](/RV32i_forwarding.drawio.png "Schematic")
This project modifies and enhance an existing structural model of a single-issue 5-stage RISC-V processor in order to improve its performance. 
## Acknowledgement
The baseline processor design is provided by RipperJ, and can be found at [https://github.com/RipperJ/RISC-V_CPU/tree/main/RV32i](https://github.com/RipperJ/RISC-V_CPU/tree/main/RV32i). 
## Modifications
### Data forwarding	
To remove data hazards and impreove performance of the processor, data forwarding optimization is implemented. 
The optimization forwards operands that are not yet commited to the registers to the inputs of ALU or data_out port at execution state.
Data stalls due to data hazards are minimized, with only load-use hazard causing a one-cycle clock stall. 
#### List of changes
* Modified module data_stall so that it only stalls with load-use hazards
* Added forwarding_unit
* Modified processor module to accomodate the above changes
### Branch prediction
Branch prediction is implemented in order to remove control hazards of conditional branches.
Branches are predicted to be always not taken.
When branch is resolved as taken at execution stage, the processor flushes and fallbacks to the correct instruction. 
#### List of changes
* Replaced module MUX5 for chosing next PC with module next_PC
* Modified module control_unit so that it no longer handles branch-resolving
* Added module branch_verification, which takes over branch resolving and verification of prediciton
* Modified module control_stall, so it stalls correctly with jump instrcution as well as mispredicted branches
* Modified REG_ID_EXE to include branch_related signals, as well as ID_EXE_cstall
* Modified processor module to accomodate the above changes
#### Planned predictors
* Always taken predictor
* GLobal saturating counter predictor (2-bit & 3-bit)
* Smith's predictor
* Two-level correlating predictor
* GSHARE predictor
* TAGE and L-TAGE predictor
* Perceptron predictor

### Planned optimizations
* Tomasulo's algorithm (to be implemented)
* basic unsupported instrcutions (to be implemented)
* RISCV Vector Extension (to be implemented)
## Related project
[elec5140_project](https://github.com/146snk/elec5140_project): the original version of the project. As the original version has messy file and module structure, as well as inconsistent naming conventions, it is decided that this new project would be a revamp on the original project, solving the problems mentioned above to improved the ease of further development. 