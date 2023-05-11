


module galios_mult_by_two_GF_2_8 (
        input       [8 - 1          : 0]                x,
        output      [8 - 1          : 0]                y
);

wire                 carry;



assign carry = x[7];

assign y[7] =  x[6];
assign y[6] =  x[5];
assign y[5] =  x[4];
assign y[4] = (x[3]) ^ carry;
assign y[3] = (x[2]) ^ carry;
assign y[2] =  x[1];
assign y[1] = (x[0]) ^ carry;
assign y[0] = carry;


endmodule






module galios_mult 
    #(
        parameter                                       degree                          = 0
        )
    (
        input                                           clk,
        input                                           go,
        input       [degree - 1     : 0]                x, 
        input       [degree - 1     : 0]                y,

        output reg  [degree - 1     : 0]                result,

        output reg                                      finished
    );

reg                                                     working_flag;
reg                 [degree - 1     : 0]                lagger;
reg                 [degree - 1     : 0]                counter;

reg                 [degree + 1 - 1 : 0]                irreducible_poly;

reg                 [degree + 1 - 1 : 0]                one_degree;
reg                 [degree + 1 - 1 : 0]                one_degree_one;


reg                 [2 * degree - 1     : 0]            y_clone;
reg                 [2 * degree - 1     : 0]            m;

reg                                                     verbose=0;

// go
always @(posedge go) begin

    working_flag = 1;

    lagger = 0;
    counter = 0;

    finished = 0;

    m = 0;

    one_degree      = 1 <<  degree;
    one_degree_one  = 1 << (degree - 1);

    y_clone = y;
    
    
    if  (degree == 8) begin
        irreducible_poly = 9'b100011011;
    end else if  (degree == 128) begin
        irreducible_poly = 129'd340282366920938463463374607431768211591;
    end


    // if ((x==3) && (y==196)) begin
    //     verbose = 1;
    // end

end





always @(negedge clk) begin

    if (working_flag == 1) begin

        lagger = lagger + 1;

        if (lagger == 1) begin
            m = m << 1;

            if (verbose) $display("\n0 m: %d", m);

        end else if (lagger == 2) begin
        
            if (m & one_degree) begin
                m = m ^ irreducible_poly;
    
                if (verbose) $display("1 m: %d", m);

            end

        end else if (lagger == 3) begin

            if (y_clone & one_degree_one) begin
                m = m ^ x;

                if (verbose) $display("2 m: %d", m);

            end

        end else if (lagger == 4) begin
            y_clone = y_clone << 1;
            if (verbose) $display("y_clone: %d", y_clone);


        end else if (lagger == 5) begin

            if (counter < degree - 1) begin
                counter = counter + 1;

            end else begin

                result = m;
                
                working_flag = 0;
                finished = 1;
            end

            lagger = 0;

        end

    end

end





endmodule















