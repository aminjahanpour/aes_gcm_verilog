
        

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
            