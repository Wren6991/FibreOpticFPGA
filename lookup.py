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

encode_format_5b6b = "6'b%s: b6 = 6'b%s;"
encode_format_3b4b = "5'b?%s: b4 = 4'b%s;"

decode_format_5b6b = "6'b%s: d_out[4:0] = 5'b%s;"
decode_format_3b4b = "4'b%s: d_out[7:5] = 3'b%s;"

def encode_table(data, w1, w2, format_string):
    # The output must be reversed ([::-1]) due to
    # back to front convention used on Wikipedia page
    data = [d.split("\t") for d in data.split("\n")]
    for row in data:
        if row[2] == "":
            print(format_string % ("?" + row[0].zfill(w1), row[1].zfill(w2)[::-1]))
        else:
            print(format_string % ("0" + row[0].zfill(w1), row[1].zfill(w2)[::-1]))
            print(format_string % ("1" + row[0].zfill(w1), row[2].zfill(w2)[::-1]))
           
def decode_table(data, w1, w2, format_string):
    data = [d.split("\t") for d in data.split("\n")]
    for row in data:
        for codeword in row[1:]:
            if len(codeword) == 0:
                continue
            print(format_string % (codeword.zfill(w1)[::-1], row[0].zfill(w2)))


