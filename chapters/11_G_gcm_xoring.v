

















    
// G10

// flag
reg                                                     G10_gcm_payload_main_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G10;
reg                 [q_full - 1 : 0]                    lagger_G10;

// G10 variables
reg                 [32 - 1     : 0]                    gcm_payload_idx_E;
reg                 [32 - 1     : 0]                    gcm_counter_E;


//G10_gcm_payload_main_loop_flag
always @(negedge clk_gcm) begin
if (G10_gcm_payload_main_loop_flag == 1) begin
    lagger_G10 = lagger_G10 + 1;

    if (lagger_G10 == 1) begin
        gcm_payload_idx_E = counter_G10;

    end else if (lagger_G10 == 2) begin
        
        $display("\n\n-----------------------------running aes on payload:%d", gcm_payload_idx_E);

        G10_gcm_payload_main_loop_flag = 0;
        // setting and launching AES for the payload
        counter_E1 = 0;
        lagger_E1 = 0;
        E1_initialize_block_based_memory_flag = 1;
        aes_shared_memory_mem_block_based_section_write_addr = 0;

    end else if (lagger_G10 == 3) begin

        if (counter_G10 < gcm_payload_counts_P_G2 - 1) begin
            counter_G10 = counter_G10 + 1;

        end else begin
            
            G10_gcm_payload_main_loop_flag = 0;
            
            
            // setting and launching soft dumper
            // counter_E5 = 0;
            // lagger_E5 = 0;
            // E5_dump_aes_shared_memory_flag = 1;





            gcm_xoring_block_counter_G12 = 0;
            counter_G11 = 0;
            lagger_G11 = 0;
            G11_gcm_xoring_payload_loop_flag  = 1;

        end

        lagger_G10 = 0;
    
    end 
end
end






















// G11

// flag
reg                                                     G11_gcm_xoring_payload_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G11; // (i)
reg                 [q_full - 1 : 0]                    lagger_G11;

// G11 variables

//G11_gcm_xoring_payload_loop_flag
always @(negedge clk_gcm) begin
if (G11_gcm_xoring_payload_loop_flag == 1) begin
    lagger_G11 = lagger_G11 + 1;

    if (lagger_G11 == 1) begin
        
        if (counter_G11 == 0) begin
            counter_G12 = 2;
        end else begin
            counter_G12 = 0;
        end

    end else if (lagger_G11 == 2) begin

        $display("\nG11:  building cipher texts for payload=%d,    counter_G12:%d", counter_G11, counter_G12);

        
        G11_gcm_xoring_payload_loop_flag = 0;
        // setting and launching G12 (counter was set above)
        lagger_G12 = 0;
        G12_gcm_xoring_block_loop_flag = 1;


    end else if (lagger_G11 == 3) begin

        if (counter_G11 < gcm_payload_counts_P_G2 - 1) begin
            counter_G11 = counter_G11 + 1;

        end else begin
            
            G11_gcm_xoring_payload_loop_flag = 0;
            
            
            


        end

        lagger_G11 = 0;
    
    end 
end
end















// G12

// flag
reg                                                     G12_gcm_xoring_block_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G12; 
reg                 [q_full - 1 : 0]                    lagger_G12;

// G12 variables
reg                 [q_full - 1 : 0]                    gcm_xoring_block_counter_G12;


//G12_gcm_xoring_block_loop_flag
always @(negedge clk_gcm) begin
if (G12_gcm_xoring_block_loop_flag == 1) begin
    lagger_G12 = lagger_G12 + 1;

    if (lagger_G12 == 1) begin
        // $display("XORing %dth of data_bin_blocks with %dth block of the %dth px_cipher_text_payload to generate %dth cipher text",
        // gcm_xoring_block_counter_G12, counter_G12, counter_G11, gcm_xoring_block_counter_G12);

        G12_gcm_xoring_block_loop_flag = 0;
        // settting and launching G13
        lagger_G13 = 0;
        counter_G13 = 0;
        G13_gcm_xoring_byte_loop_flag = 1;


    end else if (lagger_G12 == 2) begin
        gcm_xoring_block_counter_G12 = gcm_xoring_block_counter_G12 + 1;
        


    end else if (lagger_G12 == 3) begin

        if (gcm_xoring_block_counter_G12 == gcm_blocks_count_B_G2) begin
            G12_gcm_xoring_block_loop_flag = 0;

            $display("G12: we are done with cipher texts.\n");
            // go ahead with calculating auth tag 


            $display("G12: going ahead to zero irrelevant bytes of the last block");
            lagger_G131_gcm = 0;
            counter_G131_gcm = 0;
            G131_gcm_zero_last_block_irrelevant_bytes_flag = 1;
  
        end

    end else if (lagger_G12 == 4) begin

        if (counter_G12 < 32 - 1) begin
            counter_G12 = counter_G12 + 1;

        end else begin

            G12_gcm_xoring_block_loop_flag = 0;

            G11_gcm_xoring_payload_loop_flag = 1;

        end

        lagger_G12 = 0;
    
    end 
