let g:token       = {}
let g:tokens      = []
let g:token_types = {}
let g:index       = 0

function! Init(text)
  let g:tokens = string#lexer(a:text).tokens.tokens
endfunction

function! Token(token, lbp, nud, led)
  call extend(g:token_types, {a:token : {'lbp' : a:lbp, 'nud' : a:nud, 'led': a:led}})
endfunction

function! NewToken(token)
  let obj       = {}
  let obj.lbp   = 0
  let obj.type  = a:token[0]
  let obj.value = a:token[1]
  let obj.line  = a:token[2]
  let found_type = 0
  for k in keys(g:token_types)
    if obj.value =~# k
      let obj.lbp = get(g:token_types[k], 'lbp', 0)
      let obj.nud = get(g:token_types[k], 'nud', '')
      let obj.led = get(g:token_types[k], 'led', '')
      let found_type = 1
      break
    endif
  endfor
  if ! found_type
    echoerr 'Unknown token type: ' . obj.type . ' (' . obj.value . ')'
  endif
  return obj
endfunction

function! Next()
  let t        = g:tokens[g:index]
  let g:index += 1
  while index(['whitespace', 'comment'], t[0]) != -1
    let t        = g:tokens[g:index]
    let g:index += 1
  endwhile
  return NewToken(t)
endfunction

function! Expression(rbp)
  let t       = g:token
  let g:token = Next()
  let left    = call(t.nud, [], t)
  while a:rbp < g:token.lbp
    let t       = g:token
    let g:token = Next()
    let left    = call(t.led, [left], t)
  endwhile
  return left
endfunction

function! Parse(expr)
  call Init(a:expr)
  let g:token = Next()
  return Expression(0)
endfunction

call Token('_end_', 0,  '', '')
call Token('\s\+',  0,  '', '')
call Token('\d\+',  0,  Fn('() => self.value'), '')
call Token('+',     10, '', Fn('(left) => let right = Expression(10) | a:left + right'))

echo Parse("1 + 2")
