








// G14

// flag
reg                                                     G14_gcm_auth_tag_prep_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G14_gcm;
reg                 [q_full - 1 : 0]                    lagger_G14_gcm;

// G14 variables
reg                 [128 - 1    : 0]                    gcm_auth_tag_G;
reg                 [128 - 1    : 0]                    gcm_auth_bin_G;
reg                 [128 - 1    : 0]                    gcm_H_prexor_G;
reg                 [128 - 1    : 0]                    iv_counter_0_enctypted_G;


//G14_gcm_auth_tag_prep_flag
always @(negedge clk_gcm) begin
if (G14_gcm_auth_tag_prep_flag == 1) begin
    lagger_G14_gcm = lagger_G14_gcm + 1;

    if (lagger_G14_gcm == 1) begin

        gcm_auth_tag_G = 0;
        gcm_auth_bin_G = 0;
        gcm_H_prexor_G = 0;
        iv_counter_0_enctypted_G = 0;


    end else if (lagger_G14_gcm == 2) begin
        if (counter_G14_gcm < 32) begin
            // reading H and iv_counter_0_enctypted_G
            main_mem_read_addr = msa_output_bus_register_gcm            + 5         + counter_G14_gcm;

        end else begin
            // reading auth_bin
            main_mem_read_addr = msa_input_bus_register_gcm             + 37        + counter_G14_gcm - 32;
            // $display("main_mem_read_addr: %d", main_mem_read_addr);
        end

    end else if (lagger_G14_gcm == 3) begin
        if (counter_G14_gcm < 16) begin
            // reading H
            gcm_H_prexor_G = gcm_H_prexor_G | (main_mem_read_data << ((15 - counter_G14_gcm) * 8));

        end else if ((16 <= counter_G14_gcm) && (counter_G14_gcm < 32)) begin
            // reading iv_counter_0_enctypted_G
            iv_counter_0_enctypted_G = iv_counter_0_enctypted_G | (main_mem_read_data << ((15 - (counter_G14_gcm - 16)) * 8));

        end else begin

            // $display("main_mem_read_addr: %d, main_mem_read_data:%b", main_mem_read_addr, main_mem_read_data);

            gcm_auth_bin_G = gcm_auth_bin_G | (main_mem_read_data << ((15 - (counter_G14_gcm - 32)) * 8));

        end


    end else if (lagger_G14_gcm == 4) begin

        if (counter_G14_gcm < 48 - 1) begin
            counter_G14_gcm = counter_G14_gcm + 1;

        end else begin
            
            G14_gcm_auth_tag_prep_flag = 0;
            
            $display("gcm_H_prexor_G: %h", gcm_H_prexor_G);
            $display("gcm_auth_bin_G: %h", gcm_auth_bin_G);
            $display("iv_counter_0_enctypted_G: %h", iv_counter_0_enctypted_G);

            galios_mult_x_gcm = gcm_auth_bin_G;
            galios_mult_y_gcm = gcm_H_prexor_G;
            caller_of_galios_mult_gcm = caller_of_galios_mult_gcm_is_G14;
            galios_mult_go_gcm = 1;

        end

        lagger_G14_gcm = 1;
    
    end 
end
end



reg                 [128 - 1    : 0]                    galios_mult_x_gcm;
reg                 [128 - 1    : 0]                    galios_mult_y_gcm;
wire                [128 - 1    : 0]                    galios_mult_result_gcm;
reg                                                     galios_mult_go_gcm;
wire                                                    galios_mult_finished_gcm;

reg                 [2 - 1      : 0]                    caller_of_galios_mult_gcm;
localparam          [2 - 1      : 0]                    caller_of_galios_mult_gcm_is_G14 = 0;
localparam          [2 - 1      : 0]                    caller_of_galios_mult_gcm_is_G15 = 1;
localparam          [2 - 1      : 0]                    caller_of_galios_mult_gcm_is_G17 = 2;

galios_mult #(.degree(128)) galios_mult_ins (
    .clk(clk_gcm),
    .go(galios_mult_go_gcm),
    .x(galios_mult_x_gcm),
    .y(galios_mult_y_gcm),
    .result(galios_mult_result_gcm),
    .finished(galios_mult_finished_gcm)
);



