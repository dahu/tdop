" arithmetic TDOP parser
let a = tdop#parser()

call a.token('_end_')
call a.token('\s\+')
call a.token('\d\+\.\d\+', {'sym' : 'float', 'literal' : 1})
call a.token('\d\+',       {'sym' : 'int',   'literal' : 1})

call a.token('+',  {'sym' : 'add', 'lbp' : 10, 'rsym' : 'pos', 'rbp' : 100})
call a.token('-',  {'sym' : 'sub', 'lbp' : 10, 'rsym' : 'neg', 'rbp' : 100})
call a.token('*',  {'sym' : 'mul', 'lbp' : 20})
call a.token('/',  {'sym' : 'div', 'lbp' : 20})
call a.token('**', {'sym' : 'pow', 'lbp' : 30, 'right' : 1})

echo a.parse("3.0 + 2")
echo a.parse("-3.0 - 2")
echo a.parse("-3.0 * 2")
echo a.parse("-3.0 / 2")
echo a.parse("2 ** 3 ** 4")
echo a.parse("-1 + 2 * -3 / 4 ** -5 ** 6")
