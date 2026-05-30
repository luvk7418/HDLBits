module top_module(
    input clk,
    input areset,

    input  predict_valid,
    input  [6:0] predict_pc,
    output reg predict_taken,
    output reg [6:0] predict_history,

    input train_valid,
    input train_taken,
    input train_mispredicted,
    input [6:0] train_history,
    input [6:0] train_pc
);
    reg [1:0] pht [127:0];
    wire [7:0] train_index, predict_index;
    integer i;
    
    assign train_index = train_pc ^ train_history;
    assign predict_index = predict_pc ^ predict_history;
    
    always @(posedge clk, posedge areset) begin
		if (areset) begin
            for (i = 0; i < 128; i++) pht[i] = 2'b01;
            predict_history = 7'b0;
        end else begin
            if (predict_valid) begin
                predict_history <<= 1;
                predict_history[0] = predict_taken;
            end
            if (train_valid) begin
                if (train_taken & ~&pht[train_index]) pht[train_index]++;
                else if (!train_taken & |pht[train_index]) pht[train_index]--; 
                if (train_mispredicted) predict_history = {train_history,train_taken};
            end
        end
        predict_taken = pht[predict_index][1];
    end

endmodule