

function [32 - 1: 0] gcm_counter_calculator;
    input [32 - 1 : 0] input_counter;

    begin

        if (input_counter == 0) begin

            gcm_counter_calculator = 60315029;
            // $display("\nfirst input_counter: %d, gcm_counter_calculator:%d", input_counter, gcm_counter_calculator);

        end else begin

            gcm_counter_calculator = input_counter * 32'd311;
            // $display("\ninput_counter: %d, gcm_counter_calculator:%d", input_counter, gcm_counter_calculator);


        end

    end
    
endfunction













// E1

// flag
reg                                                     E1_initialize_block_based_memory_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_E1;
reg                 [q_full - 1 : 0]                    lagger_E1;

// E1 variables
reg                 [128 - 1    : 0]                    iv_counter_E;


//E1_initialize_block_based_memory_flag
always @(negedge clk_aes) begin
if (E1_initialize_block_based_memory_flag == 1) begin
    lagger_E1 = lagger_E1 + 1;

    if (lagger_E1 == 1) begin
        iv_counter_E = {gcm_iv_E , gcm_counter_E};
        // $display("gcm_counter_E:%d, iv_counter_E:%b", gcm_counter_E, iv_counter_E);

    end else if (lagger_E1 == 2) begin

        E1_initialize_block_based_memory_flag = 0;
        // setting and launching E2
        counter_E2 = 0;
        lagger_E2 = 0;
        E2_write_one_block_to_block_based_memory_flag = 1;

    end else if (lagger_E1 == 3) begin
        gcm_counter_E = gcm_counter_calculator(gcm_counter_E);

    end else if (lagger_E1 == 4) begin

        if (counter_E1 < 32 - 1) begin
            counter_E1 = counter_E1 + 1;

        end else begin
            
            E1_initialize_block_based_memory_flag = 0;
            //setting and launching E6
            counter_E6 = 0;
            lagger_E6 = 0;
            counter_16_E = 0;
            block_counter_E = 0;
            aux_counter_E = 0;
            E6_convert_block_based_to_register_based_memory_flag = 1;


            $display("starting to convert_block_based_to_register_based_memory...");

        end

        lagger_E1 = 0;
    
    end 
end
end














// E2

// flag
reg                                                     E2_write_one_block_to_block_based_memory_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_E2;
reg                 [q_full - 1 : 0]                    lagger_E2;

// E2 variables
reg                 [address_len - 1 : 0]				aes_shared_memory_mem_block_based_section_write_addr;
reg                 [address_len - 1     : 0]           aes_shared_mem_base_E;

//E2_write_one_block_to_block_based_memory_flag
always @(negedge clk_aes) begin
if (E2_write_one_block_to_block_based_memory_flag == 1) begin
    lagger_E2 = lagger_E2 + 1;

    if (lagger_E2 == 1) begin
        main_mem_write_addr = aes_shared_mem_base_E + aes_shared_memory_mem_block_based_section_write_addr;
        main_mem_write_data = (iv_counter_E >> (8 * counter_E2)) & 128'b11111111;

        aes_shared_memory_mem_block_based_section_write_addr = aes_shared_memory_mem_block_based_section_write_addr + 1;


    end else if (lagger_E2 == 2) begin
        main_mem_write_enable = 1;


    end else if (lagger_E2 == 3) begin
        main_mem_write_enable = 0;
        

    end else if (lagger_E2 == 4) begin

        if (counter_E2 < 16 - 1) begin
            counter_E2 = counter_E2 + 1;

        end else begin
            
            E2_write_one_block_to_block_based_memory_flag = 0;
            

            E1_initialize_block_based_memory_flag = 1;

        end

        lagger_E2 = 0;
    
    end 
end
end






















// E5

// flag
reg                                                     E5_dump_aes_shared_memory_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_E5;
reg                 [q_full - 1 : 0]                    lagger_E5;

// E5 variables

//E5_dump_aes_shared_memory_flag
always @(negedge clk_aes) begin
if (E5_dump_aes_shared_memory_flag == 1) begin
    lagger_E5 = lagger_E5 + 1;

    if (lagger_E5 == 1) begin
        main_mem_read_addr = msa_output_bus_register_gcm            + 5          + counter_E5;

    end else if (lagger_E5 == 2) begin
        $fdisplayb(E5_output_file_aes_shared_memory_mem, main_mem_read_data);

        if (( 500< counter_E5) && (counter_E5 < 512)) begin
            $display("counter_E5: %d, %h", counter_E5, main_mem_read_data);
        end

    end else if (lagger_E5 == 3) begin

        if (counter_E5 < 512 - 1) begin
            counter_E5 = counter_E5 + 1;

        end else begin
            $fclose(E5_output_file_aes_shared_memory_mem);
            
            $display("\nE5: finished dumping aes_shared_memory at %d\n", $time);


            E5_dump_aes_shared_memory_flag = 0;



        end

        lagger_E5 = 0;
    
    end 
end
end





















// E6

// flag
reg                                                     E6_convert_block_based_to_register_based_memory_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_E6;
reg                 [q_full - 1 : 0]                    lagger_E6;

// E6 variables
reg                 [8 - 1      : 0]                    block_byte_E6;
reg                 [8 - 1      : 0]                    counter_16_E;
reg                 [8 - 1      : 0]                    block_counter_E;
reg                 [8 - 1      : 0]                    aux_counter_E;
reg                 [8 - 1      : 0]                    bit_counter_E;

integer i;