end
end



















// G13

// flag
reg                                                     G13_gcm_xoring_byte_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G13;
reg                 [q_full - 1 : 0]                    lagger_G13;

// G13 variables
reg                 [8 - 1      : 0]                    gcm_xoring_left_byte;
reg                 [8 - 1      : 0]                    gcm_xoring_right_byte;

//G13_gcm_xoring_byte_loop_flag
always @(negedge clk_gcm) begin
if (G13_gcm_xoring_byte_loop_flag == 1) begin
    lagger_G13 = lagger_G13 + 1;

    if (lagger_G13 == 1) begin
        // reading the plain text byte
        main_mem_read_addr = gcm_input_bytes_count_start_address_G2 + 5                                     + (16 * gcm_xoring_block_counter_G12)   + counter_G13;
        // $display("G13 main_mem_read_addr: %d", main_mem_read_addr);
 

    end else if (lagger_G13 == 2) begin
        gcm_xoring_left_byte = main_mem_read_data;


    end else if (lagger_G13 == 3) begin
       // reading the prexor byte
        main_mem_read_addr = msa_output_bus_register_gcm            + 5         + (512 * counter_G11)       + (16 * counter_G12)                    + counter_G13;


    end else if (lagger_G13 == 4) begin
        gcm_xoring_right_byte = main_mem_read_data;


    end else if (lagger_G13 == 5) begin
        main_mem_write_addr = main_mem_read_addr;
        main_mem_write_data = gcm_xoring_left_byte ^ gcm_xoring_right_byte;
        // $display("G13 cipher text: %b xor %b = %b", gcm_xoring_left_byte, gcm_xoring_right_byte, main_mem_write_data);

    end else if (lagger_G13 == 6) begin
        main_mem_write_enable = 1;


    end else if (lagger_G13 == 7) begin
        main_mem_write_enable = 0;


    end else if (lagger_G13 == 8) begin

        if (counter_G13 < (16 - 1)) begin
            counter_G13 = counter_G13 + 1;

        end else begin
            
            G13_gcm_xoring_byte_loop_flag = 0;
            
            G12_gcm_xoring_block_loop_flag = 1;
        end

        lagger_G13 = 0;
    
    end 
end
end












// G131

// flag
reg                                                     G131_gcm_zero_last_block_irrelevant_bytes_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G131_gcm;
reg                 [q_full - 1 : 0]                    lagger_G131_gcm;

// G131 variables


//G131_gcm_zero_last_block_irrelevant_bytes_flag
always @(negedge clk_gcm) begin
if (G131_gcm_zero_last_block_irrelevant_bytes_flag == 1) begin
    lagger_G131_gcm = lagger_G131_gcm + 1;

    if (lagger_G131_gcm == 1) begin

        if ((counter_G131_gcm + 1) > gcm_last_block_relevant_bytes_Z_G2) begin
            main_mem_write_addr = msa_output_bus_register_gcm            + 5                +    2*16 +    (16 * (gcm_blocks_count_B_G2 - 1))                    +  counter_G131_gcm;
            main_mem_write_data = 0;
        end

    end else if (lagger_G131_gcm == 2) begin
        
        if ((counter_G131_gcm + 1) > gcm_last_block_relevant_bytes_Z_G2) begin
            main_mem_write_enable = 1;
        end

    end else if (lagger_G131_gcm == 3) begin
        
        if ((counter_G131_gcm + 1) > gcm_last_block_relevant_bytes_Z_G2) begin
            main_mem_write_enable = 0;
        end


    end else if (lagger_G131_gcm == 4) begin

        if (counter_G131_gcm < 16 - 1) begin
            counter_G131_gcm = counter_G131_gcm + 1;

        end else begin
            
            G131_gcm_zero_last_block_irrelevant_bytes_flag = 0;
            
            $display("going ahead to calculate auth tag");

            lagger_G14_gcm = 0;
            counter_G14_gcm = 0;
            G14_gcm_auth_tag_prep_flag = 1;


        end

        lagger_G131_gcm = 0;
    
    end 
end
end
















