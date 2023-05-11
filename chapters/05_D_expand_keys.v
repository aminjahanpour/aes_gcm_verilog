
// D0

// flag
reg                                                     D0_read_base_key_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_D0;
reg                 [q_full - 1 : 0]                    lagger_D0;

// D0 variables
reg                 [32 - 1     : 0]                    new_word_D;

reg                 [32 - 1     : 0]                    base_key_words_D [8 - 1   : 0];

reg                 [8 - 1      : 0]                    round_constants_D [ 7 - 1 :0];

//D0_read_base_key_flag
always @(negedge clk_expand_keys) begin
if (D0_read_base_key_flag == 1) begin
    lagger_D0 = lagger_D0 + 1;

    if (lagger_D0 == 1) begin
        main_mem_read_addr = msa_input_bus_register_gcm + 5 + counter_D0;
    
    end else if (lagger_D0 == 2) begin

        if (counter_D0 < 32) begin
            main_mem_write_addr = msa_work_bus_register_gcm + counter_D0;
        end

    end else if (lagger_D0 == 3) begin
        if (counter_D0 < 32) begin
            main_mem_write_data = main_mem_read_data;
        end

    end else if (lagger_D0 == 4) begin
        if (counter_D0 < 32) begin
            main_mem_write_enable = 1;
        end

    end else if (lagger_D0 == 5) begin
        if (counter_D0 < 32) begin
            main_mem_write_enable = 0;
        end


    end else if (lagger_D0 == 6) begin

        case (counter_D0 % 4)
            0     :    base_key_words_D[counter_D0 / 4]  = base_key_words_D[counter_D0 / 4]  | (main_mem_read_data << 24);
            1     :    base_key_words_D[counter_D0 / 4]  = base_key_words_D[counter_D0 / 4]  | (main_mem_read_data << 16);
            2     :    base_key_words_D[counter_D0 / 4]  = base_key_words_D[counter_D0 / 4]  | (main_mem_read_data << 8);
            3     :    base_key_words_D[counter_D0 / 4]  = base_key_words_D[counter_D0 / 4]  | (main_mem_read_data);
        endcase


    end else if (lagger_D0 == 7) begin

        case (counter_D0)
            0     :    round_constants_D[counter_D0]  = 1;
            1     :    round_constants_D[counter_D0]  = 2;
            2     :    round_constants_D[counter_D0]  = 4;
            3     :    round_constants_D[counter_D0]  = 8;
            4     :    round_constants_D[counter_D0]  = 16;
            5     :    round_constants_D[counter_D0]  = 32;
            6     :    round_constants_D[counter_D0]  = 64;
        endcase



    end else if (lagger_D0 == 8) begin

        if (counter_D0 < 32 - 1) begin
            counter_D0 = counter_D0 + 1;

        end else begin
            D0_read_base_key_flag = 0;
            


            //setting and launching D1
            counter_D1 = 0;
            lagger_D1 = 0;
            eight_counter_D = 0;
            rc_idx_D = 0;
            new_word_D = base_key_words_D[7];

            main_mem_write_addr = main_mem_write_addr + 1;

            D1_main_loop_flag = 1;

            // $display("new_word_D:%b",new_word_D);


            // D19_display_base_key_words_flag = 1;
            // counter_D19 = 0;
            // lagger_D19 = 0;

        end

        lagger_D0 = 0;
    
    end 
end
end





















// D1

// flag
reg                                                     D1_main_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_D1;
reg                 [q_full - 1 : 0]                    lagger_D1;

// D1 variables
reg                 [3 - 1      : 0]                    key_explansion_stage_D;
localparam          [3 - 1      : 0]                    key_explansion_stage_new_D        = 0;
localparam          [3 - 1      : 0]                    key_explansion_stage_middle_D     = 1;
localparam          [3 - 1      : 0]                    key_explansion_stage_regular_D    = 2;

reg                 [9 - 1      : 0]                    eight_counter_D;

reg                 [32 - 1     : 0]                    left_xor_D;
reg                 [32 - 1     : 0]                    right_xor_D;
reg                 [8 - 1      : 0]                    rc_idx_D;
reg                 [32 - 1     : 0]                    round_constant_aux_D;