always @(posedge galios_mult_finished_gcm) begin

    galios_mult_go_gcm = 0;


    gcm_auth_tag_G = galios_mult_result_gcm;

    if (caller_of_galios_mult_gcm == caller_of_galios_mult_gcm_is_G14) begin
        $display("auth_tag after H*auth_bin: %h", gcm_auth_tag_G);

        counter_G15_gcm = 0;
        lagger_G15_gcm = 0;
        G15_gcm_auth_tag_block_loop_flag = 1;

    end else if (caller_of_galios_mult_gcm == caller_of_galios_mult_gcm_is_G15) begin
        
        G15_gcm_auth_tag_block_loop_flag = 1;

    end else if (caller_of_galios_mult_gcm == caller_of_galios_mult_gcm_is_G17) begin
        
        G17_gcm_finalize_auth_tag_flag = 1;

    end
    
end














// G15

// flag
reg                                                     G15_gcm_auth_tag_block_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G15_gcm;
reg                 [q_full - 1 : 0]                    lagger_G15_gcm;

// G15 variables


//G15_gcm_auth_tag_block_loop_flag
always @(negedge clk_gcm) begin
if (G15_gcm_auth_tag_block_loop_flag == 1) begin
    lagger_G15_gcm = lagger_G15_gcm + 1;

    if (lagger_G15_gcm == 1) begin

        G15_gcm_auth_tag_block_loop_flag = 0;
        // setting and launching G16
        G16_gcm_auth_tag_byte_loop_flag = 1;
        lagger_G16_gcm  = 0;
        counter_G16_gcm = 0;

    end else if (lagger_G15_gcm == 2) begin
        // $display("\ngcm_cipher_block_G16[%d]: %b", counter_G15_gcm, gcm_cipher_block_G16);

        gcm_auth_tag_G = gcm_auth_tag_G ^ gcm_cipher_block_G16;
        // $display("auth_tag %d after xor : %h", counter_G15_gcm+1, gcm_auth_tag_G);


    end else if (lagger_G15_gcm == 3) begin

        G15_gcm_auth_tag_block_loop_flag = 0;
        // starting mult
        galios_mult_x_gcm = gcm_auth_tag_G;
        galios_mult_y_gcm = gcm_H_prexor_G;
        caller_of_galios_mult_gcm = caller_of_galios_mult_gcm_is_G15;
        galios_mult_go_gcm = 1;

    // end else if (lagger_G15_gcm == 4) begin
    //     gcm_auth_tag_G = galios_mult_result_gcm; 
        // $display("auth_tag %d after mult: %h", counter_G15_gcm+1, gcm_auth_tag_G);


    end else if (lagger_G15_gcm == 5) begin

        if (counter_G15_gcm < gcm_blocks_count_B_G2 - 1) begin
            counter_G15_gcm = counter_G15_gcm + 1;

        end else begin
            
            G15_gcm_auth_tag_block_loop_flag = 0;
            
            $display("auth_tag befor lens: %h", gcm_auth_tag_G);
            

            // setting and launching G15
            lagger_G17_gcm = 0;
            G17_gcm_finalize_auth_tag_flag = 1;
        end

        lagger_G15_gcm = 0;
    
    end 
end
end
















// G16

// flag
reg                                                     G16_gcm_auth_tag_byte_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G16_gcm;
reg                 [q_full - 1 : 0]                    lagger_G16_gcm;

// G16 variables
reg                 [128 - 1    : 0]                    gcm_cipher_block_G16;

//G16_gcm_auth_tag_byte_loop_flag
always @(negedge clk_gcm) begin
if (G16_gcm_auth_tag_byte_loop_flag == 1) begin
    lagger_G16_gcm = lagger_G16_gcm + 1;

    if (lagger_G16_gcm == 1) begin
        gcm_cipher_block_G16 = 0;


    end else if (lagger_G16_gcm == 2) begin
        
        if (gcm_this_is_encryption) begin
            main_mem_read_addr = msa_output_bus_register_gcm            + 5                +    2*16 +    (16 * counter_G15_gcm)                    + counter_G16_gcm;
        end else begin
            main_mem_read_addr = gcm_input_bytes_count_start_address_G2 + 5                +              (16 * counter_G15_gcm)                    + counter_G16_gcm;
        end


    end else if (lagger_G16_gcm == 3) begin

        gcm_cipher_block_G16 = gcm_cipher_block_G16 | (main_mem_read_data << (8 * (15 - counter_G16_gcm)));


    end else if (lagger_G16_gcm == 4) begin

        if (counter_G16_gcm < 16 - 1) begin
            counter_G16_gcm = counter_G16_gcm + 1;

        end else begin
            
            G16_gcm_auth_tag_byte_loop_flag = 0;
            
            G15_gcm_auth_tag_block_loop_flag = 1;

        end

        lagger_G16_gcm = 1;
    
    end 
end
end

















// G17

