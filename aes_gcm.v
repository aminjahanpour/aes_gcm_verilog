
        

module soc (
    input                                               clk,
    input                                               reset,
    output reg                                          finished
);



// Output Files

integer                                                 E5_output_file_aes_shared_memory_mem;
integer                                                 G99_output_file_main_mem;




// Reset
always @(posedge reset) begin


    $display("soc reset.");

    finished                   = 0;

    gcm_this_is_encryption = 0;

    
	reset_expand_keys            = 0;
	reset_aes            = 0;
	reset_gcm            = 0;

	finished_expand_keys         = 0;
	finished_aes         = 0;
	finished_gcm         = 0;

    
    
    E5_output_file_aes_shared_memory_mem =                                $fopen("./dumps/E5_output_file_aes_shared_memory_mem.txt", "w");
G99_output_file_main_mem =                                $fopen("./dumps/G99_output_file_main_mem.txt", "w");


    
    reset_expand_keys = 1;

end


            
            
always @(posedge reset_expand_keys) begin



    finished_expand_keys       =   0;
            

            D0_read_base_key_flag = 1;
            counter_D0 = 0;
            lagger_D0 = 0;
            new_word_D = 0;
            base_key_words_D[0] = 0;
            base_key_words_D[1] = 0;
            base_key_words_D[2] = 0;
            base_key_words_D[3] = 0;
            base_key_words_D[4] = 0;
            base_key_words_D[5] = 0;
            base_key_words_D[6] = 0;
            base_key_words_D[7] = 0;
            
            
            
end
            
            
            
            
always @(posedge reset_gcm) begin



    finished_gcm       =   0;
            
    gcm_counter_E = 0;

    aes_shared_mem_base_E = msa_work_bus_register_gcm + 240;

    G2_gcm_padding_evaluation_prep_flag = 1;
    counter_G2 = 0;
    lagger_G2 = 0;
            
    

    // AES stuff

    finished_aes       =   0;
            
    mix_col_indecies_F13[0][0] = 16'b0000010110101111;
    mix_col_indecies_F13[1][0] = 16'b0100100111100011;
    mix_col_indecies_F13[2][0] = 16'b1000110100100111;
    mix_col_indecies_F13[3][0] = 16'b1100000101101011;
    mix_col_indecies_F13[0][1] = 16'b0101101011110000;
    mix_col_indecies_F13[1][1] = 16'b1001111000110100;
    mix_col_indecies_F13[2][1] = 16'b1101001001111000;
    mix_col_indecies_F13[3][1] = 16'b0001011010111100;
    mix_col_indecies_F13[0][2] = 16'b1010111100000101;
    mix_col_indecies_F13[1][2] = 16'b1110001101001001;
    mix_col_indecies_F13[2][2] = 16'b0010011110001101;
    mix_col_indecies_F13[3][2] = 16'b0110101111000001;
    mix_col_indecies_F13[0][3] = 16'b1111000001011010;
    mix_col_indecies_F13[1][3] = 16'b0011010010011110;
    mix_col_indecies_F13[2][3] = 16'b0111100011010010;
    mix_col_indecies_F13[3][3] = 16'b1011110000010110;

    writing_on_aes_tmp_memory = 0;




            
end
            
localparam                                              config_width                      = 128;
localparam                                              config_depth                      = 10;
localparam                                              input_data_bytes_count                      = 24;
localparam                                              address_len                      = 24;
localparam                                              q_full                      = 24;
localparam                                              main_memory_depth                               = 100_000;
localparam                                              msa_input_bus_register_gcm                      = 10_000;
localparam                                              msa_work_bus_register_gcm                       = 10_100;
localparam                                              msa_output_bus_register_gcm                     = 30_000;



    reg                                             		main_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				main_mem_read_addr      ;
    wire                [8 - 1 	 : 0]    				main_mem_read_data      ;
    reg                                             		main_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				main_mem_write_addr     ;
    reg                 [8 - 1 	 : 0]    				main_mem_write_data     ;

    memory_list #(
        .mem_width(8),
        .address_len(address_len),
        .mem_depth(main_memory_depth),
        .initial_file("./input.txt")

    ) main_mem(
        .clk(clk),
        .r_en(  main_mem_read_enable),
        .r_addr(main_mem_read_addr),
        .r_data(main_mem_read_data),
        .w_en(  main_mem_write_enable),
        .w_addr(main_mem_write_addr),
        .w_data(main_mem_write_data)
    );

    
    
wire            clk_expand_keys;
wire            clk_aes;
wire            clk_gcm;

assign          clk_expand_keys = clk;
assign          clk_aes = clk;
assign          clk_gcm = clk;

reg             finished_expand_keys;
reg             finished_aes;
reg             finished_gcm;

reg             reset_expand_keys;
reg             reset_aes;
reg             reset_gcm;


                
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




































































































































































































            

endmodule


            