//D1_main_loop_flag
always @(negedge clk_expand_keys) begin
if (D1_main_loop_flag == 1) begin
    lagger_D1 = lagger_D1 + 1;

    if (lagger_D1 == 1) begin

        case (eight_counter_D)
            0           :    key_explansion_stage_D = key_explansion_stage_new_D;
            4           :    key_explansion_stage_D = key_explansion_stage_middle_D;
            default     :    key_explansion_stage_D = key_explansion_stage_regular_D;
        endcase


    end else if (lagger_D1 == 2) begin

        if (key_explansion_stage_D == key_explansion_stage_regular_D) begin
            left_xor_D  = new_word_D;
            right_xor_D = base_key_words_D[eight_counter_D];

        end else if (key_explansion_stage_D == key_explansion_stage_middle_D) begin


            feed_to_sbox_D[0] = new_word_D[32 - 1  :  24];
            feed_to_sbox_D[1] = new_word_D[24 - 1  :  16];
            feed_to_sbox_D[2] = new_word_D[16 - 1  :   8];
            feed_to_sbox_D[3] = new_word_D[8  - 1  :   0];

            
        end else if (key_explansion_stage_D == key_explansion_stage_new_D) begin
            before_rot_word_D = new_word_D;

            D1_main_loop_flag = 0;
            // setting and launching D3
            counter_D3 = 0;
            lagger_D3= 0;
            after_rot_word_D = 0;
            D3_rot_word_flag = 1;

        end




    end else if (lagger_D1 == 3) begin


        if (key_explansion_stage_D == key_explansion_stage_middle_D) begin

            left_xor_D = {feed_from_sbox_D[0], feed_from_sbox_D[1], feed_from_sbox_D[2], feed_from_sbox_D[3]};

            right_xor_D = base_key_words_D[eight_counter_D];


            
        end else if (key_explansion_stage_D == key_explansion_stage_new_D) begin
            left_xor_D = after_rot_word_D;

            feed_to_sbox_D[0] = left_xor_D[32 - 1  :  24];
            feed_to_sbox_D[1] = left_xor_D[24 - 1  :  16];
            feed_to_sbox_D[2] = left_xor_D[16 - 1  :   8];
            feed_to_sbox_D[3] = left_xor_D[8  - 1  :   0];


        end



    end else if (lagger_D1 == 4) begin


        if (key_explansion_stage_D == key_explansion_stage_new_D) begin
            left_xor_D = {feed_from_sbox_D[0], feed_from_sbox_D[1], feed_from_sbox_D[2], feed_from_sbox_D[3]};

            // $display("D1: rc in:            %b", left_xor_D);

            round_constant_aux_D = round_constants_D[rc_idx_D] << 24;

            left_xor_D = left_xor_D ^ round_constant_aux_D;


            // $display("D1: rc out:           %b", left_xor_D);

            rc_idx_D = rc_idx_D + 1;



        end




    end else if (lagger_D1 == 5) begin


        if (key_explansion_stage_D == key_explansion_stage_new_D) begin
            
            if (counter_D1 >=  1) begin

                // $display("\nswitching base_key_words");


                D1_main_loop_flag = 0;
                // setting and launching D4
                counter_D4 = 0;
                lagger_D4= 0;
                base_key_words_D[0] = 0;
                base_key_words_D[1] = 0;
                base_key_words_D[2] = 0;
                base_key_words_D[3] = 0;
                base_key_words_D[4] = 0;
                base_key_words_D[5] = 0;
                base_key_words_D[6] = 0;
                base_key_words_D[7] = 0;
                D4_update_base_key_words_flag = 1;

            end

        end


    end else if (lagger_D1 == 6) begin


        if (key_explansion_stage_D == key_explansion_stage_new_D) begin

            // $display("base_key_words_D[0]: %b", base_key_words_D[0]);
            // $display("base_key_words_D[1]: %b", base_key_words_D[1]);
            // $display("base_key_words_D[2]: %b", base_key_words_D[2]);

            
            eight_counter_D = 0;

            right_xor_D = base_key_words_D[eight_counter_D];
        end




    end else if (lagger_D1 == 7) begin

        new_word_D = left_xor_D ^ right_xor_D;




    end else if (lagger_D1 == 8) begin
        main_mem_write_data = new_word_D[32 - 1 : 24];

    end else if (lagger_D1 == 9) begin
        main_mem_write_enable = 1;

    end else if (lagger_D1 == 10) begin
        main_mem_write_enable = 0;

    end else if (lagger_D1 == 11) begin
        main_mem_write_addr = main_mem_write_addr + 1;



    end else if (lagger_D1 == 12) begin
        main_mem_write_data = new_word_D[24 - 1 : 16];

    end else if (lagger_D1 == 13) begin
        main_mem_write_enable = 1;

    end else if (lagger_D1 == 14) begin
        main_mem_write_enable = 0;

    end else if (lagger_D1 == 15) begin
        main_mem_write_addr = main_mem_write_addr + 1;



    end else if (lagger_D1 == 16) begin
        main_mem_write_data = new_word_D[16 - 1 : 8];

    end else if (lagger_D1 == 17) begin
        main_mem_write_enable = 1;

    end else if (lagger_D1 == 18) begin
        main_mem_write_enable = 0;

    end else if (lagger_D1 == 19) begin
        main_mem_write_addr = main_mem_write_addr + 1;



    end else if (lagger_D1 == 20) begin
        main_mem_write_data = new_word_D[8 - 1 : 0];

    end else if (lagger_D1 == 21) begin
        main_mem_write_enable = 1;

    end else if (lagger_D1 == 22) begin
        main_mem_write_enable = 0;

    end else if (lagger_D1 == 23) begin
        main_mem_write_addr = main_mem_write_addr + 1;






    end else if (lagger_D1 == 24) begin

        if (main_mem_write_addr == msa_work_bus_register_gcm + 240) begin
            D1_main_loop_flag = 0;

            $display("");
            D20_dump_expanded_keys_flag = 1;
            counter_D20 = 0;
            lagger_D20 = 0;

        end else begin
            
            counter_D1 = counter_D1 + 1;

            eight_counter_D = eight_counter_D + 1;

            if (eight_counter_D == 8) begin
                eight_counter_D = 0;
            end


            lagger_D1 = 0;

        end

    
    end 
