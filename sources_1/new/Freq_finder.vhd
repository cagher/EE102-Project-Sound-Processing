-----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.11.2023 21:00:31
-- Design Name: 
-- Module Name: Freq_finder - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;
use work.normsqfind.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Freq_finder is
    Port ( samp : in STD_LOGIC_VECTOR (11 downto 0);
           clock : in STD_LOGIC;
           freq : out std_logic_vector(63 downto 0)
           );
end Freq_finder;

architecture Behavioral of Freq_finder is

    
    COMPONENT xfft_0
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_config_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axis_config_tvalid : IN STD_LOGIC;
    s_axis_config_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tlast : IN STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axis_data_tuser : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tready : IN STD_LOGIC;
    m_axis_data_tlast : OUT STD_LOGIC;
    event_frame_started : OUT STD_LOGIC;
    event_tlast_unexpected : OUT STD_LOGIC;
    event_tlast_missing : OUT STD_LOGIC;
    event_status_channel_halt : OUT STD_LOGIC;
    event_data_in_channel_halt : OUT STD_LOGIC;
    event_data_out_channel_halt : OUT STD_LOGIC 
  );
    END COMPONENT;
    signal tuser, tuser1 : std_logic_vector(15 downto 0);
    signal freq_buff, freq_norm : std_logic_vector(63 downto 0) := (others => '0');
    signal data_config : std_logic_vector(51 downto 0) := (others => '0');
    signal data_in : std_logic_vector(63 downto 0);
    signal counter : std_logic_vector(6 downto 0):= (others => '0');
    signal ris_edge_count : std_logic;
    signal cycle : natural range 0 to 16383 := 16383;
    signal data_tlast, tvalid_fft, tlast_fft,
     frame_started, tlast_unexpected, tlast_missing, status_channel_halt, data_in_channel_halt
     , data_out_channel_halt: std_logic;
     signal config_tready, data_tready : std_logic := '1';
     signal config_tready1, data_tready1, data_tlast1, tvalid_ifft, tlast_ifft,
     frame_started1, tlast_unexpected1, tlast_missing1, status_channel_halt1, data_in_channel_halt1
     , data_out_channel_halt1: std_logic;
    signal ifft_ready, main_ready, main_valid : std_logic := '1';
    signal fft_out, fft_data, data_out : std_logic_vector(63 downto 0);
    signal index_buffer : std_logic_vector(13 downto 0) := (others => '0');
    signal valid_divide : std_logic := '1';
    signal validate : integer range 0 to 79 := 0; 

begin
    data_in <= data_config & samp;
     main_ready<= '1'; main_valid <= '1';
    ris_edge_count <= not counter(6);
    
    clk_div : process (clock)
    begin
        if rising_edge(clock) then
            if counter >= "1100100" then
                counter <= (others => '0');
            else 
                counter <= counter + 1;
            end if;
        end if;
    end process; 

     
    cyc_proc : process (counter(6))
    begin
    if falling_edge(counter(6)) then
        if validate = 79 then
            valid_divide <= '1';
            validate <= 0;
        else valid_divide <= '0'; validate <= validate + 1; end if;
        if cycle >= 16383 then
        cycle <= 0;
        data_tlast <= '1';
        else cycle <= cycle + 1; data_tlast <= '0'; end if;
        if tvalid_fft = '1' and (not (tuser = "0000000000000000")) then
        
        if freq_norm <= fft_data and tuser(13 downto 0) <= "10000000000000"  then
            freq_buff <= fft_out;
            index_buffer <= tuser(13 downto 0);
        end if;
        else
            freq(13 downto 0) <= index_buffer;
            freq_buff <= (others => '0');
        end if;
    end if;
    end process;
      
  fft : xfft_0
  PORT MAP (
    aclk => ris_edge_count ,
    s_axis_config_tdata => "0010101011010101",
    s_axis_config_tvalid => '1',
    s_axis_config_tready => config_tready,
    s_axis_data_tdata => data_in,
    s_axis_data_tvalid => valid_divide,
    s_axis_data_tready => data_tready,
    s_axis_data_tlast => data_tlast,
    m_axis_data_tdata => fft_out,
    m_axis_data_tuser => tuser,
    m_axis_data_tvalid => tvalid_fft,
    m_axis_data_tready => '1',
    m_axis_data_tlast => tlast_fft,
    event_frame_started => frame_started,
    event_tlast_unexpected => tlast_unexpected,
    event_tlast_missing => tlast_missing,
    event_status_channel_halt => status_channel_halt,
    event_data_in_channel_halt => data_in_channel_halt,
    event_data_out_channel_halt => data_out_channel_halt
  );
  fft_data <= normsq(fft_out);
  freq_norm <= normsq(freq_buff);
  

         

end Behavioral;
