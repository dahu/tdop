function! tdop#parser()
  let obj             = {}
  let obj.tok         = {}
  let obj.tokens      = []
  let obj.token_types = {}
  let obj.index       = 0

  func obj.token(token, lbp, nud, led)
    call extend(self.token_types, {a:token : {'lbp' : a:lbp, 'nud' : a:nud, 'led': a:led}})
  endfunc

  func obj.tdop_token(token)
    let obj        = {}
    let obj.lbp    = 0
    let obj.type   = a:token[0]
    let obj.string_value  = a:token[1]
    if obj.string_value =~ '\d\+\.\d\+'
      let obj.value = str2float(obj.string_value)
    elseif obj.string_value =~ '\d\+'
      let obj.value = str2nr(obj.string_value)
    else
      let obj.value = obj.string_value
    endif
    let obj.line   = a:token[2]
    let found_type = 0
    for k in keys(self.token_types)
      if obj.string_value =~# '^' . k . '$'
        let obj.lbp = get(self.token_types[k], 'lbp', 0)
        let obj.nud = get(self.token_types[k], 'nud', '')
        let obj.led = get(self.token_types[k], 'led', '')
        let obj._ = self
        let found_type = 1
        break
      endif
    endfor
    if ! found_type
      echoerr 'Unknown token type: ' . obj.type . ' (' . obj.value . ')'
    endif
    return obj
  endfunc

  func obj.next()
    let t = self.tokens[self.index]
    let self.index += 1
    while index(['whitespace', 'comment'], t[0]) != -1
      let t = self.tokens[self.index]
      let self.index += 1
    endwhile
    let self.tok = self.tdop_token(t)
  endfunction

  func obj.expression(rbp)
    let t = self.tok
    call self.next()
    let left = call(t.nud, [], t)
    while a:rbp < self.tok.lbp
      let t = self.tok
      call self.next()
      let left = call(t.led, [left], t)
    endwhile
    return left
  endfunc

  let obj.x = obj.expression

  func obj.parse(text)
    let self.tokens = string#lexer(a:text).tokens.tokens
    let self.index = 0
    call self.next()
    return self.expression(0)
  endfunc

  return obj
endfunction
