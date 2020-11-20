# Contributing to developer.code42.com

## Authoring a new articleas

## Markdown Reference

### Headers

For headers:

```
# Level 1 (Largest) Header
## Level 2 Header
### Level 3 Header
#### Level 4 Header
```

Will Render:

# Level 1 (Largest) Header
## Level 2 Header
### Level 3 Header
#### Level 4 Header
<br>

Note that only level 1, 2, and 3 headers will appear in the left-hand table of contents.

### Paragraph Text

For normal text, just type your paragraph.

Make sure the lines above and below your paragraph are empty.

### Code Snippets

For code, surround the snippet with three backticks at the top and bottom, and the name of the language/syntax after the first three ticks:

```
	```bash
	curl https://example.com
	```

    ```json
        { example: "some value"}
    ```

	```python
    import foo
    # This is some Python code!
    bar = "baz"
	```
```

Will render:

```bash
curl https://example.com
```

```json
{ example: "some value"}
```

```python
import foo
# This is some Python code!
bar = "baz"
```

For the full list of supported languages, see [rouge](https://github.com/jneen/rouge/wiki/List-of-supported-languages-and-lexers).


### Tables

Slate uses PHP Markdown Extra style tables:

```markdown
Table Header 1 | Table Header 2 | Table Header 3
-------------- | -------------- | --------------
Row 1 col 1 | Row 1 col 2 | Row 1 col 3
Row 2 col 1 | Row 2 col 2 | Row 2 col 3
```

Renders:

Table Header 1 | Table Header 2 | Table Header 3
-------------- | -------------- | --------------
Row 1 col 1 | Row 1 col 2 | Row 1 col 3
Row 2 col 1 | Row 2 col 2 | Row 2 col 3
<br>

Note that the pipes do not need to line up with each other on each line.

You can also use normal html `<table>`s directly in your markdown.

### Formatted Text

```markdown
This text is **bold**, this is *italic*, this is an `inline code block`.
```

Renders:

This text is **bold**, this is *italic*, this is an `inline code block`.

You can use those formatting rules in tables, paragraphs, lists, wherever, although they'll appear verbatim in code blocks.

### Lists

```markdown
1. This
2. Is
3. An
4. Ordered
5. List

* This
* Is
* A
* Bulleted
* List
```
Will render:

  1. This
  2. Is
  3. An
  4. Ordered
  5. List

  * This
  * Is
  * A
  * Bulleted
  * List

#### Nested Lists

You can do sub-lists in Markdown by indenting the bullets (or numbers) by 4 spaces: 
```markdown
* First
    1. 1
    2. 2
* Second
    * a
    * b
    * c
```

Will render:

* First
    1. 1
    2. 2
* Second
    * a
    * b
    * c


### Links

```markdown
This is an [internal link](#error-code-definitions), this is an [external link](http://google.com).
```

Will render:

This is an [internal link](#error-code-definitions), this is an [external link](http://google.com).

### Notes and Warnings

You can add little highlighted warnings and notes with just a little HTML embedded in your markdown document:

```html
<aside class="notice">
    You must replace meowmeowmeow with your personal API key.
</aside>
```

Use `class="notice"` for blue "info" notes, `class="warning"` for red "warning" notes, and `class="success"` for green "checkmark" notes.

Markdown inside HTML blocks won't be processed, but you can still use normal html.
