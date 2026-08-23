import duckdb
con = duckdb.connect(r'C:\Users\USER\Desktop\DEProject\DIVVY\divvyProj\warehouse.duckdb')
result = con.execute("select * from diferente_tipuri_biciclete")
columns = [desc[0] for desc in result.description]
print(columns)
for row in result.fetchall():
    print(row)