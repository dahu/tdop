function! tdop#parser()
  let obj             = {}
  let obj.tok         = {}
  let obj.tokens      = []
  let obj.token_types = {}
  let obj.index       = 0

  func obj.token(token, ...)
    let token = a:token
    if a:0
      let traits = a:1
      for st in items({'lsym' : 'literal', 'bsym' : 'binary', 'usym' : 'unary', 'rsym' : 'right_binary'})
        if has_key(traits, st[0])
          call extend(traits, {'sym_type' : st[1]})
          let traits.sym = get(traits, st[0])
          break
        endif
      endfor
      if ! has_key(traits, 'bp')
        call extend(traits, {'bp' : 0})
      endif
      if st[1] =~ 'binary'
        call extend(traits, {'lbp' : traits.bp})
        if has_key(traits, 'eval')
          call extend(traits, {'beval' : traits.eval})
        endif
        if st[1] =~ 'right'
          call extend(traits, {'right' : 1})
        endif
      endif
      if st[1] == 'unary'
        call extend(traits, {'rbp' : traits.bp})
        if has_key(traits, 'eval')
          call extend(traits, {'ueval' : traits.eval})
        endif
      endif
      if st[1] == 'literal'
        call extend(traits, {'literal' : 1})
        if has_key(traits, 'eval')
          call extend(traits, {'leval' : traits.eval})
        endif
      endif
      " echom string(traits)
      for [k, V] in items(traits)
        call self.decorate(token, k, V)
        unlet V
      endfor
    else
      call self.decorate(token, 'lbp', 0)
    endif
  endfunc

  func obj.decorate(token, name, value)
    let token = a:token
    if has_key(self.token_types, token)
      call extend(self.token_types[token], {a:name : a:value})
    else
      call extend(self.token_types, {token : {a:name : a:value}})
    endif
  endfunc

  func obj.literal()
    let value = self.value
    if has_key(self, 'leval')
      let value = self.leval(value)
    endif
    return [self.sym, self.value, value]
  endfunc

  func obj.prefix()
    let right = self._.x(self.rbp)
    let value = right[-1]
    if has_key(self, 'ueval')
      let value = self.ueval(value)
    endif
    return [self.usym, right, value]
  endfunc

  func obj.infix(left)
    let right = self._.x(self.lbp)
    let value = right[-1]
    if has_key(self, 'beval')
      let value = self.beval(a:left[-1], value)
    endif
    return [self.sym, a:left, right, value]
  endfunc

  func obj.right_infix(left)
    let right = self._.x(self.lbp - 1)
    let value = right[-1]
    if has_key(self, 'beval')
      let value = self.beval(a:left[-1], value)
    endif
    return [self.sym, a:left, right, value]
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
        for [name, Value] in items(self.token_types[k])
          let obj[name] = Value
          unlet Value
        endfor
        if has_key(obj, 'literal') && obj.literal != 0
          let obj.prefix = self.literal
        endif
        if ! has_key(obj, 'prefix')
          let obj.prefix = self.prefix
        endif
        if ! has_key(obj, 'infix')
          if has_key(obj, 'right')
            let obj.infix = self.right_infix
          else
            let obj.infix = self.infix
          endif
        endif
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
    let left = call(t.prefix, [], t)
    while a:rbp < self.tok.lbp
      let t = self.tok
      call self.next()
      let l = left
      unlet left
      let left = call(t.infix, [l], t)
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