//E6_convert_block_based_to_register_based_memory_flag
always @(negedge clk_aes) begin
if (E6_convert_block_based_to_register_based_memory_flag == 1) begin
    lagger_E6 = lagger_E6 + 1;

    if (lagger_E6 == 1) begin
        // $display("E6: counter_E6:%d", counter_E6);

        main_mem_read_addr = aes_shared_mem_base_E + counter_E6;

        bit_counter_E = 0;

    end else if (lagger_E6 == 2) begin
        block_byte_E6 = main_mem_read_data;

    end else if (lagger_E6 == 3) begin

        for (i = 0; i < 8; i = i + 1) begin

            involved_registers_E[i] = counter_16_E * 8 + i;

        end

    end else if (lagger_E6 == 4) begin

        E6_convert_block_based_to_register_based_memory_flag = 0;
        // setting and launching E7
        lagger_E7 = 0;
        counter_E7 = 0;
        E7_work_on_all_involved_registers_flag = 1;


    end else if (lagger_E6 == 5) begin

        aux_counter_E = aux_counter_E + 1;

        counter_16_E = counter_16_E + 1;

    end else if (lagger_E6 == 6) begin

        if (aux_counter_E == 16) begin
            aux_counter_E = 0;
            block_counter_E = block_counter_E + 1;
        end

    end else if (lagger_E6 == 7) begin

        if (counter_16_E == 16) begin
            counter_16_E = 0;
        end


    end else if (lagger_E6 == 8) begin

        if (counter_E6 < 512 - 1) begin
            counter_E6 = counter_E6 + 1;

        end else begin
            
            E6_convert_block_based_to_register_based_memory_flag = 0;
            
            $display("E6: finished building the register-based mameory.");
            
            //setting and launching F10
            get_round_key_idx_F = 0;
            lagger_F10 = 0;
            counter_F10 = 0;
            F10_apply_round_key_flag = 1;

            // // setting and launching E5
            // lagger_E5 = 0;
            // counter_E5 = 0;
            // E5_dump_aes_shared_memory_flag = 1;

        end

        lagger_E6 = 0;
    
    end 
end
end










// E7

// flag
reg                                                     E7_work_on_all_involved_registers_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_E7;
reg                 [q_full - 1 : 0]                    lagger_E7;

// E7 variables
reg                 [8 - 1      : 0]                    involved_registers_E [8 - 1 : 0];

//E7_work_on_all_involved_registers_flag
always @(negedge clk_aes) begin
if (E7_work_on_all_involved_registers_flag == 1) begin
    lagger_E7 = lagger_E7 + 1;

    if (lagger_E7 == 1) begin
        involved_register_E = involved_registers_E[counter_E7];
        // $display("-     E7: involved_register_E:%d", involved_register_E);

    end else if (lagger_E7 == 2) begin
        
        E7_work_on_all_involved_registers_flag = 0;
        // setting and launching E8
        counter_E8 = 0;
        lagger_E8 = 0;
        E8_work_on_one_involved_register_flag = 1;


    end else if (lagger_E7 == 3) begin

        if (counter_E7 < 8 - 1) begin
            counter_E7 = counter_E7 + 1;

        end else begin
            
            E7_work_on_all_involved_registers_flag = 0;
            
            
            E6_convert_block_based_to_register_based_memory_flag = 1;


        end

        lagger_E7 = 0;
    
    end 
end
end




















// E8

// flag
reg                                                     E8_work_on_one_involved_register_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_E8;
reg                 [q_full - 1 : 0]                    lagger_E8;

// E8 variables
reg                 [10 - 1      : 0]                   involved_register_E;
reg                 [10 - 1     : 0]                    target_row_idx_in_register_mem_E;
reg                                                     bit_value_E6;
reg                 [8 - 1      : 0]                    update_register_value_E;

//E8_work_on_one_involved_register_flag
always @(negedge clk_aes) begin
if (E8_work_on_one_involved_register_flag == 1) begin
    lagger_E8 = lagger_E8 + 1;

    if (lagger_E8 == 1) begin
        target_row_idx_in_register_mem_E = 10'd4 * involved_register_E + (block_counter_E / 8);

    end else if (lagger_E8 == 2) begin
        bit_value_E6 = block_byte_E6[bit_counter_E];
        // $display("-         E8: target_row_idx_in_register_mem_E:%d , bit_value_E6:%b", target_row_idx_in_register_mem_E, bit_value_E6);

    end else if (lagger_E8 == 3) begin
        main_mem_read_addr = aes_shared_mem_base_E + 512 + target_row_idx_in_register_mem_E;

    end else if (lagger_E8 == 4) begin
        update_register_value_E = main_mem_read_data;

    end else if (lagger_E8 == 5) begin
        if (update_register_value_E[0]===1'bX) begin
            update_register_value_E = 0;
        end 
    end else if (lagger_E8 == 6) begin
        update_register_value_E = (update_register_value_E << 1) | bit_value_E6;

        bit_counter_E = bit_counter_E + 1;

    end else if (lagger_E8 == 7) begin
        main_mem_write_addr = main_mem_read_addr;
        main_mem_write_data = update_register_value_E;

    end else if (lagger_E8 == 8) begin
        main_mem_write_enable = 1;

    end else if (lagger_E8 == 9) begin
        main_mem_write_enable = 0;



    end else if (lagger_E8 == 10) begin

        E8_work_on_one_involved_register_flag = 0;
        
        E7_work_on_all_involved_registers_flag = 1;

    end 
end
end
