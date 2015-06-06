" arithmetic TDOP parser
let a = tdop#parser()

call a.token('_end_')
call a.token('\s\+')
call a.token('\d\+\.\d\+', {'nud' : Fn('() => self.value')})
call a.token('\d\+',       {'nud' : Fn('() => self.value')})

call a.token('+',    {'lbp' : 10, 'led' : Fn('(l) => a:l + self._.x(10)')})
call a.token('-',    {'lbp' : 10, 'led' : Fn('(l) => a:l - self._.x(10)')})
call a.token('\*',   {'lbp' : 20, 'led' : Fn('(l) => a:l * self._.x(20)')})
call a.token('/',    {'lbp' : 20, 'led' : Fn('(l) => a:l / self._.x(20)')})
call a.token('\*\*', {'lbp' : 30, 'led' : Fn('(l) => pow(a:l, self._.x(30-1))')})

echo a.parse("3.0 + 2")
echo a.parse("3.0 - 2")
echo a.parse("3.0 * 2")
echo a.parse("3.0 / 2")
echo a.parse("2 * 3 ** 4")
