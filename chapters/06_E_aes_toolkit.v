

// F0

// flag
reg                                                     F0_get_register_bus_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F0;
reg                 [q_full - 1 : 0]                    lagger_F0;

// F0 variables
reg                 [32 - 1     : 0]                    get_register_bus_F;
reg                 [8 - 1      : 0]                    register_idx_F;


reg                                                     function_caller_for_get_register_bus;
localparam                                              function_caller_for_get_register_bus_is_get_register_pack = 0;
localparam                                              function_caller_for_get_register_bus_is_apply_round_key = 1;



//F0_get_register_bus_flag
always @(negedge clk_aes) begin
if (F0_get_register_bus_flag == 1) begin
    lagger_F0 = lagger_F0 + 1;

    if (lagger_F0 == 1) begin
        get_register_bus_F = 0;

        main_mem_read_addr = aes_shared_mem_base_E + 512 + (4 * register_idx_F);

    end else if (lagger_F0 == 2) begin
        get_register_bus_F = get_register_bus_F | (main_mem_read_data << 24);



    end else if (lagger_F0 == 3) begin
        main_mem_read_addr = aes_shared_mem_base_E + 512 + (4 * register_idx_F) + 1;

    end else if (lagger_F0 == 4) begin
        get_register_bus_F = get_register_bus_F | (main_mem_read_data << 16);



    end else if (lagger_F0 == 5) begin
        main_mem_read_addr = aes_shared_mem_base_E + 512 + (4 * register_idx_F) + 2;

    end else if (lagger_F0 == 6) begin
        get_register_bus_F = get_register_bus_F | (main_mem_read_data << 8);



    end else if (lagger_F0 == 7) begin
        main_mem_read_addr = aes_shared_mem_base_E + 512 + (4 * register_idx_F) + 3;

    end else if (lagger_F0 == 8) begin
        get_register_bus_F = get_register_bus_F | main_mem_read_data;



    end else if (lagger_F0 == 9) begin

        F0_get_register_bus_flag = 0;

        case (function_caller_for_get_register_bus)
            function_caller_for_get_register_bus_is_get_register_pack   :  F1_get_register_pack_flag = 1;
            function_caller_for_get_register_bus_is_apply_round_key     :  F10_apply_round_key_flag  = 1;
        endcase
    
    end 
end
end












// F1

// flag
reg                                                     F1_get_register_pack_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F1;
reg                 [q_full - 1 : 0]                    lagger_F1;

// F1 variables
reg                 [8 - 1      : 0]                    pack_starting_index_F;
reg                 [32 - 1     : 0]                    get_register_pack_F [8 - 1      : 0];

reg                 [3 - 1      : 0]                    function_caller_for_get_register_pack;
localparam          [3 - 1      : 0]                    function_caller_for_get_register_pack_is_get_sub_bytes = 0;
localparam          [3 - 1      : 0]                    function_caller_for_get_register_pack_is_perform_aes_column_mix = 1;

//F1_get_register_pack_flag
always @(negedge clk_aes) begin
if (F1_get_register_pack_flag == 1) begin
    lagger_F1 = lagger_F1 + 1;

    if (lagger_F1 == 1) begin
        register_idx_F      = pack_starting_index_F + counter_F1;


    end else if (lagger_F1 == 2) begin


        F1_get_register_pack_flag = 0;
        // setting and launching F0
        function_caller_for_get_register_bus = function_caller_for_get_register_bus_is_get_register_pack;
        counter_F0 = 0;
        lagger_F0 = 0;
        F0_get_register_bus_flag = 1;

    end else if (lagger_F1 == 3) begin
        get_register_pack_F[counter_F1] = get_register_bus_F;

    end else if (lagger_F1 == 4) begin

        if (counter_F1 < 8 - 1) begin
            counter_F1 = counter_F1 + 1;

        end else begin
            
            F1_get_register_pack_flag = 0;
            
            case (function_caller_for_get_register_pack)
                function_caller_for_get_register_pack_is_get_sub_bytes          :   F12_get_sub_bytes_flag          = 1;
                function_caller_for_get_register_pack_is_perform_aes_column_mix :   F13_perform_aes_column_mix_flag = 1;
            endcase

        end

        lagger_F1 = 0;
    
    end 
end
end















































// F2

// flag
reg                                                     F2_replace_register_bus_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F2;
reg                 [q_full - 1 : 0]                    lagger_F2;

// F2 variables
reg                 [32 - 1     : 0]                    new_register_bus_F;
reg                                                     writing_on_aes_tmp_memory;

reg                                                     function_caller_for_replace_register_bus;
localparam                                              function_caller_for_replace_register_bus_is_replace_register_pack = 0;
localparam                                              function_caller_for_replace_register_bus_is_apply_round_key = 1;



