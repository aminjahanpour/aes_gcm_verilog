

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


                