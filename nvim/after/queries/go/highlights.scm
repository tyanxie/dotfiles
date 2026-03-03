; extends

; 提升 escape_sequence 的优先级到 150，使其高于 LSP semantic tokens 的 125
; 让 @string.escape 的颜色覆盖能正常生效
((escape_sequence) @string.escape (#set! priority 150))
