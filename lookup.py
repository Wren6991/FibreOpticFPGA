data = """0	1011	100
1	1001	
10	101	
11	1100	11
100	1101	10
101	1010	
110	110	
111	1110	1
111	111	1000"""

data = [d.split("\t") for d in data.split("\n")]
for row in data:
	print("case 3'b" + row[0].zfill(3) + ": 4b = 4'b" + row[1].zfill(4) + ";")
