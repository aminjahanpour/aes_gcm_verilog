
always @(negedge clk_gcm) begin
   clock_timer = clock_timer + 1; 
end



reg                 [8 - 1     : 0]                     clock_timer = 0;

// G2

// flag
reg                                                     G2_gcm_padding_evaluation_prep_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G2;
reg                 [q_full - 1 : 0]                    lagger_G2;

// G2 variables
reg                 [32 - 1     : 0]                    gcm_total_bits_count_G2;
reg                 [32 - 1     : 0]                    gcm_total_bytes_count_G2;
reg                 [32 - 1     : 0]                    gcm_input_bytes_count_start_address_G2;

reg                                                     gcm_this_is_encryption;

/*
this loop first finds the address where the input data bytes count is stored
then it reads those bytes and figures out the byte counts.
then it uses a function to figure out the padding for the gcm.
*/

//G2_gcm_padding_evaluation_prep_flag
always @(negedge clk_gcm) begin
if (G2_gcm_padding_evaluation_prep_flag == 1) begin
    lagger_G2 = lagger_G2 + 1;

    if (lagger_G2 == 1) begin
        gcm_input_bytes_count_start_address_G2 = 0;
        gcm_total_bytes_count_G2 = 0;

    end else if (lagger_G2 == 2) begin

        if (counter_G2 < 5) begin
            main_mem_read_addr = msa_input_bus_register_gcm + counter_G2;

        end else begin
            main_mem_read_addr = gcm_input_bytes_count_start_address_G2 + (counter_G2 - 5);
        end

    end else if (lagger_G2 == 3) begin
        if (counter_G2 < 5) begin
            gcm_input_bytes_count_start_address_G2 = gcm_input_bytes_count_start_address_G2 | (main_mem_read_data << (8 * (4 - counter_G2)));
        
        end else begin
            gcm_total_bytes_count_G2 = gcm_total_bytes_count_G2 | (main_mem_read_data << (8 * (4 - (counter_G2 - 5))));
        end

    end else if (lagger_G2 == 4) begin

        if (counter_G2 < 10 - 1) begin
            counter_G2 = counter_G2 + 1;

        end else begin
            
            G2_gcm_padding_evaluation_prep_flag = 0;
            
            gcm_total_bits_count_G2 = 8 * gcm_total_bytes_count_G2;





            $display("G2: gcm_input_bytes_count_start_address_G2:%d", gcm_input_bytes_count_start_address_G2);
            $display("G2: gcm_total_bytes_count_G2:%d", gcm_total_bytes_count_G2);
            $display("G2: gcm_total_bits_count_G2:%d", gcm_total_bits_count_G2);

            //setting and launching G3
            counter_G3 = 0;
            lagger_G3 = 0;
            G3_gcm_padding_evaluation_flag = 1;


        end

        lagger_G2 = 1;
    
    end 
end
end









// G3

// flag
reg                                                     G3_gcm_padding_evaluation_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G3;
reg                 [q_full - 1 : 0]                    lagger_G3;

// G3 variables
reg                 [24 - 1     : 0]                    gcm_payload_counts_P_G2;
reg                 [24 - 1     : 0]                    gcm_padding_bits_count_M_G2;
reg                 [24 - 1     : 0]                    gcm_blocks_count_B_G2;
reg                 [24 - 1     : 0]                    gcm_last_block_relevant_bytes_Z_G2;

reg                 [24 - 1     : 0]                    gcm_padding_bytes_count_G2;

reg                 [32 - 1     : 0]                    gcm_padding_L0_G2;
reg                 [32 - 1     : 0]                    gcm_padding_L1_G2;