//F2_replace_register_bus_flag
always @(negedge clk_aes) begin
if (F2_replace_register_bus_flag == 1) begin
    lagger_F2 = lagger_F2 + 1;

    if (lagger_F2 == 1) begin

        // $display("writing_on_aes_tmp_memory: %b", writing_on_aes_tmp_memory);
        if (writing_on_aes_tmp_memory == 0) begin

            main_mem_write_addr = aes_shared_mem_base_E + 512 + (4 * register_idx_F) + counter_F2;
        end else begin
            main_mem_write_addr = aes_shared_mem_base_E + 1024 + (4 * register_idx_F) + counter_F2;
        end
    end else if (lagger_F2 == 2) begin

        main_mem_write_data = (new_register_bus_F >> (8 * (3 - counter_F2))) & (8'b11111111);

    end else if (lagger_F2 == 3) begin
        main_mem_write_enable = 1;

    end else if (lagger_F2 == 4) begin
        main_mem_write_enable = 0;
    
    end else if (lagger_F2 == 5) begin

        if (counter_F2 < 4 - 1) begin
            counter_F2 = counter_F2 + 1;

        end else begin
            
            F2_replace_register_bus_flag = 0;
            

            case (function_caller_for_replace_register_bus)
                function_caller_for_replace_register_bus_is_replace_register_pack   :  F3_replace_register_pack_flag    = 1;
                function_caller_for_replace_register_bus_is_apply_round_key         :  F10_apply_round_key_flag         = 1;
            endcase
    


        end

        lagger_F2 = 0;
    
    end 
end
end












// F3

// flag
reg                                                     F3_replace_register_pack_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F3;
reg                 [q_full - 1 : 0]                    lagger_F3;

// F3 variables
// reg                 [8 - 1      : 0]                    pack_starting_index_F;
reg                 [32 - 1     : 0]                    new_register_pack_F [8 - 1      : 0];

reg                                                     function_caller_for_replace_register_pack;
localparam                                              function_caller_for_replace_register_pack_is_get_sub_bytes = 0;
localparam                                              function_caller_for_replace_register_pack_is_perform_aes_column_mix = 1;

//F3_replace_register_pack_flag
always @(negedge clk_aes) begin
if (F3_replace_register_pack_flag == 1) begin
    lagger_F3 = lagger_F3 + 1;

    if (lagger_F3 == 1) begin
        
        new_register_bus_F  = new_register_pack_F[counter_F3];
        register_idx_F      = pack_starting_index_F + counter_F3;


    end else if (lagger_F3 == 2) begin
        
        function_caller_for_replace_register_bus = function_caller_for_replace_register_bus_is_replace_register_pack;

        F3_replace_register_pack_flag = 0;
        // setting and launching F2
        lagger_F2 = 0;
        counter_F2 = 0;
        F2_replace_register_bus_flag = 1;

    end else if (lagger_F3 == 3) begin

        if (counter_F3 < 8 - 1) begin
            counter_F3 = counter_F3 + 1;

        end else begin
            
            F3_replace_register_pack_flag = 0;
            

            case (function_caller_for_replace_register_pack)
                function_caller_for_replace_register_pack_is_get_sub_bytes          : F12_get_sub_bytes_flag            = 1;
                function_caller_for_replace_register_pack_is_perform_aes_column_mix : F13_perform_aes_column_mix_flag   = 1;
            endcase
            
        end

        lagger_F3 = 0;
    
    end 
end
end


















// F4

// flag
reg                                                     F4_get_round_key_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F4;
reg                 [q_full - 1 : 0]                    lagger_F4;

// F4 variables
reg                 [8 -1       : 0]                    get_round_key_idx_F;
reg                 [128 -1     : 0]                    get_round_key_F;

//F4_get_round_key_flag
always @(negedge clk_aes) begin
if (F4_get_round_key_flag == 1) begin
    lagger_F4 = lagger_F4 + 1;

    if (lagger_F4 == 1) begin
        // expanded_keys_mem_read_addr = 16 * get_round_key_idx_F + counter_F4;
        main_mem_read_addr = msa_work_bus_register_gcm + 16 * get_round_key_idx_F + counter_F4;

    end else if (lagger_F4 == 2) begin
        // get_round_key_F = get_round_key_F | (expanded_keys_mem_read_data << ((16 - 1 - counter_F4) * 8));
        get_round_key_F = get_round_key_F | (main_mem_read_data << ((16 - 1 - counter_F4) * 8));

    end else if (lagger_F4 == 3) begin

        if (counter_F4 < 16 - 1) begin
            counter_F4 = counter_F4 + 1;

        end else begin
            
            F4_get_round_key_flag = 0;
            
            $display("\nF4: key idx:%d, key:%h", get_round_key_idx_F,get_round_key_F);

            F10_apply_round_key_flag = 1;
        end

        lagger_F4 = 0;
    
    end 
end
end












































