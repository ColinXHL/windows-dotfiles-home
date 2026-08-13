; Keep normal comment features for every C# comment.
((comment) @injection.content
  (#set! injection.language "comment"))

; C# /// documentation is XML. Only inject lines containing XML tags, and
; combine their ranges so an opening tag and a later closing tag are parsed
; as one XML document. No tag names are hard-coded.
((comment) @injection.content
  (#match? @injection.content "^///[ \\t]*</?[A-Za-z_:]")
  (#set! injection.language "xml")
  (#set! injection.combined))

; Doxygen block and //! documentation comments.
((comment) @injection.content
  (#match? @injection.content "^(/\\*\\*|/\\*!|//!)(.*)")
  (#set! injection.language "doxygen"))

; Doxygen commands are also valid in consecutive /// comments. C# XML tags
; above remain XML; lines beginning with @command or \\command use Doxygen.
((comment) @injection.content
  (#match? @injection.content "^///[ \\t]*(@|\\\\)[A-Za-z]")
  (#set! injection.language "doxygen"))
