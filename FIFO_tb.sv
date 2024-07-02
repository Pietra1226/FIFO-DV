`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/01 13:17:58
// Design Name: 
// Module Name: FIFO_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

class transaction;

    rand bit operation; // decide which operation should be perform, read(0) or write(1).
    bit rd_en, wr_en, empty, full, almost_empty, almost_full;
    bit [7:0] din;
    bit [7:0] dout;
    
    constraint operation_ratio {
        operation dist {1 :/ 50, 0 :/ 50}; // read and write operation ratio is about 50%/50%
    }
    
endclass

class generator;
    
    transaction tr;
    mailbox #(transaction) mbx; // used to tranfer the transaction data to the driver
    
    int count = 0;
    int i = 0;
    
    event next; // ready to get the next transaction data
    event done; // all the stimulis are created
    
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx;
        tr = new();
    endfunction
    
    task run();    
        repeat(count)begin
            assert(tr.randomize) else $error("Randomization is Failed."); // when generator run, it randomizes the transaction data.
            i++;
            mbx.put(tr); // put transaction data into mailbox which will be sent to driver later.
            $display("[GENERATOR]: Operation: %0d, iteration: %0d", tr.operation, i);
            @(next); // already get one transaction data, it's time to get the next transaction data.
        end->done; // after running "count" times of generating, it stops itself.
    endtask
    
endclass

class driver;
    virtual FIFO_if fif; // driver is connected to the DUT, so it needs to do the interface connection.
    mailbox #(transaction) mbx;
    transaction datac; // store the transaction data from generator
    
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx;
    endfunction
    
    task reset();
        fif.rst <= 1'b1;
        fif.rd_en <= 1'b0;
        fif.wr_en <= 1'b0;
        fif.din <= 0;
        repeat (5) @(posedge fif.clk);// wait three clock
        fif.rst <= 1'b0;
        $display("[DRIVER]: DUT Reset is Done.");
        $display("---------------------------------");
    endtask;
    
    task write();
        @(posedge fif.clk);
        fif.rst <= 1'b0;
        fif.rd_en <= 1'b0;
        fif.wr_en <= 1'b1;
        fif.din <= $urandom_range(1,10); // write test data into driver
        @(posedge fif.clk);
        fif.wr_en <= 1'b0;
        $display("[DRIVER]: DATA %0d has been written.", fif.din);
        @(posedge fif.clk); // wait a clock
    endtask;
    
    task read();
        @(posedge fif.clk);
        fif.rst <= 1'b0;
        fif.rd_en <= 1'b1;
        fif.wr_en <= 1'b0;
        @(posedge fif.clk);
        fif.rd_en <= 1'b0;
        $display("[DRIVER]: DATA has been read.");
        @(posedge fif.clk); // wait a clock
    endtask;
    
    task run();
        forever begin
            mbx.get(datac);
            if(datac.operation == 1'b1)
                write();
            else
                read();
        end
    endtask
    
endclass

class monitor; // similar to the generator
    virtual FIFO_if fif; // monitor is connected to the DUT, so it needs to do the interface connection.
    mailbox #(transaction) mbx; // use this mailbox to tranfer transaction data to scoreboard
    transaction tr;
    
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx;
    endfunction
    
    task run();
        tr = new();
        forever begin
            repeat(2) @(posedge fif.clk);
            tr.wr_en = fif.wr_en;
            tr.rd_en = fif.rd_en;
            tr.din = fif.din;
            tr.empty = fif.empty;
            tr.full = fif.full;
            tr.almost_empty = fif.almost_empty;
            tr.almost_full = fif.almost_full;
            @(posedge fif.clk);
            tr.dout = fif.dout;
            
            mbx.put(tr);
            $display("[MONITOR]: Wr_en: %0d, Rd_en: %0d, Data_In: %0d, Data_Out: %0d, Empty: %0d, Full: %0d, Almost_Empty: %0d, Almost_Full: %0d", tr.wr_en, tr.rd_en, tr.din, tr.dout, tr.empty, tr.full, tr.almost_empty, tr.almost_full);
        end    
    endtask
    
endclass

class scoreboard;

    mailbox #(transaction) mbx;
    transaction tr;
    event next;
    
    bit [7:0] din [$];
    bit [7:0] temp; // store the pop out data
    int error = 0;
    
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx;
    endfunction
    
    task run();
        forever begin
            mbx.get(tr); // get transaction data from monitor
            $display("[SCOREBOARD]: Wr_en: %0d, Rd_en: %0d, Data_In: %0d, Data_Out: %0d, Empty: %0d, Full: %0d, Almost_Empty: %0d, Almost_Full: %0d", tr.wr_en, tr.rd_en, tr.din, tr.dout, tr.empty, tr.full, tr.almost_empty, tr.almost_full);
            
            if(tr.wr_en == 1'b1)
            begin
                if(tr.full == 1'b0)
                begin
                    din.push_front(tr.din);
                    $display("[SCOREBOARD]: Data %0d Store in FIFO.", tr.din);
                    if(tr.almost_full == 1'b1)
                    begin
                        $display("[SCOREBOARD]: NOTICE! FIFO is Almost FULL.");
                    end
                end
                else
                begin
                    $display("[SCOREBOARD]: !!!ALERT!!! FIFO is FULL.");
                end
                $display("---------------------------------------");
            end
            
            if(tr.rd_en == 1'b1)
            begin
                if(tr.empty == 1'b0)
                begin
                    temp = din.pop_back();
                    if(tr.dout == temp)
                        $display("[SCOREBOARD]: Data MATCH.");
                    else
                    begin
                        $error("[SCOREBOARD]: Data MISMATCH.");
                        error++;
                    end
                    if(tr.almost_empty == 1'b1)
                    begin
                        $display("[SCOREBOARD]: NOTICE! FIFO is Almost EMPTY.");
                    end
                end
                else
                begin
                    $display("[SCOREBOARD]: !!!ALERT!!! FIFO is EMPTY.");
                end
                $display("---------------------------------------");
            end
            -> next;
        end
    endtask
        
endclass

class environment;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard sco;
    
    mailbox #(transaction)gdmbx; //mailbox form generator to driver
    mailbox #(transaction)msmbx; //mailbox from monitor to scoreboard
    
    event nextgs;

    virtual FIFO_if fif;
    
    function new(virtual FIFO_if fif);
        gdmbx = new();
        gen = new(gdmbx);
        drv = new(gdmbx);
        msmbx = new();
        mon = new(msmbx);
        sco = new(msmbx);
        this.fif = fif;
        drv.fif = this.fif;
        mon.fif = this.fif;
        gen.next = nextgs;
        sco.next = nextgs;
    endfunction
    
    task pre_test();
        drv.reset();
    endtask
  
    task test();
        fork
          gen.run();
          drv.run();
          mon.run();
          sco.run();
        join_any
    endtask
  
  task post_test();
    wait(gen.done.triggered);  
    $display("---------------------------------------------");
    $display("Total Error Count :%0d", sco.error);
    $display("---------------------------------------------");
    $finish();
  endtask
  
  task run();
    pre_test();
    test();
    post_test();
  endtask
  
endclass

module FIFO_tb;
    
  FIFO_if fif();
  FIFO dut (fif.clk, fif.rst, fif.wr_en, fif.rd_en, fif.din, fif.dout, fif.empty, fif.full, fif.almost_empty, fif.almost_full);
    
  initial begin
    fif.clk <= 0;
  end
    
  always #10 fif.clk <= ~fif.clk;
    
  environment env;
    
  initial begin
    env = new(fif);
    env.gen.count = 20;
    env.run();
  end
    
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule
