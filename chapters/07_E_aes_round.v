

// F10

// flag
reg                                                     F10_apply_round_key_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F10;
reg                 [q_full - 1 : 0]                    lagger_F10;

// F10 variables
reg                 [8 - 1      : 0]                    key_bit_idx_F10;
reg                                                     key_bit_F10;

//F10_apply_round_key_flag
always @(negedge clk_aes) begin
if (F10_apply_round_key_flag == 1) begin
    lagger_F10 = lagger_F10 + 1;

    if (lagger_F10 == 1) begin
        F10_apply_round_key_flag = 0;
        get_round_key_F = 0;
        //setting and launching F4
        lagger_F4 = 0;
        counter_F4 = 0;
        F4_get_round_key_flag = 1;

    end else if (lagger_F10 == 2) begin
    
        key_bit_idx_F10 = ((counter_F10 / 8) * 8 ) + (7 - (counter_F10 - (counter_F10 / 8) * 8));

        key_bit_F10 = get_round_key_F[128 - 1 - key_bit_idx_F10];
        // $display("F10: counter_F10:%d, key_bit_idx_F10:%d, key_bit_F10:%b", counter_F10, key_bit_idx_F10, key_bit_F10);

    end else if (lagger_F10 == 3) begin
        
        if (key_bit_F10) begin
            register_idx_F = counter_F10;

            F10_apply_round_key_flag = 0;
            // setting and launching F0
            counter_F0 = 0;
            lagger_F0 = 0;
            function_caller_for_get_register_bus = function_caller_for_get_register_bus_is_apply_round_key;
            F0_get_register_bus_flag = 1;

        end

    end else if (lagger_F10 == 4) begin
        if (key_bit_F10) begin

            // $display("-     F10: get_register_bus_F:%b", get_register_bus_F);

            new_register_bus_F = ~ get_register_bus_F;

            F10_apply_round_key_flag = 0;
            // setting and launching F2
            counter_F2 = 0;
            lagger_F2 = 0;
            function_caller_for_replace_register_bus = function_caller_for_replace_register_bus_is_apply_round_key;
            F2_replace_register_bus_flag = 1;



        end



    end else if (lagger_F10 == 5) begin

        if (counter_F10 < 128 - 1) begin
            counter_F10 = counter_F10 + 1;

        end else begin


            if (get_round_key_idx_F == 0) begin
                F10_apply_round_key_flag = 0;
                F11_aes_main_loop_flag = 1;
                
                counter_F11 = 0;
                lagger_F11 = 0;

                
            end else begin
                F10_apply_round_key_flag = 0;
                F11_aes_main_loop_flag = 1;


                // setting and launching E5
                // lagger_E5 = 0;
                // counter_E5 = 0;
                // E5_dump_aes_shared_memory_flag = 1;

            end





        end

        lagger_F10 = 1;
    
    end 
end
end

























// F11

// flag
reg                                                     F11_aes_main_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F11;
reg                 [q_full - 1 : 0]                    lagger_F11;

// F11 variables


//F11_aes_main_loop_flag
always @(negedge clk_aes) begin
if (F11_aes_main_loop_flag == 1) begin
    lagger_F11 = lagger_F11 + 1;

    if (lagger_F11 == 1) begin


        F11_aes_main_loop_flag = 0;
        // setting and launching F12
        $display("F11: starting sub-byte");
        lagger_F12 = 0;
        counter_F12 = 0;
        F12_get_sub_bytes_flag = 1;

    end else if (lagger_F11 == 2) begin
        
        F11_aes_main_loop_flag = 0;
        

        
        // setting and launching F13
        $display("F11: starting column-mix");
        writing_on_aes_tmp_memory = 1;
        lagger_F13 = 0;
        counter_F13 = 0;
        n_col_F13 = 0;
        m_row_F13 = 0;
        F13_perform_aes_column_mix_flag = 1;




    end else if (lagger_F11 == 3) begin
        writing_on_aes_tmp_memory = 0;

        F11_aes_main_loop_flag = 0;

        // setting and launching E5
        // lagger_E5 = 0;
        // counter_E5 = 0;
        // E5_dump_aes_shared_memory_flag = 1;



        // $display("F11: starting apply round key");

        //setting and launching F10
        get_round_key_idx_F = get_round_key_idx_F + 1;
        lagger_F10 = 0;
        counter_F10 = 0;
        F10_apply_round_key_flag = 1;



    end else if (lagger_F11 == 4) begin

        if (counter_F11 < 14 - 1) begin
            counter_F11 = counter_F11 + 1;

        end else begin
            
            F11_aes_main_loop_flag = 0;
            $display("F11: finished with AES main loop");
            
            
            // setting and launching F20
            lagger_F20 = 0;
            counter_F20 = 0;
            four_counter_F20 = 0;
            register_counter_F20 = 0;
            F20_convert_register_based_to_block_based_memory_flag = 1;


        end

        lagger_F11 = 0;
    
    end 
