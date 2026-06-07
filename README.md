## 📂 Repository Breakdown
This repository delivers a full-stack, closed-loop hardware verification environment:

1. **`/FPGA_33_4_4/` (Hardware RTL & Project):** 
   Complete Intel Quartus Prime synthesis environment for DE2-115. Includes top-level HDL (`DE2_115.v`), internal RAM initialization, and peripheral controllers (`fpga_uart.v`).
   
2. **`/FPGADEMO/` (On-Board Test Suite & Tooling):**
   - Pre-compiled standalone bare-metal binaries (`coremark_imc_*.bin`, `dhrystone_*.bin`) ready to be flashed into the instruction memory.
   - Presaved serial communication tool (`sscom5.13.1.exe`) and profiles (`sscom51.ini`) configured to capture real-time performance outputs from the FPGA UART Tx pin.