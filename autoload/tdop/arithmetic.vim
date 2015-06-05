let arithmetic = tdop#parser()
call arithmetic.token('_end_', 0,  '', '')
call arithmetic.token('\s\+',  0,  '', '')
call arithmetic.token('\d\+',  0,  Fn('() => self.value'), '')
call arithmetic.token('+',     10, '', Fn('(left) => let right = self._.expression(10) | a:left + right'))

echo arithmetic.parse("1 + 2")

