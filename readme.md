
to replace vim.{bo,wo}

## purpose
* provide a compatibility layer to easy the api migration of nvim_{buf,win}_{s,g}et_option
* cache the descriptor as needed
* prefer function call over emulating property setter/setter 

## equivalents
* vim.bo[bufnr]         -> prefer.buf(bufnr)
* vim.bo[bufnr].foo     -> prefer.bo(bufnr, foo)
* vim.bo[bufnr].foo=bar -> prefer.bo(bufnr, foo, bar)