//G3_gcm_padding_evaluation_flag
always @(negedge clk_gcm) begin
if (G3_gcm_padding_evaluation_flag == 1) begin
    lagger_G3 = lagger_G3 + 1;

    if (lagger_G3 == 1) begin
        gcm_blocks_count_B_G2 = gcm_total_bits_count_G2 / 128;
        gcm_last_block_relevant_bytes_Z_G2 = 16;

    end else if (lagger_G3 == 2) begin
        if ((gcm_blocks_count_B_G2 * 128) < gcm_total_bits_count_G2) begin
            gcm_last_block_relevant_bytes_Z_G2  = (gcm_total_bits_count_G2 - (gcm_blocks_count_B_G2 * 128 )) / 8;
            gcm_blocks_count_B_G2               = gcm_blocks_count_B_G2 + 1;
        end

    end else if (lagger_G3 == 3) begin
        if (gcm_total_bits_count_G2 < 3840) begin
            gcm_padding_bits_count_M_G2     = 3840 - gcm_total_bits_count_G2;
            gcm_payload_counts_P_G2         = 1;
        end

    end else if (lagger_G3 == 4) begin
        if (gcm_total_bits_count_G2 >= 3840) begin
            gcm_padding_L0_G2               = gcm_total_bits_count_G2 - 3840;
            gcm_payload_counts_P_G2         = gcm_padding_L0_G2 /  4096;
            gcm_padding_bits_count_M_G2     = 0;
            gcm_padding_L1_G2 = gcm_padding_L0_G2 - (gcm_payload_counts_P_G2 * 4096);

        end

    end else if (lagger_G3 == 5) begin
        if (gcm_total_bits_count_G2 >= 3840) begin

            if (gcm_padding_L1_G2 > 0 ) begin
                gcm_payload_counts_P_G2 = gcm_payload_counts_P_G2 + 1;
                gcm_padding_bits_count_M_G2 = gcm_padding_L1_G2;
            end

        end

    end else if (lagger_G3 == 6) begin
        if (gcm_total_bits_count_G2 >= 3840) begin
            gcm_payload_counts_P_G2 = gcm_payload_counts_P_G2 + 1;
        end
    
    end else if (lagger_G3 == 7) begin

        gcm_padding_bytes_count_G2 = gcm_padding_bits_count_M_G2 / 8;


        $display("\nG2: gcm_payload_counts_P_G2:%d",    gcm_payload_counts_P_G2);
        $display("G2: gcm_padding_bits_count_M_G2:%d",  gcm_padding_bits_count_M_G2);
        $display("G2: gcm_padding_bytes_count_G2:%d",   gcm_padding_bytes_count_G2);
        $display("G2: gcm_blocks_count_B_G2:%d",        gcm_blocks_count_B_G2);
        $display("G2: gcm_last_block_relevant_bytes_Z_G2:%d",        gcm_last_block_relevant_bytes_Z_G2);



    end else if (lagger_G3 ==8) begin

        G3_gcm_padding_evaluation_flag  =   0;
        // setting and launching G4
        G4_gcm_apply_padding_flag       =   1;
        lagger_G4 = 0;
        counter_G4 = 0;

    end 
end
end

















// G4

// flag
reg                                                     G4_gcm_apply_padding_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G4;
reg                 [q_full - 1 : 0]                    lagger_G4;

// G4 variables


//G4_gcm_apply_padding_flag
always @(negedge clk_gcm) begin
if (G4_gcm_apply_padding_flag == 1) begin
    lagger_G4 = lagger_G4 + 1;

    if (lagger_G4 == 1) begin
        main_mem_write_addr = gcm_input_bytes_count_start_address_G2 + 5 + gcm_total_bytes_count_G2 + counter_G4;
        main_mem_write_data = 8'b11111111;

    end else if (lagger_G4 == 2) begin
        main_mem_write_enable = 1;

    end else if (lagger_G4 == 3) begin
        main_mem_write_enable = 0;

    end else if (lagger_G4 == 4) begin

        if (counter_G4 < gcm_padding_bytes_count_G2 - 1) begin
            counter_G4 = counter_G4 + 1;

        end else begin
            
            G4_gcm_apply_padding_flag = 0;
            
            


            //setting and launching dumper
            // counter_G99= 0;
            // lagger_G99 = 0;
            // G99_gcm_dump_main_mem_flag = 1;


            // setting and launching G5
            lagger_G5 = 0;
            counter_G5 = 0;
            G5_gcm_generate_iv_flag = 1;

        end

        lagger_G4 = 0;
    
    end 
