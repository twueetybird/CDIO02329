-- This is the component that you'll need to fill in in order to create the LC3 computer.
-- It is FPGA independent. It can be used without any changes between the Zybo and the 
-- Nexys3 boards.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lc3_computer is
   port (
		--System clock
      clk              : in  std_logic; 

      --Virtual I/O
      led              : out std_logic_vector(7 downto 0);
      btn              : in  std_logic_vector(4 downto 0);
      sw               : in  std_logic_vector(7 downto 0);
      hex              : out std_logic_vector(15 downto 0); --16 bit hexadecimal value (shown on 7-seg sisplay)

		--Physical I/0 (IO on the Zybo FPGA)
		pbtn				  : in  std_logic_vector(3 downto 0);
		psw				  : in  std_logic_vector(3 downto 0);
		pled				  : out  std_logic_vector(2 downto 0);

		--VIO serial
		rx_data          : in  std_logic_vector(7 downto 0);
      rx_rd            : out std_logic;
      rx_empty         : in  std_logic;
      tx_data          : out std_logic_vector(7 downto 0);
      tx_wr            : out std_logic;
      tx_full          : in  std_logic;
		
		sink             : out std_logic;

      --Debug
      address_dbg      : out std_logic_vector(15 downto 0);
      data_dbg         : out std_logic_vector(15 downto 0);
      RE_dbg           : out std_logic;
      WE_dbg           : out std_logic;
		
		--LC3 CPU inputs
      cpu_clk_enable   : in  std_logic;
      sys_reset        : in  std_logic;
      sys_program      : in  std_logic
   );
end lc3_computer;

architecture Behavioral of lc3_computer is
   ---<<<<<<<<<<<<<<>>>>>>>>>>>>>>>---
   ---<<<<< Pregenerated code >>>>>---
   ---<<<<<<<<<<<<<<>>>>>>>>>>>>>>>---

	--Making	sure	that	our	output	signals	are	not	merged/removed	during	
	-- synthesis. We	achieve	this	by	setting	the keep	attribute for	all	our	outputs
	-- It's good to uncomment the following attributs if you get some errors with multiple 
	-- drivers for a signal.
--	attribute	keep:string;
--	attribute	keep	of	led			: signal	is	"true";
--	attribute	keep	of	pled			: signal	is	"true";
--	attribute	keep	of	hex			: signal	is	"true";
--	attribute	keep	of	rx_rd			: signal	is	"true";
--	attribute	keep	of	tx_data		: signal	is	"true";
--	attribute	keep	of	tx_wr			: signal	is	"true";
--	attribute	keep	of	address_dbg	: signal	is	"true";
--	attribute	keep	of	data_dbg		: signal	is	"true";
--	attribute	keep	of	RE_dbg		: signal	is	"true";
--	attribute	keep	of	WE_dbg		: signal	is	"true";
--	attribute	keep	of	sink			: signal	is	"true";

   --Creating user friently names for the buttons
   alias btn_u : std_logic is btn(0); --Button UP
   alias btn_l : std_logic is btn(1); --Button LEFT
   alias btn_d : std_logic is btn(2); --Button DOWN
   alias btn_r : std_logic is btn(3); --Button RIGHT
   alias btn_s : std_logic is btn(4); --Button SELECT (center button)
   alias btn_c : std_logic is btn(4); --Button CENTER
   
   signal sink_sw : std_logic;
   signal sink_psw : std_logic;
   signal sink_btn : std_logic;
   signal sink_pbtn : std_logic;
	signal sink_uart : std_logic;
   
	-- Memory interface signals
	signal address: std_logic_vector(15 downto 0);
	signal data, data_in, data_out: std_logic_vector(15 downto 0); -- data inputs
	signal RE, WE:  std_logic;


	-- I/O constants for addr from 0xFE00 to 0xFFFF:
   constant STDIN_S    : std_logic_vector(15 downto 0) := X"FE00";  -- Serial IN (terminal keyboard)
   constant STDIN_D    : std_logic_vector(15 downto 0) := X"FE02";
   constant STDOUT_S   : std_logic_vector(15 downto 0) := X"FE04";  -- Serial OUT (terminal  display)
   constant STDOUT_D   : std_logic_vector(15 downto 0) := X"FE06";
	constant IO_SW      : std_logic_vector(15 downto 0) := X"FE0A";  -- Switches
   constant IO_PSW     : std_logic_vector(15 downto 0) := X"FE0B";  -- Physical Switches	
	constant IO_BTN     : std_logic_vector(15 downto 0) := X"FE0e";  -- Buttons
 	constant IO_PBTN    : std_logic_vector(15 downto 0) := X"FE0F";  -- Physical Buttons	
	constant IO_SSEG    : std_logic_vector(15 downto 0) := X"FE12";  -- 7 segment
	constant IO_LED     : std_logic_vector(15 downto 0) := X"FE16";  -- Leds
	constant IO_PLED    : std_logic_vector(15 downto 0) := X"FE17";  -- Physical Leds
   
	---<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>---
   ---<<<<< End of pregenerated code >>>>>---
   ---<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>---
