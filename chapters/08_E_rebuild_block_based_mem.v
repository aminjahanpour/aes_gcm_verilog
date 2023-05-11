

// F20

// flag
reg                                                     F20_convert_register_based_to_block_based_memory_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F20;
reg                 [q_full - 1 : 0]                    lagger_F20;

// F20 variables
reg                 [8 - 1      : 0]                    four_counter_F20;
reg                 [10 - 1     : 0]                    register_counter_F20;
reg                 [8 - 1      : 0]                    bit_counter_F20;
reg                 [8 - 1      : 0]                    register_byte_F20;


//F20_convert_register_based_to_block_based_memory_flag
always @(negedge clk_aes) begin
if (F20_convert_register_based_to_block_based_memory_flag == 1) begin
    lagger_F20 = lagger_F20 + 1;

    if (lagger_F20 == 1) begin

        main_mem_read_addr = aes_shared_mem_base_E + 512 + counter_F20;
        bit_counter_F20 = 0;

    end else if (lagger_F20 == 2) begin
        register_byte_F20 = main_mem_read_data;
        // $display("\nE6: counter_F20:%d, register_byte_F20:%b", counter_F20, register_byte_F20);

    end else if (lagger_F20 == 3) begin
        for (i = 0; i < 8; i = i + 1) begin
            involved_blocks_F20[i] = (four_counter_F20 * 8) + i;
        end

    end else if (lagger_F20 == 4) begin

        F20_convert_register_based_to_block_based_memory_flag = 0;
        // setting and launching F21;
        lagger_F21 = 0;
        counter_F21 = 0;
        F21_convert_rb_to_bb_work_on_all_registers_flag = 1;


    end else if (lagger_F20 == 5) begin

        four_counter_F20 = four_counter_F20 + 1;

        if (four_counter_F20 == 4) begin
            four_counter_F20 = 0;
            register_counter_F20 =  register_counter_F20 + 1;
        end


    end else if (lagger_F20 == 6) begin

        if (counter_F20 < 512 - 1) begin
            counter_F20 = counter_F20 + 1;

        end else begin
            
            F20_convert_register_based_to_block_based_memory_flag = 0;
            
            $display("F20: finished converting register-based memory to block-based memory.");
            
            F11_aes_main_loop_flag = 0;




            // going back to gcm payload manager
            G10_gcm_payload_main_loop_flag = 1;


        end

        lagger_F20 = 0;
    
    end 
end
end









// F21

// flag
reg                                                     F21_convert_rb_to_bb_work_on_all_registers_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F21;
reg                 [q_full - 1 : 0]                    lagger_F21;

// F21 variables
reg                 [8 - 1      : 0]                    involved_blocks_F20 [8 - 1 :    0];


//F21_convert_rb_to_bb_work_on_all_registers_flag
always @(negedge clk_aes) begin
if (F21_convert_rb_to_bb_work_on_all_registers_flag == 1) begin
    lagger_F21 = lagger_F21 + 1;

    if (lagger_F21 == 1) begin
        involved_block_F21 = involved_blocks_F20[counter_F21];
        // $display("-     F21: involved_block_F21:%d", involved_block_F21);

    end else if (lagger_F21 == 2) begin
        
        F21_convert_rb_to_bb_work_on_all_registers_flag = 0;
        // setting and launching F22;
        lagger_F22 = 0;
        counter_F22 = 0;
        F22_convert_rb_to_bb_work_on_one_register_flag = 1;

    end else if (lagger_F21 == 3) begin

        if (counter_F21 < 8 - 1) begin
            counter_F21 = counter_F21 + 1;

        end else begin
            
            F21_convert_rb_to_bb_work_on_all_registers_flag = 0;
            
            
            F20_convert_register_based_to_block_based_memory_flag = 1;

        end

        lagger_F21 = 0;
    
    end 
end
end

















// F22

// flag
reg                                                     F22_convert_rb_to_bb_work_on_one_register_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F22;
reg                 [q_full - 1 : 0]                    lagger_F22;

// F22 variables
reg                 [10 - 1     : 0]                    involved_block_F21;
reg                 [10 - 1     : 0]                    target_row_idx_in_block_mem_F22;
reg                                                     bit_value_F22;
reg                 [8 - 1      : 0]                    update_block_byte_value_F22;


//F22_convert_rb_to_bb_work_on_one_register_flag
always @(negedge clk_aes) begin
if (F22_convert_rb_to_bb_work_on_one_register_flag == 1) begin
    lagger_F22 = lagger_F22 + 1;

    if (lagger_F22 == 1) begin
        target_row_idx_in_block_mem_F22 = involved_block_F21 * 10'd16 + (register_counter_F20 / 8);

        bit_value_F22 = register_byte_F20[7 - bit_counter_F20];

        // $display("-         F22: target_row_idx_in_block_mem_F22:%d , bit_counter_F20:%d, bit_value_F22:%b", target_row_idx_in_block_mem_F22, bit_counter_F20, bit_value_F22);

    end else if (lagger_F22 == 2) begin
        // main_mem_read_addr = aes_shared_mem_base_E + target_row_idx_in_block_mem_F22;
        main_mem_read_addr = msa_output_bus_register_gcm            + 5         + gcm_payload_idx_E * 512       + target_row_idx_in_block_mem_F22;

    end else if (lagger_F22 == 3) begin
        update_block_byte_value_F22 = main_mem_read_data;

    end else if (lagger_F22 == 4) begin
        update_block_byte_value_F22 = (update_block_byte_value_F22) | (bit_value_F22 << (register_counter_F20 % 8));
        // $display("-         F22: update_block_byte_value_F22:%b", update_block_byte_value_F22);

        bit_counter_F20 = bit_counter_F20 + 1;

    end else if (lagger_F22 == 5) begin
        main_mem_write_addr = main_mem_read_addr;

        main_mem_write_data = update_block_byte_value_F22;

        // $display("addr: %d, prexor: %b", main_mem_write_addr, main_mem_write_data);

    end else if (lagger_F22 == 6) begin
        main_mem_write_enable = 1;

    end else if (lagger_F22 == 7) begin
        main_mem_write_enable = 0;


    end else if (lagger_F22 == 8) begin

            
        F22_convert_rb_to_bb_work_on_one_register_flag = 0;
        
        
        F21_convert_rb_to_bb_work_on_all_registers_flag = 1;


    
    end 
end
end