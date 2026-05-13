
# code for spi_baud_generator.v

  ...
  module spi_baud_generator(PCLK,PRESET_n,spi_mode_i,spiswai_i,sppr_i,spr_i,cpol_i,cpha_i,ss_i,SCLK_o,BaudRateDivisor_o,miso_receive_sclk_o,miso_receive_sclk0_o,mosi_send_sclk_o,mosi_send_sclk0_o);
	input PCLK,PRESET_n,spiswai_i,cpol_i,cpha_i,ss_i;
	input [1:0]spi_mode_i;
	input [2:0]sppr_i,spr_i;
	output reg SCLK_o,miso_receive_sclk_o,miso_receive_sclk0_o,mosi_send_sclk_o,mosi_send_sclk0_o;
	output [11:0]BaudRateDivisor_o;
	wire pre_sclk_s;
	reg [11:0]count_s;


	assign BaudRateDivisor_o =(sppr_i+1'b1)*(2**(spr_i+1'b1));
	assign pre_sclk_s =(cpol_i)? 1'b1:1'b0;
		
	always@(posedge PCLK,negedge PRESET_n)
		begin
			if(!PRESET_n)
			begin
				count_s<=12'b0;
				SCLK_o<=pre_sclk_s;
			end
			
			else if((!ss_i)&&(!spiswai_i)&&((spi_mode_i==2'b00)||(spi_mode_i==2'b01)))
				begin
					if(count_s==((BaudRateDivisor_o/2)-1))
					begin
						SCLK_o<=~SCLK_o;
						count_s<=12'b0;
					end
					else
						count_s<=count_s+1'b1;
				end
			else
			begin
				SCLK_o<=pre_sclk_s;
				count_s<=12'b0;
			end
		end
	always@(posedge PCLK,negedge PRESET_n)
		begin
		if(!PRESET_n)
		begin
			miso_receive_sclk_o<=1'b0;
			miso_receive_sclk0_o<=1'b0;
		end
			else if((!cpha_i && cpol_i)||(cpha_i && !cpol_i))
			begin
				if(SCLK_o)
				begin
					if(count_s==((BaudRateDivisor_o/2)-1))
				
						miso_receive_sclk0_o<=1'b1;
					else
					miso_receive_sclk0_o<=1'b0;
				end
		         	else
				miso_receive_sclk0_o<=1'b0;
			end
			else if((!cpha_i && !cpol_i)||(cpha_i && cpol_i))
			begin
				if(!SCLK_o)
				begin
					if(count_s==((BaudRateDivisor_o/2)-1))
				
						miso_receive_sclk_o<=1'b1;
					else
					miso_receive_sclk_o<=1'b0;
				end
		        	else
				miso_receive_sclk_o<=1'b0;
			end
			else 
			begin
			miso_receive_sclk_o<=1'b0;
			miso_receive_sclk0_o<=1'b0;
		        end
  

	end
	always@(posedge PCLK,negedge PRESET_n)
		begin
		if(!PRESET_n)
		begin
			mosi_send_sclk_o<=1'b0;
			mosi_send_sclk0_o<=1'b0;
		end
			else if((!cpha_i && cpol_i)||(cpha_i && !cpol_i))
			begin
				if(SCLK_o)
				begin
					if(count_s==((BaudRateDivisor_o/2)-2))
				
						mosi_send_sclk0_o<=1'b1;
					else
					mosi_send_sclk0_o<=1'b0;
				end
		         	else
				mosi_send_sclk0_o<=1'b0;
			end
			else if((!cpha_i && !cpol_i)||(cpha_i && cpol_i))
			begin
				if(!SCLK_o)
				begin
					if(count_s==((BaudRateDivisor_o/2)-2))
				
						mosi_send_sclk_o<=1'b1;
					else
					mosi_send_sclk_o<=1'b0;
				end
		        	else
				mosi_send_sclk_o<=1'b0;
			end
			else 
			begin
			mosi_send_sclk_o<=1'b0;
			mosi_send_sclk0_o<=1'b0;
		        end
  

	end
	
endmodule

...


