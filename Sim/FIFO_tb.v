module FIFO #(parameter FIFO_WIDTH = 16 , FIFO_DEPTH = 512)(
    input [FIFO_WIDTH-1:0]din_a ,
    input wen_a , ren_b , clk_a , clk_b , rst ,
    output reg [FIFO_WIDTH-1:0]dout_b ,
    output reg full , empty 
);
reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0]; // defining our FIFO
reg [$clog2(FIFO_DEPTH)-1:0] write_counter = 0;  
reg [$clog2(FIFO_DEPTH)-1:0] read_counter = 0; //defining the pointers for writing and reading
reg [FIFO_WIDTH-1:0] trivial_data ; //extra variable to take the ignored data when full in writing and to read the ignored data when full in reading data when empty in reading
//***some useless tries ***\\
//reg trivial_flag ; //an extra signal just to skip the first state when reset as in writing stage it's supposed when both counters are equal then it's a full but not in the begining so this signal handles this situation 
//reg full_pre_reg ; //an internal signal to act as a pre full so the full signal is asserted at the right time
//reg empty_pre_reg ; //an internal signal to act as a pre empty so the empty signal is asserted at the right time
reg full_internal ;
reg empty_internal ;

//implementing writing stage
always @(posedge clk_a) begin
    if (rst) begin
        write_counter <= 0; 
        full_internal <= 0;  //we don't have data yet
    end 
    else begin
        if((write_counter == FIFO_DEPTH -1 ) && (read_counter == 0)) begin //special case usually happens at the beginning
                        //I forced the case where read counter is zero and and it's supposed that when we add 1 to the write counter it goes back to zero but that is not what really happens, so when adding 1 it's actually 8 not zero so that;s why i putted this condition 
            if (wen_a) begin
                mem[write_counter] <= din_a;
                write_counter <= write_counter + 1;
                full_internal <= 1 ;
            end
            else
                full_internal <= 0 ;
        end
        else if ((write_counter + 1) == read_counter) begin //this is an indication that it might be a full state
            if (wen_a) begin
                write_counter <= write_counter + 1;
                mem[write_counter] <= din_a;
                full_internal <= 1 ;
            end
            else
                full_internal <= 0 ;
        end
        else if (full && wen_a) //this condition is to handle the state when full and still receiving new data so the counter is freezed and the data is ignored
            trivial_data <= din_a ;
        else if (wen_a) begin//if data is coming and write enable is on, then there are data comming so incerement the write counter
            write_counter <= write_counter + 1;
            empty_internal <= 0;
            mem[write_counter] <= din_a;
        end
    end
end  // to sum up we will go through the last else if then to the first (usually in the beginning) or the second (usually upcoming cases) then to the third else if as the write enable is on

//implementing reading stage
always @(posedge clk_b) begin
    if (rst) begin
        dout_b <= 0;
        read_counter <= 0;
        empty_internal <= 1; //we don't have data yet
    end 
    else begin
        if((read_counter == FIFO_DEPTH-1) && (write_counter == 0)) begin //special case usually happens at the beginning
            if (ren_b) begin
                read_counter <= read_counter + 1;
                dout_b <= mem[read_counter]; 
                empty_internal <= 1; //this signal is asserted directly
            end
            else
                empty_internal <= 0;
        end
        else if ((read_counter + 1) == write_counter) begin //this is an indication that it might be an empty state
            if (ren_b) begin
                read_counter <= read_counter + 1;
                dout_b <= mem[read_counter];
                empty_internal <= 1 ; //here I asserted the empty signal directly as it takes a one clock delay naturally
            end
            else
                empty_internal <= 0 ;
        end
        else if (empty && ren_b) //this condition is to handle the state when empty and the read enable is on so the read counter is freezed and the read data is ignored
                trivial_data <= mem[read_counter];
        else if (ren_b) begin//if data is equal to zero and the read enables is on, then it's a reading process
                read_counter <= read_counter + 1;
                full_internal <= 0;
                dout_b <= mem[read_counter];
        end
    end
end // to sum up we will go through the last else if then to the first (usually in the beginning) or the second (usually upcoming cases) then to the third else if as the read enable is on
always @(*)begin
    full = full_internal;
    empty = empty_internal;
end
endmodule