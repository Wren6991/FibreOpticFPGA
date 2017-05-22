# Tables are copied from Wikipedia article.
# Functions are provided to generate verilog case statements.

table_5b6b = """0	100111	11000
1	11101	100010
10	101101	10010
11	110001	
100	110101	1010
101	101001	
110	11001	
111	111000	111
1000	111001	110
1001	100101	
1010	10101	
1011	110100	
1100	1101	
1101	101100	
1110	11100	
1111	10111	101000
10000	11011	100100
10001	100011	
10010	10011	
10011	110010	
10100	1011	
10101	101010	
10110	11010	
10111	111010	101
11000	110011	1100
11001	100110	
11010	10110	
11011	110110	1001
11100	1110	
11101	101110	10001
11110	11110	100001
11111	101011	10100"""

table_3b4b = """0	1011	100
1	1001	
10	101	
11	1100	11
100	1101	10
101	1010	
110	110	
111	1110	1
111	111	1000"""

encode_format_5b6b = "5'b%05d: 6'b%06d"

decode_format_5b6b = "6'b%06d: d_out[4:0] = 5'b%05d;"
decode_format_3b4b = "4'b%04d: d_out[7:5] = 3'b%03d;"
def encode_table(data, format_string):
    data = [d.split("\t") for d in data.split("\n")]
    for row in data:
        print(format_string % (int(row[0]), int(row[1])))

def decode_table(data, format_string):
    data = [d.split("\t") for d in data.split("\n")]
    for row in data:
        for codeword in row[1:]:
            if len(codeword) == 0:
                continue
            print(format_string % (int(codeword), int(row[0])))

