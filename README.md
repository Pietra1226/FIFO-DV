# FIFO-Design & Verification
## GOAL: Using SystemVerilog to build a FIFO module and verify it.
![image](https://github.com/Pietra1226/FIFO-DV/blob/main/FIFO.png)

![image](https://github.com/Pietra1226/FIFO-DV/blob/main/FIFO%20Interface.png)
Provide by: [AMD](https://docs.amd.com/r/en-US/pg327-emb-fifo-gen/Native-FIFO-Interface-Signals)
The table provided the required interface of the common clock FIFO. I used this table to build up my FIFO project in 8 bit and it can store 16 data. Additionally, I added two signals named almost_empty and almost_full which is optional.

1. **almost_empty**: When asserted, this signal indicates that the FIFO is almost empty and one word remains in the FIFO.
2. **almost_full**: When asserted, this signal indicates that only one more write can be performed before the FIFO is full.

This is the FIFO configuration of my project.
![image](https://github.com/Pietra1226/FIFO-DV/blob/main/My%20FIFO.png)

Tool: AMD Vivado 2023.2