end
end



wire                [16 - 1 :    0]                     gcm_random_value_G5;
reg                                                     gcm_rnd_go_signal_G5;
rnd #() rnd_ins(
    .clk(clk_gcm),
    .go(gcm_rnd_go_signal_G5),
    .random_value(gcm_random_value_G5),
    .initial_value(16'd61979 * gcm_total_bits_count_G2[16 - 1: 0])
    );




// G5

// flag
reg                                                     G5_gcm_generate_iv_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G5;
reg                 [q_full - 1 : 0]                    lagger_G5;

// G5 variables
reg                 [96 - 1     : 0]                    gcm_iv_E;


//G5_gcm_generate_iv_flag
always @(negedge clk_gcm) begin
if (G5_gcm_generate_iv_flag == 1) begin
    lagger_G5 = lagger_G5 + 1;

    if (lagger_G5 == 1) begin
        gcm_iv_E = 0;
        gcm_rnd_go_signal_G5 = 1;

    end else if (lagger_G5 == 9) begin
        gcm_iv_E = gcm_iv_E | (gcm_random_value_G5 << (16 * (5 - counter_G5)));

    end else if (lagger_G5 == 10) begin

        gcm_iv_E = gcm_iv_E ^ {12{clock_timer}};

        // $display("\n%b, %b, %b", gcm_random_value_G5, gcm_iv_E, clock_timer);


    end else if (lagger_G5 == 11) begin

        if (counter_G5 < 6 - 1) begin
            counter_G5 = counter_G5 + 1;

        end else begin
            
            G5_gcm_generate_iv_flag     = 0;
            gcm_rnd_go_signal_G5        = 0;

            gcm_iv_E = gcm_iv_E ^ {12{clock_timer}};



            // $display("last");
            // $display("%b, %b, %b", gcm_random_value_G5, gcm_iv_E, clock_timer);

            // $display("G5: gcm_total_bits_count_G2[16 - 1: 0]: %b", 16'd61979 * gcm_total_bits_count_G2[16 - 1: 0]);



            // !!!!!!!!!!!!!!!!!!!!!!!!!
            gcm_iv_E=0;
            // !!!!!!!!!!!!!!!!!!!!!!!!!



            $display("G5: gcm_iv_E: %b", gcm_iv_E);



            //setting and launching G6
            counter_G10 = 0;
            lagger_G10 = 0;
            G10_gcm_payload_main_loop_flag = 1;


        end

        lagger_G5 = 1;
    
    end 
end
end























// G99

// flag
reg                                                     G99_gcm_dump_main_mem_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G99;
reg                 [q_full - 1 : 0]                    lagger_G99;

// G99 variables

//G99_gcm_dump_main_mem_flag
always @(negedge clk_gcm) begin
if (G99_gcm_dump_main_mem_flag == 1) begin
    lagger_G99 = lagger_G99 + 1;

    if (lagger_G99 == 1) begin
        main_mem_read_addr = counter_G99;

    end else if (lagger_G99 == 2) begin
        $fdisplayb(G99_output_file_main_mem, main_mem_read_data);

    end else if (lagger_G99 == 3) begin

        if (counter_G99 < main_memory_depth - 1) begin
            counter_G99 = counter_G99 + 1;

        end else begin
            $fclose(G99_output_file_main_mem);
            G99_gcm_dump_main_mem_flag = 0;
            
            $display("G99: finished dumping main at %d", $time);

            $display("FINISHED_______________________________________%d", $time);

        end

        lagger_G99 = 0;
    
    end 
end
end
