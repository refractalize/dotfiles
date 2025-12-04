; inherits html

; Jinja delimiters in text nodes: {{ … }}, {% … %}, {# … #}
  (
  (text) @injection.content
  (#match? @injection.content "\\{[{%#]")
  (#set! injection.language "jinja")    ; or "jinja2" if that’s your parser name
  )

  ; Jinja inside attribute values (e.g., class="{{ foo }}")
  (
  (attribute_value) @injection.content
  (#match? @injection.content "\\{[{%#]")
  (#set! injection.language "jinja")    ; or "jinja2"
  )

  ; Optional: Jinja appearing in raw_text (e.g., inside  or )
  (
  (raw_text) @injection.content
  (#match? @injection.content "\\{[{%#]")
  (#set! injection.language "jinja")    ; or "jinja2"
  )