#code for spi_shifter.v

  ...
  module spi_shifter(PCLK,PRESET_n,ss_i,send_data_i,lsbfe_i,cpha_i,cpol_i,miso_receive_sclk_i,miso_receive_sclk0_i,data_mosi_i,miso_i,receive_data_i,mosi_o,data_miso_o,mosi_send_sclk_i,mosi_send_sclk0_i);
	input [7:0]data_mosi_i;
	input PCLK,PRESET_n,ss_i,send_data_i,lsbfe_i,cpha_i,cpol_i,miso_receive_sclk_i,miso_receive_sclk0_i,miso_i,mosi_send_sclk_i,mosi_send_sclk0_i;
	input receive_data_i;
	output reg mosi_o;
	output reg [7:0]data_miso_o;
	reg [7:0]shift_register,temp_reg;
	reg [2:0]count,count1;
	reg [2:0]count2,count3;

	always@(posedge PCLK or negedge PRESET_n)
	begin
		if(!PRESET_n)
			shift_register<=8'b00000000;
		else 
			begin
				if(send_data_i==1)
					shift_register<=data_mosi_i;
				else
					shift_register<=shift_register;
			end
	end
	always@(*)
	begin
		if(receive_data_i==1)
			data_miso_o=temp_reg;
		else
			data_miso_o=8'b00000000;
	end
	//transmite data bit by bit(mosi)...
	always@(posedge PCLK or negedge PRESET_n)
	begin
		if(!PRESET_n)
		begin
			mosi_o<=1'b0;
			count<=3'b000;
		        count1<=3'b111;
			end
		else if(!ss_i)
		begin
			if((!cpha_i && cpol_i)||(cpha_i && !cpol_i))
			begin
				if(lsbfe_i)
				begin
					if(count<=3'd7)
					begin
						if(mosi_send_sclk_i)
							begin
								mosi_o<=shift_register[count];
								count<=count+1'b1;
							end
						end
						else
							count<=3'b0;
					
					end
				else
				begin
					if(count1>=3'b0)
					begin
						if(mosi_send_sclk_i)
						begin
							mosi_o<=shift_register[count1];
							count1<=count1-1'b1;
						end
					end
					else
						count1<=3'd7;
				end
			end
			else
			begin
				if(lsbfe_i)
				begin
					if(count<=3'd7)
					begin
						if(mosi_send_sclk0_i)
						begin
							mosi_o<=shift_register[count];
							count<=count+1'b1;
						end
					end
					else
						count<=3'b0;
				end
				else
				begin
					if(count1>=3'b0)
					begin
						if(mosi_send_sclk0_i)
						begin
							mosi_o<=shift_register[count1];
							count1<=count1-1'b1;
						end
					end
					else
						count1<=3'd7;
				end
			end
		end
	end
	
	//receive data bit by bit(miso)

	always@(posedge PCLK or negedge PRESET_n)
	begin
		if(!PRESET_n)
		begin
			temp_reg<=8'b0;
			count2<=3'b0;
			count3<=3'd7;
		end
		else if(!ss_i)
		begin
			if((!cpha_i && cpol_i)||(cpha_i && !cpol_i))
			begin
				if(lsbfe_i)
				begin
					if(count2<=3'd7)
					begin
						if(miso_receive_sclk0_i)
						begin
							temp_reg[count2]<=miso_i;
							count2<=count2+1'b1;
						end
					end
					else
						count2<=3'b0;
				end
				else
				begin
					if(count3>=3'b0)
					begin
						if(miso_receive_sclk0_i)
						begin
							temp_reg[count3]<=miso_i;
							count3<=count3-1'b1;
						end
					end
					else
						count3<=3'd7;
				end
			end
			else
			begin
				if(lsbfe_i)
				begin
					if(count2<=3'd7)
					begin
						if(miso_receive_sclk_i)
						begin
							temp_reg[count2]<=miso_i;
							count2<=count2+1'b1;
						end
					end
					else
						count2<=3'b0;
				end
				else
				begin
					if(count3>=3'b0)
					begin
						if(miso_receive_sclk_i)
						begin
							temp_reg[count3]<=miso_i;
							count3<=count3-1'b1;
						end
					end
					else
						count3<=3'd7;
				end
			end
		end
	end

							
					
endmodule

...

# code for spi_slave_interface.v

  '''
  module spi_slave_interface(pclk, preset_n, paddr_i, pwrite_i, psel_i, penable_i, pwdata_i, ss_i, miso_data_i, rec_data_i, tip_i,
prdata_o, mstr_o, cpol_o, cpha_o, lsbfe_o, spiswai_o, sppr_o, spr_o, spi_int_req_o, pready_o, pslverr_o, send_data_o,
mosi_data_o, spi_mode_o);
	input pclk, preset_n, pwrite_i, psel_i, penable_i, ss_i, rec_data_i, tip_i;
	input [2:0]paddr_i;
	input [7:0]pwdata_i,miso_data_i;
	output mstr_o, cpol_o, cpha_o, lsbfe_o, spiswai_o, pready_o, pslverr_o;
	output reg spi_int_req_o;
	output reg send_data_o;
	output reg[7:0]mosi_data_o;
	output reg [1:0]spi_mode_o;
	output reg[7:0]prdata_o;
	output[2:0]sppr_o, spr_o;
	reg [1:0]state, next_state; //APB state
	reg [1:0]nmode; //SPI mode state
	reg [7:0]spi_cr1, spi_cr2, spi_br, spi_dr;
	reg [7:0]spi_sr;
	wire wr_enb,rd_enb;
	wire spie, spe, sptie, ssoe_o;
	wire modfen;
	wire spif;
	wire sptef;
	wire modf;
	wire [7:0]spi_cr2_mask=8'b00011011;
	wire [7:0]spi_br_mask=8'b01110111;
	assign modf=~ss_i && ~ssoe_o && mstr_o && modfen;
	assign sptef=(spi_dr==8'b0)?1'b1:1'b0;
	assign spif=(spi_dr==8'b0)?1'b1:1'b0;
	assign mstr_o=spi_cr1[4];
	assign cpol_o=spi_cr1[3];
	assign cpha_o=spi_cr1[2];
	assign lsbfe_o=spi_cr1[0];assign spie=spi_cr1[7];
	assign spe=spi_cr1[6];
	assign sptie=spi_cr1[5];
	assign modfen=spi_cr2[4];
	assign spiswai_o=spi_cr2[1];
	assign sppr_o=spi_br[6:4];
	assign spr_o=spi_br[2:0];
	assign ssoe_o=spi_cr1[1];
	parameter
		idle=2'b00,
		setup=2'b01,
		enable=2'b10;
	parameter
		spi_run=2'b00,
		spi_wait=2'b01,
		spi_stop=2'b10;
	//APB FSM
	always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
		state<=idle;
		else
		state<=next_state;
	end
	always@(*)
	begin
		case(state)
		idle:
		begin
			if(psel_i && !penable_i) next_state=setup;
			else next_state=idle;
		end
		setup:
		begin
			if(psel_i && penable_i) next_state=enable;
			else if(psel_i && !penable_i) next_state=setup;
			else next_state=idle;
		end
		enable:
		begin
			if(psel_i) next_state=setup;
			else next_state=idle;
		end
		default: next_state=idle;
	endcase
	end
//SPI FSM
	always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
		spi_mode_o<=spi_run;
		else
			spi_mode_o<=nmode;
		end
		always@(*)
		begin
			case(spi_mode_o)
			spi_run:
			begin
				if(!spe) nmode=spi_wait;
				else nmode=spi_run;
			end
			spi_wait:
			begin
				if(spiswai_o) nmode=spi_stop;
				else if(spe) nmode=spi_run;
				else nmode=spi_wait;
				end
			spi_stop:
			begin
				if(!spiswai_o) nmode=spi_wait;
				else if(spe) nmode=spi_run;
				else nmode=spi_stop;
			end
			default: nmode=spi_run;
			endcase
			end
//spi sr register
//assign spi_sr=(preset_n)?8'b00100000:{spif,1'b0,sptef,modf,4'b0};
/*always@(*)
begin
if(preset_n)
spi_sr<=8'b00100000;
else
spi_sr<={spif,1'b0,sptef,modf,4'b0};
end*/
//send data out
	always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
		send_data_o<=0;else
		begin
			if(wr_enb)
			send_data_o<=1'b0;
			else
			begin
				if(spi_dr==pwdata_i && spi_dr!=miso_data_i &&(spi_mode_o==2'b00 || spi_mode_o==2'b01))
				send_data_o<=1'b1;
				else
				send_data_o<=1'b0;
			end
		end
	end
//mosi data out
	always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
		mosi_data_o<=8'b0;
		else
		begin
			if(spi_dr==pwdata_i && spi_dr!=miso_data_i && (spi_mode_o==2'b00 ||spi_mode_o==2'b01))
			mosi_data_o<=spi_dr;
		else
		mosi_data_o<=mosi_data_o;
		end
	end
//SPI Data Register
	always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)spi_dr<=8'b0;
		else
		begin
			if(wr_enb)
			begin
				if(paddr_i==3'b101)
				spi_dr<=pwdata_i;
				else
				spi_dr<=spi_dr;
			end
			else
			begin
				if(spi_dr==pwdata_i && spi_dr!=miso_data_i &&(spi_mode_o==2'b00 || spi_mode_o==2'b01))
				spi_dr<=8'b0;
				else
				begin
					if((spi_mode_o==2'b00 ||spi_mode_o==2'b01) && rec_data_i)
						spi_dr<=miso_data_i;
				else
				spi_dr<=spi_dr;
				end
			end
		end
	end
//SPI Interuppt Request Signal
	always@(*)
	begin
		spi_int_req_o = 1'b0;
		if(!spie && !sptie)
			spi_int_req_o=0;
		else if(spie && !sptie)
		begin
			if(spif || modf)spi_int_req_o=1'b1;
		end
		else if(sptie && !spie)
			spi_int_req_o=sptef;
		else
		begin
			if(spif || modf || sptef)
			spi_int_req_o=1'b1;
		end
	end
//prdata_i
	always@(*)
	begin
		if(rd_enb)
		begin
			case(paddr_i)
			3'b000:prdata_o=spi_cr1;
			3'b001:prdata_o=spi_cr2;
			3'b010:prdata_o=spi_br;
			3'b011:prdata_o=spi_sr;
			3'b100:prdata_o=8'b0;
			3'b101:prdata_o=spi_dr;
			3'b110:prdata_o=8'b0;
			3'b111:prdata_o=8'b0;
		endcase
		end
		else
		prdata_o=8'b0;
	end
//spi_cr1 register
	always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
			spi_cr1<=8'h04;
		else
		begin
			if(wr_enb)
			begin
				if(paddr_i==3'b000)
					spi_cr1<=pwdata_i;
				else
					spi_cr1<=spi_cr1;
			end
			else
			spi_cr1<=spi_cr1;
		end
	end
//spi_cr2 register
	always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
		spi_cr2<=8'h0;
		else
		begin
			if(wr_enb)
			begin
				if(paddr_i==3'b001)
				spi_cr2<=pwdata_i & spi_cr2_mask;
				else
				spi_cr2<=spi_cr2;
			end
			else
			spi_cr2<=spi_cr2;
		end
	end
//spi_br register
	always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
			spi_br<=8'h00;
		else
		begin
			if(wr_enb)
			begin
				if(paddr_i==3'b010)
					spi_br<=pwdata_i & spi_br_mask;
				else
				spi_br<=spi_br;
			end
			else
			spi_br<=spi_br;
		end
	end
	assign pready_o=(state==enable)?1'b1:1'b0;
	assign pslverr_o=(state==enable)?(tip_i):1'b0;
	assign wr_enb=(pwrite_i && state==enable)?1'b1:1'b0;
	assign rd_enb=(!pwrite_i && state==enable)?1'b1:1'b0;
//spi_sr register
	always@(*)
	begin
		if(!preset_n)
		spi_sr<=8'b00100000;
		else
			spi_sr<={spif,1'b0,sptef,modf,4'b0};
	end
endmodule

'''

#code for spi_slave_select.v

  '''
  module spi_slave_select(PCLK,PRESET_n,mstr_i,send_data_i,spiswai_i,spi_mode_i,ss_o,baudratedivisor_i,tip_o,receive_data_o);
	input PCLK,PRESET_n,mstr_i,send_data_i,spiswai_i;
	input [1:0]spi_mode_i;
	input [11:0]baudratedivisor_i;
	output reg ss_o,receive_data_o;
	output tip_o;
	reg [15:0]count_s;
	wire [15:0] target_s;
	reg rcv_s;
	
	
	assign target_s =(8*baudratedivisor_i);
	assign tip_o = ~ss_o;

	always@(posedge PCLK or negedge PRESET_n)
	begin
		if(!PRESET_n)
		begin
			count_s<=16'hffff;
			ss_o<=1'b1;
			rcv_s<=1'b0;
		end
		else if(mstr_i && (spi_mode_i==2'b00)||(spi_mode_i==2'b01) && (!spiswai_i))
		begin
			if(send_data_i)
			begin
				ss_o<=0;
		    		count_s<=16'h0;
			end
			else if(count_s < (target_s-1'b1))
			begin
				ss_o<=0;
				count_s<=count_s+16'h1;
				rcv_s<=1'b0;
			end
			 else if(count_s==(target_s-1'b1))
			 begin
			   
				 rcv_s<=1'b1;
				 count_s <= 16'hffff;
				 ss_o<=1;
			 end
			 else
			 begin
				 ss_o<=1;
			 	 rcv_s<=0;
			 	 count_s<=16'hFFFF;	 
			 end
		 end
		else
		begin
			ss_o<=1;
			rcv_s<=0;
			count_s<=16'hFFFF;
		end
	end
	always@(posedge PCLK or negedge PRESET_n)
	begin
		if(!PRESET_n)
		begin
			receive_data_o<=1'b0;
		end
		else
			receive_data_o<=rcv_s;
	end
endmodule
			
'''

# code for spi_top_module.v

  '''
  module spi_top_module(PCLK,PRESET_n,PADDR_i,PWRITE_i,PSEL_i,PENABLE_i,PWDATA_i,miso_i,PRDATA_o,PREADY_o,PSLVERR_o,SCLK_o,mosi_o,ss_o,spi_interrupt_request_o);
	input PCLK,PRESET_n,PSEL_i,PWRITE_i,PENABLE_i,miso_i;
	input [2:0]PADDR_i;
	input [7:0]PWDATA_i;
	output [7:0]PRDATA_o;
	output PREADY_o,PSLVERR_o,SCLK_o,ss_o,mosi_o,spi_interrupt_request_o;

// internal connections

	wire mstr_w,cpol_w,cpha_w,lsbfe_w,spiswai_w;
	wire [2:0]sppr_w,spr_w;
	wire [1:0]spi_mode_w;
	
	wire send_data_w,rec_data_w;
	wire [7:0]miso_data_w,mosi_data_w;

	wire miso_r_sclk_w;
	wire miso_r_sclk0_w;
	wire mosi_s_sclk_w;
	wire mosi_s_sclk0_w;

	wire [11:0]brd_w;
	wire tip_w;

	spi_slave_interface si (
	.pclk(PCLK),
	.preset_n(PRESET_n),
	.paddr_i(PADDR_i),
	.pwrite_i(PWRITE_i),
	.psel_i(PSEL_i),
	.penable_i(PENABLE_i),
	.pwdata_i(PWDATA_i),
	.ss_i(ss_o),
	.miso_data_i(miso_data_w),
	.rec_data_i(rec_data_w),
	.tip_i(tip_w),
	.prdata_o(PRDATA_o),
	.mstr_o(mstr_w),
	.cpol_o(cpol_w),
	.cpha_o(cpha_w),
	.lsbfe_o(lsbfe_w),
	.spiswai_o(spiswai_w),
	.sppr_o(sppr_w),
	.spr_o(spr_w),
	.spi_int_req_o(spi_interrupt_request_o),
	.pready_o(PREADY_o),
	.pslverr_o(PSLVERR_o),
	.send_data_o(send_data_w),
	.mosi_data_o(mosi_data_w),
	.spi_mode_o(spi_mode_w));

	spi_baud_generator bg(
	.PCLK(PCLK),
	.PRESET_n(PRESET_n),
	.spi_mode_i(spi_mode_w),
	.spiswai_i(spiswai_w),
	.sppr_i(sppr_w),
	.spr_i(spr_w),
	.cpol_i(cpol_w),
	.cpha_i(cpha_w),
	.ss_i(ss_o),
	.SCLK_o(SCLK_o),
	.miso_receive_sclk_o(miso_r_sclk_w),
	.miso_receive_sclk0_o(miso_r_sclk0_w),
	.mosi_send_sclk_o(mosi_s_sclk_w),
	.mosi_send_sclk0_o(mosi_s_sclk0_w),
	.BaudRateDivisor_o(brd_w));

   spi_shifter s(
	.PCLK(PCLK),
	.PRESET_n(PRESET_n),
	.ss_i(ss_o),
	.send_data_i(send_data_w),
	.lsbfe_i(lsbfe_w),
	.cpha_i(cpha_w),
	.cpol_i(cpol_w),
	.miso_receive_sclk_i(miso_r_sclk_w),
	.miso_receive_sclk0_i(miso_r_sclk0_w),
	.mosi_send_sclk_i(mosi_s_sclk_w),
	.mosi_send_sclk0_i(mosi_s_sclk0_w),
	.data_mosi_i(mosi_data_w),
	.miso_i(miso_i),
	.receive_data_i(rec_data_w),
	.mosi_o(mosi_o),
	.data_miso_o(miso_data_w));

   spi_slave_select ss(
	.PCLK(PCLK),
	.PRESET_n(PRESET_n),
	.mstr_i(mstr_w),
	.spiswai_i(spiswai_w),
	.spi_mode_i(spi_mode_w),
	.send_data_i(send_data_w),
	.baudratedivisor_i(brd_w),
	.receive_data_o(rec_data_w),
	.ss_o(ss_o),
	.tip_o(tip_w));


endmodule

...

 





									





	

									