type ram_type is array (0 to ((2**16)-1)) of std_logic_vector (15 downto 0);

signal ram : ram_type:=(
-- Empty Traps/Interrupt Tables
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 0 - 7
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 8 - 15
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 16 - 23
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 24 - 31
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 32 - 39
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 40 - 47
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 48 - 55
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 56 - 63
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 64 - 71
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 72 - 79
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 80 - 87
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 88 - 95
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 96 - 103
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 104 - 111
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 112 - 119
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 120 - 127
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 128 - 135
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 136 - 143
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 144 - 151
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 152 - 159
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 160 - 167
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 168 - 175
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 176 - 183
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 184 - 191
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 192 - 199
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 200 - 207
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 208 - 215
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 216 - 223
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 224 - 231
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 232 - 239
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 240 - 247
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 248 - 255
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 256 - 263
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 264 - 271
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 272 - 279
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 280 - 287
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 288 - 295
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 296 - 303
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 304 - 311
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 312 - 319
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 320 - 327
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 328 - 335
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 336 - 343
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 344 - 351
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 352 - 359
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 360 - 367
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 368 - 375
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 376 - 383
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 384 - 391
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 392 - 399
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 400 - 407
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 408 - 415
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 416 - 423
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 424 - 431
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 432 - 439
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 440 - 447
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 448 - 455
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 456 - 463
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 464 - 471
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 472 - 479
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 480 - 487
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 488 - 495
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 496 - 503
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 504 - 511
-- Serial Port Program loader    (512-767)
X"2407", X"6080", X"07fe", X"6082", X"6284", X"07fe", X"7086", X"0ff9",  -- addr 512 - 519
X"fe00", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 520 - 527
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 528 - 535
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 536 - 543
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 544 - 551
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 552 - 559
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 560 - 567
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 568 - 575
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 576 - 583
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 584 - 591
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 592 - 599
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 600 - 607
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 608 - 615
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 616 - 623
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 624 - 631
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 632 - 639
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 640 - 647
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 648 - 655
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 656 - 663
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 664 - 671
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 672 - 679
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 680 - 687
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 688 - 695
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 696 - 703
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 704 - 711
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 712 - 719
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 720 - 727
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 728 - 735
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 736 - 743
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 744 - 751
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 752 - 759
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 760 - 767
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 768 - 775
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 776 - 783
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 784 - 791
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 792 - 799
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 800 - 807
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 808 - 815
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 816 - 823
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 824 - 831
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 832 - 839
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 840 - 847
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 848 - 855
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 856 - 863
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 864 - 871
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 872 - 879
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 880 - 887
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 888 - 895
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 896 - 903
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 904 - 911
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 912 - 919
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 920 - 927
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 928 - 935
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 936 - 943
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 944 - 951
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 952 - 959
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 960 - 967
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 968 - 975
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 976 - 983
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 984 - 991
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 992 - 999
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1000 - 1007
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1008 - 1015
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1016 - 1023
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1024 - 1031
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1032 - 1039
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1040 - 1047
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1048 - 1055
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1056 - 1063
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1064 - 1071
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1072 - 1079
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1080 - 1087
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1088 - 1095
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1096 - 1103
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1104 - 1111
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1112 - 1119
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1120 - 1127
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1128 - 1135
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1136 - 1143
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1144 - 1151
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1152 - 1159
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1160 - 1167
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1168 - 1175
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1176 - 1183
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1184 - 1191
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1192 - 1199
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1200 - 1207
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1208 - 1215
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1216 - 1223
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1224 - 1231
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1232 - 1239
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1240 - 1247
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1248 - 1255
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1256 - 1263
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1264 - 1271
X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",  -- addr 1272 - 1279
-- Start of user program         (1280-...)
X"2405", X"608a", X"7092", X"608e", X"7096", X"0ffb", X"fe00",  -- addr 1280 - 1286
 others => X"0000");
 
signal addr_reg: std_logic_vector(15 downto 0);

signal hex_reg : std_logic_vector(15 downto 0);

signal sel : std_logic_vector (1 downto 0 );

signal WE_segg : std_logic;


