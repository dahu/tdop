let arithmetic = tdop#parser()

call arithmetic.token('_end_', 0,  '', '')
call arithmetic.token('\s\+',  0,  '', '')
call arithmetic.token('\d\+\.\d\+',  0,  Fn('() => self.value'), '')
call arithmetic.token('\d\+',  0,  Fn('() => self.value'), '')

function! tdop#arithmetic#add(left) dict
  return a:left + self._.expression(10)
endfunction

function! tdop#arithmetic#sub(left) dict
  return a:left - self._.expression(10)
endfunction

function! tdop#arithmetic#mul(left) dict
  return a:left * self._.expression(10)
endfunction

function! tdop#arithmetic#div(left) dict
  return a:left / self._.expression(10)
endfunction

function! tdop#arithmetic#pow(left) dict
  return pow(a:left, self._.expression(30-1))
endfunction

call arithmetic.token('+',     10, '', Fn('(left) => a:left + self._.x(10)'))
call arithmetic.token('-',     10, '', function('tdop#arithmetic#sub'))
call arithmetic.token('*',     20, '', function('tdop#arithmetic#mul'))
call arithmetic.token('/',     20, '', function('tdop#arithmetic#div'))
call arithmetic.token('**',    30, '', function('tdop#arithmetic#pow'))

echo arithmetic.parse("3.0 + 2")
echo arithmetic.parse("3.0 - 2")
echo arithmetic.parse("3.0 * 2")
echo arithmetic.parse("3.0 / 2")
echo arithmetic.parse("2 ** 3")