end
end











reg                 [8 - 1      : 0]                    feed_to_sbox_D      [4 - 1     : 0];
wire                [8 - 1      : 0]                    feed_from_sbox_D    [4 - 1     : 0];

genvar j_expand_keys;

generate
    for (j_expand_keys = 0; j_expand_keys < 4; j_expand_keys = j_expand_keys + 1) begin
        bSbox s_box_ins  (
                    .A (feed_to_sbox_D[j_expand_keys]),
                    .Q (feed_from_sbox_D[j_expand_keys])
                );
    end
endgenerate

      








// D3

// flag
reg                                                     D3_rot_word_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_D3;
reg                 [q_full - 1 : 0]                    lagger_D3;

// D3 variables
reg                 [32 - 1     : 0]                    before_rot_word_D;
reg                 [32 - 1     : 0]                    after_rot_word_D;


//D3_rot_word_flag
always @(negedge clk_expand_keys) begin
if (D3_rot_word_flag == 1) begin
    lagger_D3 = lagger_D3 + 1;

    if (lagger_D3 == 1) begin

        case (counter_D3)
            0           :    after_rot_word_D =                    before_rot_word_D[24 - 1 : 16] << 24;
            1           :    after_rot_word_D = after_rot_word_D | before_rot_word_D[16 - 1 : 8] << 16;
            2           :    after_rot_word_D = after_rot_word_D | before_rot_word_D[8 - 1  : 0] << 8;
            3           :    after_rot_word_D = after_rot_word_D | before_rot_word_D[32 - 1 : 24];
        endcase
        

    end else if (lagger_D3 == 2) begin

        if (counter_D3 < 4 - 1) begin
            counter_D3 = counter_D3 + 1;

        end else begin
            // $display("D2: before_rot_word_D:%b, after_rot_word_D:%b",before_rot_word_D, after_rot_word_D);

            D3_rot_word_flag = 0;
            
            D1_main_loop_flag = 1;

        end

        lagger_D3 = 0;
    
    end 
end
end












// D4

// flag
reg                                                     D4_update_base_key_words_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_D4;
reg                 [q_full - 1 : 0]                    lagger_D4;

// D4 variables


//D4_update_base_key_words_flag
always @(negedge clk_expand_keys) begin
if (D4_update_base_key_words_flag == 1) begin
    lagger_D4 = lagger_D4 + 1;

    if (lagger_D4 == 1) begin

        main_mem_read_addr = main_mem_write_addr - 32 + counter_D4;
        

    end else if (lagger_D4 == 2) begin
        
        case (counter_D4 % 4)
            0     :    base_key_words_D[counter_D4 / 4]  = base_key_words_D[counter_D4 / 4]  | (main_mem_read_data << 24);
            1     :    base_key_words_D[counter_D4 / 4]  = base_key_words_D[counter_D4 / 4]  | (main_mem_read_data << 16);
            2     :    base_key_words_D[counter_D4 / 4]  = base_key_words_D[counter_D4 / 4]  | (main_mem_read_data << 8);
            3     :    base_key_words_D[counter_D4 / 4]  = base_key_words_D[counter_D4 / 4]  | (main_mem_read_data);
        endcase


    end else if (lagger_D4 == 3) begin

        if (counter_D4 < 32 - 1) begin
            counter_D4 = counter_D4 + 1;

        end else begin
            
            D4_update_base_key_words_flag = 0;
            
            
            D1_main_loop_flag = 1;



        end

        lagger_D4 = 0;
    
    end 
end
end



















































// D20

// flag
reg                                                     D20_dump_expanded_keys_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_D20;
reg                 [q_full - 1 : 0]                    lagger_D20;

// D20 variables

//D20_dump_expanded_keys_flag
always @(negedge clk_expand_keys) begin
if (D20_dump_expanded_keys_flag == 1) begin
    lagger_D20 = lagger_D20 + 1;

    if (lagger_D20 == 1) begin
        main_mem_read_addr = msa_work_bus_register_gcm + counter_D20;

    end else if (lagger_D20 == 2) begin
        $writeh(main_mem_read_data);

        if((counter_D20+1) % 16 == 0) begin
            $display("");
        end


    end else if (lagger_D20 == 3) begin

        if (counter_D20 < 240 - 1) begin
            counter_D20 = counter_D20 + 1;

        end else begin
            D20_dump_expanded_keys_flag = 0;
            
            $display("\nD20: finished dumping expanded_keys at %d", $time);

            finished_expand_keys = 1;


            $display("\n GCM STARTING at %d\n", $time);

            reset_gcm = 1;

        end

        lagger_D20 = 0;
    
    end 
end
end




