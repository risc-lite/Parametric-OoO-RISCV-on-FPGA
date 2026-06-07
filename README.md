
# Parametric Out-of-Order RISC-V Core (FPGA Implementation)

A fully synthesizable, parameter-driven Out-of-Order (OoO) RISC-V processor implementation tailored for FPGA hardware deployment. Built upon a custom **Instruction Scheduling Matrix (ISM)**, this microarchitecture eliminates traditional heavy branch tracking structures to achieve a minimal physical footprint while maintaining an aggressive peak IPC.

---

## 🚀 Hardware Performance & PPA Snapshot

The tracking configuration showcased under the project snapshot (`FPGA_33_4_4`) delivers the following hardware metrics on silicon:

* **FPGA Platform:** Terasic DE2-115 (Intel/Altera Cyclone IV E EP4CE115F29C7)
* **Clock Frequency:** 33 MHz
* **Logic Resource Utility:** 43%
* **Rigid Efficiency:** 7.28 CoreMark/MHz

---

## 🛠️ Microarchitecture Scalability (4 Core Knobs)

The entire IP throughput, scheduling capacity, and pipeline topology are fully scalable via four top-level parameters:
* **`PNUM` & `STEP_NUM`:** Establish the spatial-temporal geometry of the **Instruction Scheduling Matrix (ISM)**.
* **`OP_NUM` / `MD_NUM`:** Dictate the core's parallel execution throughput for basic arithmetic pipelines and multi-cycle, non-blocking asynchronous Multiply-Divide unit arrays.

---

## 📂 Repository Breakdown
This repository delivers a full-stack, closed-loop hardware verification environment:

1. **`/FPGA_33_4_4/` (Hardware RTL & Project):** 
   Complete Intel Quartus Prime synthesis environment for DE2-115. Includes top-level HDL (`DE2_115.v`), internal RAM initialization, and peripheral controllers (`fpga_uart.v`).
   
2. **`/FPGADEMO/` (On-Board Test Suite & Tooling):**
   - Pre-compiled standalone bare-metal binaries (`coremark_imc_*.bin`, `dhrystone_*.bin`) ready to be flashed into the instruction memory.
   - Presaved serial communication tool (`sscom5.13.1.exe`) and profiles (`sscom51.ini`) configured to capture real-time performance outputs from the FPGA UART Tx pin.