// flag
reg                                                     G17_gcm_finalize_auth_tag_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_G17_gcm;
reg                 [128 - 1    : 0]                    gcm_lens_bus_G17;
reg                 [40 - 1     : 0]                    gcm_relevant_total_bits_count_G17;
reg                 [40 - 1     : 0]                    gcm_relevant_total_bytes_count_G17;
// G17 variables


//G17_gcm_finalize_auth_tag_flag
always @(negedge clk_gcm) begin
if (G17_gcm_finalize_auth_tag_flag == 1) begin
    lagger_G17_gcm = lagger_G17_gcm + 1;

    if (lagger_G17_gcm == 1) begin
        gcm_lens_bus_G17 = 0;
        gcm_lens_bus_G17 = 128 << 64;

        gcm_relevant_total_bits_count_G17 = (128 * (gcm_blocks_count_B_G2 - 1) + 8 * gcm_last_block_relevant_bytes_Z_G2);
        gcm_relevant_total_bytes_count_G17 = gcm_relevant_total_bits_count_G17 / 8;
        gcm_lens_bus_G17 = gcm_lens_bus_G17 | gcm_relevant_total_bits_count_G17;

    end else if (lagger_G17_gcm == 2) begin
        gcm_auth_tag_G = gcm_auth_tag_G ^ gcm_lens_bus_G17;

        $display("auth_tag after lens: %h", gcm_auth_tag_G);



    end else if (lagger_G17_gcm == 3) begin


        G17_gcm_finalize_auth_tag_flag = 0;
        galios_mult_x_gcm = gcm_auth_tag_G;
        galios_mult_y_gcm = gcm_H_prexor_G;
        caller_of_galios_mult_gcm = caller_of_galios_mult_gcm_is_G17;
        galios_mult_go_gcm = 1;


    end else if (lagger_G17_gcm == 4) begin

        $display("auth_tag last mult:  %h, %d", gcm_auth_tag_G, $time);

        gcm_auth_tag_G = gcm_auth_tag_G ^ iv_counter_0_enctypted_G;

        $display("auth_tag:  %h", gcm_auth_tag_G);


    end else if (lagger_G17_gcm == 5) begin

        G17_gcm_finalize_auth_tag_flag = 0;
        // setting and launching G17
        lagger_G18_gcm = 0;
        counter_G18_gcm = 0;
        G18_gcm_write_outputs_flag = 1;
    
    end 
end
end

















// G18

// flag
reg                                                     G18_gcm_write_outputs_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G18_gcm;
reg                 [q_full - 1 : 0]                    lagger_G18_gcm;

// G18 variables


//G18_gcm_write_outputs_flag
always @(negedge clk_gcm) begin
if (G18_gcm_write_outputs_flag == 1) begin
    lagger_G18_gcm = lagger_G18_gcm + 1;

    if (lagger_G18_gcm == 1) begin
        if (counter_G18_gcm < 5) begin
            main_mem_write_addr = msa_output_bus_register_gcm + counter_G18_gcm;
            main_mem_write_data = 8'b11111111 & (gcm_relevant_total_bytes_count_G17 >> ((4 - counter_G18_gcm) * 8));
        
        end else if ((5 <= counter_G18_gcm) && (counter_G18_gcm < 17)) begin
            main_mem_write_addr = msa_output_bus_register_gcm + 5 + gcm_relevant_total_bytes_count_G17 + (counter_G18_gcm - 5);
            main_mem_write_data = 8'b11111111 & (gcm_iv_E >> ((11 - (counter_G18_gcm - 5)) * 8));

        end else if (17 <= counter_G18_gcm) begin
            main_mem_write_addr = msa_output_bus_register_gcm + 5 + gcm_relevant_total_bytes_count_G17 + 12 + (counter_G18_gcm - 17);
            main_mem_write_data = 8'b11111111 & (gcm_auth_tag_G >> ((15 - (counter_G18_gcm - 17)) * 8));

        end 
        
    end else if (lagger_G18_gcm == 2) begin
        main_mem_write_enable = 1;

    end else if (lagger_G18_gcm == 3) begin
        main_mem_write_enable = 0;

    end else if (lagger_G18_gcm == 4) begin

        if (counter_G18_gcm < 33 - 1) begin
            counter_G18_gcm = counter_G18_gcm + 1;

        end else begin
            
            G18_gcm_write_outputs_flag = 0;
            
            counter_G99 = 0;
            lagger_G99 = 0;
            G99_gcm_dump_main_mem_flag = 1;



        end

        lagger_G18_gcm = 0;
    
    end 
end
end



































































































































































































