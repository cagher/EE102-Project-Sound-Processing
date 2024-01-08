----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.11.2023 17:41:47
-- Design Name: 
-- Module Name: Project_pro - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.MATH_REAL.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Project_pro is
    Port ( JXADC : in STD_LOGIC_VECTOR (7 downto 0);
           JC : out STD_LOGIC_VECTOR(7 downto 0);
           led : out STD_LOGIC_VECTOR(15 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0);
           seg : out STD_LOGIC_VECTOR(6 downto 0);
           sw : in STD_LOGIC_VECTOR(15 downto 0);
           clk : in std_logic;
           btnC : in std_logic;
           btnU : in std_logic;
           btnD : in std_logic
    );
end Project_pro;

architecture Behavioral of Project_pro is
    component xadc_wiz_0 is
   port
   (
    daddr_in        : in  STD_LOGIC_VECTOR (6 downto 0);     -- Address bus for the dynamic reconfiguration port
    den_in          : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
    di_in           : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
    dwe_in          : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
    do_out          : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    drdy_out        : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
    dclk_in         : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
    reset_in        : in  STD_LOGIC;                         -- Reset signal for the System Monitor control logic
    vauxp6          : in  STD_LOGIC;                         -- Auxiliary Channel 5
    vauxn6          : in  STD_LOGIC;
    busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
    channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
    eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
    eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
    alarm_out       : out STD_LOGIC;                         -- OR'ed output of all the Alarms
    vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
    vn_in           : in  STD_LOGIC
    );
    end component;
    
    component Freq_finder is
    Port ( samp : in STD_LOGIC_VECTOR (11 downto 0);
           clock : in STD_LOGIC;
           freq : out std_logic_vector(63 downto 0));
    end component;
    
    
    signal do_out : std_logic_vector(15 downto 0);
    signal cout : std_logic_vector(4 downto 0);
    signal daddr_in : std_logic_vector(6 downto 0);
    signal eoc_out : std_logic;
    signal vanal_p, vanal_n : std_logic;
    signal drdy : std_logic;
    signal counter : std_logic_vector(17 downto 0) := (others => '0');
    signal btn_counter : std_logic_vector(26 downto 0);
    signal freq : std_logic_vector(63 downto 0);
    signal transpose : integer range -3 to 3 := 0;
    signal an_select : std_logic;
    signal display : std_logic_vector(13 downto 0);
    signal JC_buffer : std_logic_vector(1 downto 0) := "10";
    signal period, intfreq, period_count, maj3, maj3n, per4, per5, per4n, per5n : integer := 0; --disclaimer: period specifies half period
    signal chord_count : std_logic_vector(25 downto 0);
    signal chord_case, norm_case : integer range -3 to 3 := 0;
    --signal period : std_Logic_vector(63 downto 0);
    --constant nanoframe : std_logic_vector(63 downto 0) := "0000000000000000000000000000001001010100000010111110010000000000";
begin

    intfreq <= to_integer(unsigned(freq(13 downto 0)));
    
    period <= 4000*16384/intfreq; --half period in 10 ns scale
    per4 <= period*3/4;
    per5 <= period*2/3;
    per4n <= period*4/3;
    per5n <= period*3/2;
    maj3 <= period*4/5;
    maj3n <= period*5/4;
    
    with sw(15) select transpose <=
        chord_case when '1',
        norm_case when others;
    process (clk)
    begin
        if rising_edge(clk) then
            if sw(15) = '1' then
                chord_count <= chord_count + 1;               
            end if;
            counter <= counter + 1;
            btn_counter <= btn_counter + 1;
            case transpose is
            when 0 =>
                if period_count >= period then
                    period_count <= 0;
                    JC_buffer <= NOT JC_buffer;
                else period_count <= period_count + 1;
                end if;
            when -1 =>
                    if period_count >= maj3n then
                    period_count <= 0;
                    JC_buffer <= NOT JC_buffer;
                else period_count <= period_count + 1;
                end if;
            when 1 =>
                    if period_count >= maj3 then
                    period_count <= 0;
                    JC_buffer <= NOT JC_buffer;
                else period_count <= period_count + 1;
                end if;
            when -2 =>
                if period_count >= per4n then
                    period_count <= 0;
                    JC_buffer <= NOT JC_buffer;
                else period_count <= period_count + 1;
                end if;
            when 2 =>
                if period_count >= per4 then
                    period_count <= 0;
                    JC_buffer <= NOT JC_buffer;
                else period_count <= period_count + 1;
                end if;
            when -3 =>
                if period_count >= per5n then
                    period_count <= 0;
                    JC_buffer <= NOT JC_buffer;
                else period_count <= period_count + 1;
                end if;
            when others => 
                if period_count >= per5 then
                    period_count <= 0;
                    JC_buffer <= NOT JC_buffer;
                else period_count <= period_count + 1;
                end if;
            end case;
        end if;
    end process;
    
    process (btn_counter(26))
    begin
        if falling_edge(btn_counter(26)) and sw(15) = '0' then
                if btnU = '1' and btnD = '0' then
                    norm_case <= norm_case + 1;
                elsif btnU = '0' and btnD = '1' then
                    norm_case <= norm_case - 1;
                end if;                   
        end if;
    end process;    
    
    process (chord_count(25))
    begin
        if falling_edge(chord_count(25)) and sw(15) = '1' then
            if chord_case >= 3 then
                chord_case <= 0;
            elsif chord_case >= 1 then               
                chord_case <= 3;
            else
                chord_case <= 1;
            end if;
        end if;
    end process;
    
    
    process(counter(17))
    begin
        if falling_edge(counter(17)) then
           
            
            an_select <= not an_select;
        end if;
    end process;
            
   with an_select select an <=
    "1110" when '1',
    "1101" when others;
    
   with an_select select seg <=
        display(6 downto 0) when '1',
        display(13 downto 7) when others;
                
    with transpose select display <=
        "11111111000000" when 0,
        "01111110011001" when -1,
        "11111110011001" when 1, --major third
        "01111110010010" when -2,
        "11111110010010" when 2, --perfect fourth
        "11111111111000" when 3,
        "01111111111000" when others;
    
    with sw(0) select led <=
        do_out when '0',
        freq(15 downto 0) when others;
        
    JC(5 downto 4) <= JC_buffer;
    
    daddr_in <= "00" & cout;
    vanal_p <= JXADC(0); vanal_n <= JXADC(4);
    
    frequency : Freq_finder port map(
        samp => do_out(15 downto 4),
        clock => clk,
        freq => freq
    );
    
    sound_converter : xadc_wiz_0 port map(
        daddr_in => daddr_in,
        den_in => eoc_out,         
        di_in => (others => '0'),      
        dwe_in => '0',         
        do_out => do_out,         
        drdy_out => drdy,      
        dclk_in => clk,       
        reset_in => btnC,  
        vauxp6 => vanal_p,  
        vauxn6 => vanal_n, 
        busy_out => open, 
        channel_out => cout,
        eoc_out => eoc_out, 
        eos_out => open,
        alarm_out => open,
        vp_in => '0',
        vn_in => '0'
    );
    
end Behavioral;
