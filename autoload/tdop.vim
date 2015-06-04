function! tdop#tokenize(token, lbp, nud, led)
  let obj = {}
  let obj.token = a:token
  let obj.lpb = a:lpb

  func obj.led(left)
  endfunc

  func obj.nud()
  endfunc

  return obj
endfunction

let tdop_arithmetic = tdop#parser()
call tdop_arithmetic.token('\d\+')
call tdop_arithmetic.nud('\d\+', Fn('() => let right = self.expression(10) | a:left + right'))
call tdop_arithmetic.token('+')
call tdop_arithmetic.led('+', Fn('(left) => let right = self.expression(10) | a:left + right'))

let operator_add_token = tdop#tokenize('+', 10)
    let operator_add_token.led =
        right = expression(10)
        return left + right

function! tdop#parser()
  let obj {}
  let obj.tok = {}
  let obj.raw_tokens = string#lexer(a:string)
  let obj.tokens = {}
  let obj.index = 0

  func obj.token(token, ...)
    let lbp = a:0 ? a:1 : 0
    call extend(self.tokens, {a:token : {'lpb' : lbp}})
  endfunc
  func obj.nud(token, nud)
    call extend(self.tokens, {a:token : {'nud' : a:nud}})
  endfunc
  func obj.led(token, led)
    call extend(self.tokens, {a:token : {'led' : a:led}})
  endfunc

  func obj.next()
    let t = self.raw_tokens[self.index]
    let tok = get(self.tokens, t[0], {})
    if tok == {}
      echom 'Error: Unknown token: ' . t[0]
    endif
    let self.index += 1
    return tok
  endfunc

  func obj.expression(rbp)
    let t = self.tok
    let self.tok = self.next()
    let left = t.nud()
    while a:rbp < self.tok.lbp
      let t = self.tok
      let self.tok = self.next()
      let left = t.led(left)
    endwhile
    return left
  endfunc

  return obj
endfunction
