module FIFO_Model #(parameter FIFO_WIDTH = 16, FIFO_DEPTH = 512)(
    input [FIFO_WIDTH-1:0] din_a,
    input wen_a, ren_b, clk_a, clk_b, rst,
    output reg [FIFO_WIDTH-1:0] dout_b,
    output reg full, empty
);
reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];
reg [$clog2(FIFO_DEPTH)-1:0] write_counter = 0;
reg [$clog2(FIFO_DEPTH)-1:0] read_counter = 0;
reg [FIFO_WIDTH-1:0] trivial_data; //extra variable to take the ignored data when full in writing and to read the ignored data when full in reading data when empty in reading

// Implementing writing stage
always @(posedge clk_a) begin
    if (rst) begin
        write_counter <= 0; 
        full <= 0;  
    end 
    else if (ren_b && !empty) 
        full <= 0;  //as when we go to the reading the full internal is still one and it should be 0 (i can't make it one in the other always block due to multi driven)
    else if (wen_a && !full) begin //writing data to memory if write enable is on and the FIFO is not full
        mem[write_counter] <= din_a;
        write_counter <= write_counter + 1;
        if (write_counter + 1 == read_counter || ((write_counter == FIFO_DEPTH -1 ) && (read_counter == 0))) //the first condition is an indication that it might be a full state while the second condition is a special case usually happens at the beginning 
                                                                                                             //I forced the case where read counter is zero and and it's supposed that when we add 1 to the write counter it goes back to zero but that is not what really happens, so when adding 1 it's actually 8 not zero so that;s why i putted this condition 
            full <= 1;
    end
    else if (wen_a && full) //to write the ignored data to check
        trivial_data <= din_a;
end

// Implementing reading stage
always @(posedge clk_b) begin
    if (rst) begin
        dout_b <= 0;
        read_counter <= 0;
        empty <= 1;
    end 
    else if (wen_a && !full)
        empty <= 0;  //write operation happened so it's not empty
    else if (ren_b && !empty) begin  //same flow as writing stage
        dout_b <= mem[read_counter];
        read_counter <= read_counter + 1;
        if (read_counter + 1 == write_counter || ((read_counter == FIFO_DEPTH-1) && (write_counter == 0)))
            empty <= 1;
    end
end
endmodule