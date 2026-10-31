# AGENTS.md

Edit AGENTS.md and README.md only when explicitly requested.

Freely manage PLAN.md, NOTES.md, and ARCHITECTURE.md for your own work. Keep them gitignored and never commit them.

## EditorConfig

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_size = 4
indent_style = space
insert_final_newline = true
max_line_length = 200
trim_trailing_whitespace = true

[*.go]
indent_size = tab
indent_style = tab
tab_width = 8

[*.ini]
max_line_length = off

[*.md]
indent_size = unset
indent_style = unset
max_line_length = off

[*.txt]
indent_size = unset
indent_style = unset
max_line_length = off

[LICENSE]
indent_size = unset
indent_style = unset
max_line_length = off

[Makefile]
indent_style = tab
max_line_length = off
```

## Prettier

```json
{
    "arrowParens": "always",
    "bracketSameLine": false,
    "objectWrap": "preserve",
    "plugins": ["@prettier/plugin-xml"],
    "proseWrap": "never",
    "semi": true,
    "singleAttributePerLine": true,
    "singleQuote": true,
    "trailingComma": "all",
    "xmlQuoteAttributes": "double",
    "xmlSelfClosingSpace": true,
    "xmlWhitespaceSensitivity": "preserve"
}
```

## Clang-Format

```yaml
---
BasedOnStyle: Microsoft
ColumnLimit: 200
NamespaceIndentation: All
InsertBraces: true
BreakBeforeBraces: Allman
SeparateDefinitionBlocks: Always
WrapNamespaceBodyWithEmptyLines: Always
InsertNewlineAtEOF: true
LineEnding: LF
...
```
