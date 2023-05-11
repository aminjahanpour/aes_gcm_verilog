
module rnd

(
    input                               clk,

    input                               go,

    input             [n_bits - 1 : 0]  initial_value,

    output  wire      [n_bits - 1 : 0]  random_value
);


localparam  n_bits = 16;


reg             [n_bits - 1 : 0]        mp_1;

reg             [n_bits : 0]            r_reg_1; 

wire            [n_bits : 0]            r_next_1;

wire                                    feedback_value_1;


always @(posedge go) begin

    mp_1    = initial_value;
    r_reg_1 = initial_value;

end


always @(clk)
begin 
    if (go) begin
       
        if (clk == 1'b1) begin

            r_reg_1 =  r_next_1;
            mp_1    =  r_next_1 ;

        end

    end

end


//// n_bits = 16
assign feedback_value_1 =  r_reg_1[16]  ^ r_reg_1[15]  ^ r_reg_1[13] ^ r_reg_1[4];

//// n_bits = 8
// assign feedback_value_1 =  r_reg_1[8]  ^ r_reg_1[6]  ^ r_reg_1[5] ^ r_reg_1[4] ^ r_reg_1[1];


assign r_next_1 =  {feedback_value_1,  r_reg_1 [n_bits : 1]};

assign random_value =  mp_1;

endmodule  