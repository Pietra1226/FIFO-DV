# FIFO-Design & Verification
## GOAL: Using SystemVerilog to build a FIFO ( Sync / Async ) module and verify it.
### Introduction
FIFO ( First In First Out ) is essentially a type of RAM. The difference from normal memory is that there is no external address line and it is very simple to use. But the disadvantage is that data can only be written in order, and data can only be read out in order. Because it uses its internal pointer to automatically plus 1 to operate, it cannot read or write the desired address like a general memory.

### FIFO Configuration
![image](https://github.com/Pietra1226/FIFO-DV/blob/main/FIFO.png)

![image](https://github.com/Pietra1226/FIFO-DV/blob/main/FIFO%20Interface.png)
Provide by: [AMD](https://docs.amd.com/r/en-US/pg327-emb-fifo-gen/Native-FIFO-Interface-Signals)

The table provided the required interface of the common clock FIFO. I used this table to build up my FIFO project in 8 bit and it can store 16 data. Additionally, I added two signals named almost_empty and almost_full which is optional.

1. **almost_empty**: When asserted, this signal indicates that the FIFO is almost empty and one word remains in the FIFO.
2. **almost_full**: When asserted, this signal indicates that only one more write can be performed before the FIFO is full.

### My Synchrnous FIFO Project
This is the FIFO configuration of my project.
![image](https://github.com/Pietra1226/FIFO-DV/blob/main/My%20FIFO.png)

I used the verification architecture like the picture below. I seperate the process into six section.

First, I created a class called "Generator" which could generate input for test randomly.

Next, I built a class called "Driver" which sent the whole bag of input data to DUT(Design Under Test, which is my FIFO design in this case), and printed what data I've written or read.

Third, I used a class called "Monitor" to show what the state is for each objects in DUT, and it will also send the DUT's result to the next section comparing to the golden result.

Fourth, I set up a class called "Scoreboard" to compare the result from "Monitor" and to indicate the verification is correct or not.

Last, I consisted all the section into a section called "Environment" which I could change the value from here instead of revising all the data seperating in different sections.

![image](https://github.com/Pietra1226/FIFO-DV/blob/main/Verification%20Architecture.png)

Tool: AMD Vivado 2023.2
