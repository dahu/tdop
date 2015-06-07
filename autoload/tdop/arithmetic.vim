" arithmetic TDOP parser
let a = tdop#parser()

call a.token('_end_')
call a.token('\s\+')
call a.token('\d\+\.\d\+', {'lsym' : 'float'})
call a.token('\d\+',       {'lsym' : 'int'})

call a.token('+',  {'usym' : 'pos', 'bp' : 100, 'eval' : Fn('(x) => a:x')             })
call a.token('-',  {'usym' : 'neg', 'bp' : 100, 'eval' : Fn('(x) => a:x * -1')        })
call a.token('+',  {'bsym' : 'add', 'bp' : 10,  'eval' : Fn('(x,y) => a:x + a:y')     })
call a.token('-',  {'bsym' : 'sub', 'bp' : 10,  'eval' : Fn('(x,y) => a:x - a:y')     })
call a.token('*',  {'bsym' : 'mul', 'bp' : 20,  'eval' : Fn('(x,y) => a:x * a:y')     })
call a.token('/',  {'bsym' : 'div', 'bp' : 20,  'eval' : Fn('(x,y) => a:x / a:y')     })
call a.token('**', {'rsym' : 'pow', 'bp' : 30,  'eval' : Fn('(x,y) => pow(a:x, a:y)') })

echo a.parse("3.0 + 2")
echo a.parse("-3.0 - 2")
echo a.parse("-3.0 * 2")
echo a.parse("-3.0 / 2")
echo a.parse("2 ** 3 ** 4")
echo a.parse("-1 + 2 * -3 / 4 ** 3 ** 2")