begin
  ---<<<<<<<<<<<<<<>>>>>>>>>>>>>>>---
   ---<<<<< Pregenerated code >>>>>---
   ---<<<<<<<<<<<<<<>>>>>>>>>>>>>>>--- 
   
   --In order to avoid warnings or errors all outputs should be assigned a value. 
   --The VHDL lines below assign a value to each otput signal. An otput signal can have
   --only one driver, so each otput signal that you plan to use in your own VHDL code
   --should be commented out in the lines below 

   
   --Virtual Leds on Zybo VIO (active high)
   led(0) <= '0';
   led(1) <= '0';
   led(2) <= '0'; 
   led(3) <= '0'; 
   led(4) <= '0'; 
   led(5) <= '0'; 
   led(6) <= '0'; 
   led(7) <= '0'; 

   --Physical leds on the Zybo board (active high)
   pled(0) <= '0';
   pled(1) <= '0';
   pled(2) <= '0';

   --Virtual hexadecimal display on Zybo VIO
   --hex <= X"1234"; 

	--Virtual I/O UART
	rx_rd <= '0';
	tx_wr <= '0';
	tx_data <= X"00";
	
	--Input data for the LC3 CPU
	--data_in <= X"0000";

   --All the input signals comming to the FPGA should be used at least once otherwise we get 
   --synthesis warnings. The following lines of VHDL code are meant to remove those warnings. 
   --Sink is just an output signal that that has the only purpose to allow all the inputs to 
   --be used at least once, by orring them and assigning the resulting the value to sink.
   --You are not suppoosed to modify the following lines of VHDL code, where inputs are orred and
   --assigned to the sink. 
   sink_psw <= psw(0) or psw(1) or psw(2) or psw(3);
   sink_pbtn <= pbtn(0) or pbtn(1) or pbtn(2) or pbtn(3);
   sink_sw <= sw(0) or sw(1) or sw(2) or sw(3) or sw(4) or sw(5) or sw(6) or sw(7); 
   sink_btn <= btn(0) or btn(1) or btn(2) or btn(3) or btn(4);
	sink_uart <= rx_data(0) or rx_data(1) or rx_data(2) or rx_data(3) or rx_data(4) or 
					 rx_data(5) or rx_data(6) or rx_data(7)or rx_empty or tx_full; 
   sink <= sink_sw or sink_psw or sink_btn or sink_pbtn or sink_uart;

   ---<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>---
   ---<<<<< End of pregenerated code >>>>>---
   ---<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>---
	
	--You'll have to decide which type of data bus you need to use for the
	--  LC3 processor. Here are the options:
	-- 1. Bidirectional data bus (to which you write using tristates).
	-- 2. Two unidirctional busses data_in and data_out where you use
	--    multiplexors to dicide where the data for data_in is comming for.
	--The VHDL code that instantiate either one of these options for the LC3
	--  processor are provided below. Just uncomment the one you prefer
	
	-- <<< LC3 CPU using multiplexers for the data bus>>>	
	lc3_m: entity work.lc3_wrapper_multiplexers
	port map (
		 clk        => clk,
		 clk_enable => cpu_clk_enable,
		 reset      => sys_reset,
		 program    => sys_program,
		 addr       => address,
		 data_in    => data_out,
		 data_out   => data_in,
		 WE         => WE,
		 RE         => RE 
		 );
   data_dbg <= data_out when RE='1' else data_in;
	-- <<< LC3 CPU using multiplexers end of instantiation>>>	
	
		 
--	-- <<< LC3 CPU using tristates for the data bus>>>
--	lc3_t: entity work.lc3_wrapper_tristates
--	port map (
--		 clk        => clk,
--		 clk_enable => cpu_clk_enable,
--		 reset      => sys_reset,
--		 program    => sys_program,
--		 addr       => address,
--		 data       => data,
--		 WE         => WE,
--		 RE         => RE 
--		 );
--   data_dbg <= data;
--	-- <<< LC3 CPU using tristates end of instantiation>>>
	
	--Information that is sent to the debugging module
   address_dbg <= address;
   RE_dbg <= RE;
   WE_dbg <= WE;
   
	-------------------------------------------------------------------------------
	-- <<< Write your VHDL code starting from here >>>
	-------------------------------------------------------------------------------

   process (clk)
   begin
      if (clk'event and clk = '1') then
         if (WE='1') then
            ram(to_integer(unsigned(address))) <= data_in;
            end if;
         addr_reg <= address;
      end if;
   end process;
   
   hex_register: process (clk)
   begin
        if clk'event and clk='1' then
            if WE_segg='1' then
                hex_reg <= data_in;
        end if;
     end if;
   end process hex_register;
   
        hex <= hex_reg;
   
   process(address,RE, WE)
   begin
        WE_segg <= '0';
        if address = IO_SW then -- Switchs
            data_out <= "00000000" & sw;
        elsif address = IO_SSEG and WE='1' then --7 Seggment
            WE_segg <= '1';
        else --RAM
            data_out <= ram(to_integer(unsigned(addr_reg)));
        end if;
   end process;

   

end Behavioral;

