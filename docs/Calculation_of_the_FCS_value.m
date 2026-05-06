%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation of the FCS value(useing the IEEE 802.3 MAC)
% 
% Description:  The following program should be used to co calculate the FCS
%               value the should be sendt allong aside the messege so a
%               testbench can send it.
% 
% Made by: Hákon Hlynsson 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Polynomial
G = [1,0,0,0,0,0,1,0,0,1,1,0,0,0,0,0,1,0,0,0,1,1,1,0,1,1,0,1,1,0,1,1,1];

% Degrees
degree = 32;

% 802.3 MAC format
Preamble= [0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA];
Start_of_Frame=[0xAB];
Destination_MAC=[0x00,0x00,0x00,0x00,0x00,0x00];% Select the Destination
Source_MAC=[0x00,0x00,0x00,0x00,0x00,0x00];     % Select the Source

% Data that you want to send 46-1500 bytes
Payload=repmat(uint8(0xAA),1,46);
EtherType_Length = [uint8(bitshift(uint16(length(Payload)), -8)), uint8(bitand(uint16(length(Payload)), 255))];

% Combining them all into on big vector 
MAC_Frame = [Preamble, Start_of_Frame, Destination_MAC, Source_MAC, EtherType_Length, Payload];

% Convert from hex to binary vector
binStr = reshape(dec2bin(MAC_Frame, 8).', 1, []); % Convert Hex to string
M = double(binStr) - double('0'); % convert from ascii to numbers a binary vector

% Adding 32 zeros for the division
M = [M, zeros(1, degree)];

% Xor when the leading bit is '1' throgh out the data (exept the last 32 bits)
for i = 1 : (length(M) - degree)
    if M(i) == 1
        M(i:i+degree) = xor(M(i:i+degree), G);
    end
end

% Find the last 32 bits and invert them
R = M(end-degree+1 : end);
R_final = 1 - R; % Final bitwise complement


%Display
% Select the last 32 bits and placeing them in a 8x4 matrix
bit_matrix = reshape(R_final(1:32), 8, 4)';  

powers_of_two = 2.^(7:-1:0)';% Creating a vector to convert to decimal 
decimal_values = bit_matrix * powers_of_two; % Decimal value

hex_bytes = dec2hex(decimal_values, 2); % Convert from decimal to hex

% write to terminal 
fprintf('Calculated Hex: 0x%s 0x%s 0x%s 0x%s\n', ...
hex_bytes(1,:), hex_bytes(2,:), hex_bytes(3,:), hex_bytes(4,:));