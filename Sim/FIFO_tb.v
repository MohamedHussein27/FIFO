module FIFO_tb();
parameter FIFO_WIDTH = 3 , FIFO_DEPTH = 8 ; //made the depth = 8 and the width = 3 to be more detectable
reg [FIFO_WIDTH-1:0]din_a ;
reg wen_a , ren_b , clk_a , clk_b , rst;
wire [FIFO_WIDTH-1:0]dout_b ;
wire full , empty ;

FIFO_Model #(FIFO_WIDTH , FIFO_DEPTH) dut (
    din_a , wen_a , ren_b , clk_a , clk_b , rst , dout_b , full , empty
);
//initializing the two clocks
initial begin
    clk_a = 0;
    forever #10 clk_a = ~clk_a;
end
initial begin
    clk_b = 0;
    forever #10 clk_b = ~clk_b;
end
initial begin
    //initial values 
    rst = 1 ;
    wen_a = 0;
    ren_b = 0;
    din_a = 0;
    #20;
    rst = 0;
    //write data to the FIFO until it's full
    wen_a = 1;
    ren_b = 0;
    repeat(12) begin //writing data more than the FIFO could handle to test the freezing of the write counter and if it destroys the FIFO's data and to test the full flag
        din_a = $random ;
        #20;
    end
    //reading data from the FIFO until it's empty   
    wen_a = 0;
    ren_b = 1;
    repeat(12) begin //reading data from the FIFO more than the entered data to test the freezing of the reading counter  if it destroys the FIFO's data and to test the empty flag
        #20;
    end
    //writing some data whereas it's not full or empty
    wen_a = 1;
    ren_b = 0;
    repeat(4) begin
        din_a = $random ;
        #20;
    end
    //reading untill it's empty
    wen_a = 0;
    ren_b = 1;
    repeat(7) begin
        din_a = 0 ;
        #20;
    end
    $stop;
end
endmodule