end
end
























// F12

// flag
reg                                                     F12_get_sub_bytes_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F12;
reg                 [q_full - 1 : 0]                    lagger_F12;

// F12 variables
reg                 [8 - 1      : 0]                    feed_to_sbox_F    [32 - 1     : 0];
wire                [8 - 1      : 0]                    feed_from_sbox_F  [32 - 1     : 0];

//F12_get_sub_bytes_flag
always @(negedge clk_aes) begin
if (F12_get_sub_bytes_flag == 1) begin
    lagger_F12 = lagger_F12 + 1;

    if (lagger_F12 == 1) begin
        pack_starting_index_F = 8 * counter_F12;

        F12_get_sub_bytes_flag = 0;
        //setting and launching F1
        function_caller_for_get_register_pack = function_caller_for_get_register_pack_is_get_sub_bytes;
        counter_F1 = 0;
        lagger_F1 = 0;
        F1_get_register_pack_flag = 1;


    // end else if (lagger_F12 == 2) begin

    //     for (i = 0; i < 8; i = i + 1) begin

    //         $display("-     F12: get_register_pack_F[%d]: %b", i, get_register_pack_F[i]);
    //     end


    end else if (lagger_F12 == 2) begin

        for (i = 0; i < 32; i = i + 1) begin
            feed_to_sbox_F[i] = {
                                    get_register_pack_F[7][31 - i],
                                    get_register_pack_F[6][31 - i],
                                    get_register_pack_F[5][31 - i],
                                    get_register_pack_F[4][31 - i],
                                    get_register_pack_F[3][31 - i],
                                    get_register_pack_F[2][31 - i],
                                    get_register_pack_F[1][31 - i],
                                    get_register_pack_F[0][31 - i]
                                 };

            // $display("-         F12: feed_to_sbox_F[%d]: %b", i, feed_to_sbox_F[i]);
        end


    // end else if (lagger_F12 == 3) begin

    //     for (i = 0; i < 32; i = i + 1) begin
    //         $display("-     F12: feed_from_sbox_F[%d]: %b", i, feed_from_sbox_F[i]);
    //     end




    end else if (lagger_F12 == 3) begin
        // replacing the register_pack
        for (i = 0; i < 8; i = i + 1) begin
            new_register_pack_F[i] = {
                                    feed_from_sbox_F[0][i],
                                    feed_from_sbox_F[1][i],
                                    feed_from_sbox_F[2][i],
                                    feed_from_sbox_F[3][i],
                                    feed_from_sbox_F[4][i],
                                    feed_from_sbox_F[5][i],
                                    feed_from_sbox_F[6][i],
                                    feed_from_sbox_F[7][i],
                                    feed_from_sbox_F[8][i],
                                    feed_from_sbox_F[9][i],
                                    feed_from_sbox_F[10][i],
                                    feed_from_sbox_F[11][i],
                                    feed_from_sbox_F[12][i],
                                    feed_from_sbox_F[13][i],
                                    feed_from_sbox_F[14][i],
                                    feed_from_sbox_F[15][i],
                                    feed_from_sbox_F[16][i],
                                    feed_from_sbox_F[17][i],
                                    feed_from_sbox_F[18][i],
                                    feed_from_sbox_F[19][i],
                                    feed_from_sbox_F[20][i],
                                    feed_from_sbox_F[21][i],
                                    feed_from_sbox_F[22][i],
                                    feed_from_sbox_F[23][i],
                                    feed_from_sbox_F[24][i],
                                    feed_from_sbox_F[25][i],
                                    feed_from_sbox_F[26][i],
                                    feed_from_sbox_F[27][i],
                                    feed_from_sbox_F[28][i],
                                    feed_from_sbox_F[29][i],
                                    feed_from_sbox_F[30][i],
                                    feed_from_sbox_F[31][i]
                                 };

            // $display("-             F12: new_register_pack_F[%d]: %b", i, new_register_pack_F[i]);

        end



    end else if (lagger_F12 == 4) begin

        F12_get_sub_bytes_flag = 0;
        //setting and launching F1
        function_caller_for_replace_register_pack = function_caller_for_replace_register_pack_is_get_sub_bytes;
        counter_F3 = 0;
        lagger_F3 = 0;
        F3_replace_register_pack_flag = 1;

        

    end else if (lagger_F12 == 5) begin

        if (counter_F12 < 16 - 1) begin
            counter_F12 = counter_F12 + 1;

        end else begin
            
            F12_get_sub_bytes_flag = 0;
            

            F11_aes_main_loop_flag = 1;

        end

        lagger_F12 = 0;
    
    end 
