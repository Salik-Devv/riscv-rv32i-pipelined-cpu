library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package regfile_pkg is
    type reg_array_public is array (31 downto 0) of std_logic_vector(31 downto 0);
end package regfile_pkg;

package body regfile_pkg is
    -- Empty package body
end package body regfile_pkg;