end
end















genvar j_aes;

generate
    for (j_aes = 0; j_aes < 32; j_aes = j_aes + 1) begin
        bSbox s_box_ins  (
                    .A (feed_to_sbox_F[j_aes]),
                    .Q (feed_from_sbox_F[j_aes])
                );
    end
endgenerate

            




       





































// F13

// flag
reg                                                     F13_perform_aes_column_mix_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F13;
reg                 [q_full - 1 : 0]                    lagger_F13;

// F13 variables
reg                 [4 - 1      : 0]                    m_row_F13;
reg                 [4 - 1      : 0]                    n_col_F13;

reg                 [16 - 1     : 0]                    mix_col_indecies_F13 [4 - 1: 0][4 - 1 : 0];

reg                 [8 - 1      : 0]                    starting_register_index_F13 [4 - 1 : 0];

reg                 [8 - 1      : 0]                    mult_test_in;
wire                [8 - 1      : 0]                    mult_test_out;

//F13_perform_aes_column_mix_flag
always @(negedge clk_aes) begin
if (F13_perform_aes_column_mix_flag == 1) begin
    lagger_F13 = lagger_F13 + 1;

    if (lagger_F13 == 1) begin
        // load up the indecies from the table

        for (i = 0; i < 4; i = i + 1) begin
            starting_register_index_F13[i] = 8 * ( ( mix_col_indecies_F13[n_col_F13][m_row_F13] >> (4 * (3 - i))  ) & 4'b1111   );
            // $display("starting_register_index_F13[%d]: %d",i, starting_register_index_F13[i]);

        end


    end else if (lagger_F13 == 2) begin
        // load up the first register pack
        pack_starting_index_F = starting_register_index_F13[0];


        F13_perform_aes_column_mix_flag = 0;
        // setting and launching F1
        lagger_F1 = 0;
        counter_F1 = 0;
        function_caller_for_get_register_pack = function_caller_for_get_register_pack_is_perform_aes_column_mix;
        F1_get_register_pack_flag = 1;


    end else if (lagger_F13 == 3) begin
        // store a clone of the first register pack
        // $display("F13: first starting_register_index: %d", pack_starting_index_F);

        for (i = 0; i < 8 ; i = i + 1) begin
            new_register_pack_F[i] = get_register_pack_F[i];
            // $display("get_register_pack_F[%d]: %b",i, get_register_pack_F[i]);

        end


    end else if (lagger_F13 == 4) begin
        // load up the second register pack
        pack_starting_index_F = starting_register_index_F13[1];


        F13_perform_aes_column_mix_flag = 0;
        // setting and launching F1
        lagger_F1 = 0;
        counter_F1 = 0;
        function_caller_for_get_register_pack = function_caller_for_get_register_pack_is_perform_aes_column_mix;
        F1_get_register_pack_flag = 1;


    // end else if (lagger_F13 == 10) begin
    //     $display("F13: second starting_register_index: %d", pack_starting_index_F);
    //     for (i = 0; i < 8 ; i = i + 1) begin
    //         $display("get_register_pack_F[%d]: %b", i, get_register_pack_F[i]);
    //     end


    end else if (lagger_F13 == 5) begin

        for (i = 0; i < 8 ; i = i + 1) begin
            new_register_pack_F[i] = get_register_pack_F[i] ^ new_register_pack_F[i];
        end


    end else if (lagger_F13 == 6) begin
        // prep the feed for mult by two
        for (i = 0; i < 32; i = i + 1) begin
            feed_to_galios_mult_by_two_F[i] = {
                                    new_register_pack_F[7][31 - i],
                                    new_register_pack_F[6][31 - i],
                                    new_register_pack_F[5][31 - i],
                                    new_register_pack_F[4][31 - i],
                                    new_register_pack_F[3][31 - i],
                                    new_register_pack_F[2][31 - i],
                                    new_register_pack_F[1][31 - i],
                                    new_register_pack_F[0][31 - i]
                                 };

            // $display("-         F12: feed_to_galios_mult_by_two_F[%d]: %b", i, feed_to_galios_mult_by_two_F[i]);
        end


    end else if (lagger_F13 == 7) begin

        for (i = 0; i < 8; i = i + 1) begin
            new_register_pack_F[i] = {
                                    feed_from_galios_mult_by_two[0][i],
                                    feed_from_galios_mult_by_two[1][i],
                                    feed_from_galios_mult_by_two[2][i],
                                    feed_from_galios_mult_by_two[3][i],
                                    feed_from_galios_mult_by_two[4][i],
                                    feed_from_galios_mult_by_two[5][i],
                                    feed_from_galios_mult_by_two[6][i],
                                    feed_from_galios_mult_by_two[7][i],
                                    feed_from_galios_mult_by_two[8][i],
                                    feed_from_galios_mult_by_two[9][i],
                                    feed_from_galios_mult_by_two[10][i],
                                    feed_from_galios_mult_by_two[11][i],
                                    feed_from_galios_mult_by_two[12][i],
                                    feed_from_galios_mult_by_two[13][i],
                                    feed_from_galios_mult_by_two[14][i],
                                    feed_from_galios_mult_by_two[15][i],
                                    feed_from_galios_mult_by_two[16][i],
                                    feed_from_galios_mult_by_two[17][i],
                                    feed_from_galios_mult_by_two[18][i],
                                    feed_from_galios_mult_by_two[19][i],
                                    feed_from_galios_mult_by_two[20][i],
                                    feed_from_galios_mult_by_two[21][i],
                                    feed_from_galios_mult_by_two[22][i],
                                    feed_from_galios_mult_by_two[23][i],
                                    feed_from_galios_mult_by_two[24][i],
                                    feed_from_galios_mult_by_two[25][i],
                                    feed_from_galios_mult_by_two[26][i],
                                    feed_from_galios_mult_by_two[27][i],
                                    feed_from_galios_mult_by_two[28][i],
                                    feed_from_galios_mult_by_two[29][i],
                                    feed_from_galios_mult_by_two[30][i],
                                    feed_from_galios_mult_by_two[31][i]
                                 };

            // $display("-             F12: feed_from_galios_mult_by_two[%d]: %b", i, feed_from_galios_mult_by_two[i]);

        end


    end else if (lagger_F13 == 8) begin
        for (i = 0; i < 8 ; i = i + 1) begin
            new_register_pack_F[i] = get_register_pack_F[i] ^ new_register_pack_F[i];
        end



    end else if (lagger_F13 == 9) begin
        // load up the second register pack
        pack_starting_index_F = starting_register_index_F13[2];


        F13_perform_aes_column_mix_flag = 0;
        // setting and launching F1
        lagger_F1 = 0;
        counter_F1 = 0;
        function_caller_for_get_register_pack = function_caller_for_get_register_pack_is_perform_aes_column_mix;
        F1_get_register_pack_flag = 1;

    // end else if (lagger_F13 == 22) begin
    //     $display("F13: third starting_register_index: %d", pack_starting_index_F);
    //     for (i = 0; i < 8 ; i = i + 1) begin
    //         $display("get_register_pack_F[%d]: %b", i, get_register_pack_F[i]);
    //     end

    end else if (lagger_F13 == 10) begin


        for (i = 0; i < 8 ; i = i + 1) begin
            new_register_pack_F[i] = get_register_pack_F[i] ^ new_register_pack_F[i];
        end



    end else if (lagger_F13 == 11) begin
        // load up the second register pack
        pack_starting_index_F = starting_register_index_F13[3];


        F13_perform_aes_column_mix_flag = 0;
        // setting and launching F1
        lagger_F1 = 0;
        counter_F1 = 0;
        function_caller_for_get_register_pack = function_caller_for_get_register_pack_is_perform_aes_column_mix;
        F1_get_register_pack_flag = 1;


    // end else if (lagger_F13 == 28) begin
    //     $display("F13: fourth starting_register_index: %d", pack_starting_index_F);
    //     for (i = 0; i < 8 ; i = i + 1) begin
    //         $display("get_register_pack_F[%d]: %b", i, get_register_pack_F[i]);
    //     end

    end else if (lagger_F13 == 12) begin

        for (i = 0; i < 8 ; i = i + 1) begin
            new_register_pack_F[i] = get_register_pack_F[i] ^ new_register_pack_F[i];
        end

    end else if (lagger_F13 == 13) begin
        pack_starting_index_F = 8 * (4 * n_col_F13 + (m_row_F13 % 4));


        F13_perform_aes_column_mix_flag = 0;
        //setting and launching F1
        function_caller_for_replace_register_pack = function_caller_for_replace_register_pack_is_perform_aes_column_mix;
        counter_F3 = 0;
        lagger_F3 = 0;
        F3_replace_register_pack_flag = 1;


    end else if (lagger_F13 == 14) begin

        if (counter_F13 < 16 - 1) begin
            counter_F13 = counter_F13 + 1;


            n_col_F13 = n_col_F13 + 1;

            if (n_col_F13 == 4) begin
                
                n_col_F13 = 0;

                m_row_F13 = m_row_F13 + 1;

            end
            
        end else begin
            
            F13_perform_aes_column_mix_flag = 0;
            // setting and launching F14
            lagger_F14 = 0;
            counter_F14 = 0;
            F14_copy_temp_col_mix_result_to_main_memory_flag = 1;


        end

        lagger_F13 = 0;
    
    end 
end
end







reg                 [8 - 1      : 0]                    feed_to_galios_mult_by_two_F      [32 - 1     : 0];
wire                [8 - 1      : 0]                    feed_from_galios_mult_by_two    [32 - 1     : 0];

genvar k;

generate
    for (k = 0; k < 32; k = k + 1) begin
        galios_mult_by_two_GF_2_8 galios_mult_by_two_GF_2_8_cases  (
                    .x (feed_to_galios_mult_by_two_F[k]),
                    .y (feed_from_galios_mult_by_two[k])
                );
    end
endgenerate

            
















// F14

// flag
reg                                                     F14_copy_temp_col_mix_result_to_main_memory_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F14;
reg                 [q_full - 1 : 0]                    lagger_F14;

// F14 variables


//F14_copy_temp_col_mix_result_to_main_memory_flag
always @(negedge clk_aes) begin
if (F14_copy_temp_col_mix_result_to_main_memory_flag == 1) begin
    lagger_F14 = lagger_F14 + 1;

    if (lagger_F14 == 1) begin
        main_mem_read_addr = aes_shared_mem_base_E + 1024 + counter_F14;

    end else if (lagger_F14 == 2) begin
        main_mem_write_addr = aes_shared_mem_base_E + 512 + counter_F14;
        main_mem_write_data = main_mem_read_data;

    end else if (lagger_F14 == 3) begin
        main_mem_write_enable = 1;
    
    end else if (lagger_F14 == 4) begin
        main_mem_write_enable = 0;
        
    end else if (lagger_F14 == 5) begin
        main_mem_write_addr = aes_shared_mem_base_E + counter_F14;
        main_mem_write_data = 0;

    end else if (lagger_F14 == 6) begin
        main_mem_write_enable = 1;
    
    end else if (lagger_F14 == 7) begin
        main_mem_write_enable = 0;
        

    end else if (lagger_F14 == 8) begin

        if (counter_F14 < 512 - 1) begin
            counter_F14 = counter_F14 + 1;

        end else begin
            
            F14_copy_temp_col_mix_result_to_main_memory_flag = 0;
            
            F11_aes_main_loop_flag = 1;


        end

        lagger_F14 = 0;
    
    end 
end
end