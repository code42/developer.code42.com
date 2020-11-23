# Contributing to developer.code42.com

## Authoring a new article

To create a new article, follow these steps:

1. Add a file anywhere under the `source` directory of this repo.
   * The file should be named in the format of `<something>.html.md`

   * You may also create a new directory as long as it is under `source`. 

   *  The folder/file path will be the url used to access the article. For example, if you created `source/subdir/another-subdir/my-article.html.md`, the url to access it would be `developer.code42.com/subdir/another-subdir/my-article.html`.

   * If the file is named `index.html.md`, then the final segment of its URL is not needed. For example, `source/subdir/another-subdir/index.html.md` would be accessed at `developer.code42.com/subdir/another-subdir`. This is the preferred method for creating a new page because the url will not end in `.html` this way.
  
2. Paste a configuration block at the top of your new file (all options except `title` and `category` should be the same as shown here).

The `title` will be:
- displayed in the title bar of the browser while viewing the article
- The link text used on the landing page (which lists all articles).

`category` indicates the heading under which the article will appear on the landing page. This must be one of `get-started`, `detect-and-respond`, `splunk`, `use-cases`, or `other`. If you wish to create a new category, you must first edit the [landing page](source/sandbox/index.html.md.erb) to define it.

```
---
title: <enter title here>

category: <enter category here>

toc_footers:
  - <a href='https://github.com/slatedocs/slate'>Documentation Powered by Slate</a>

search: true

code_clipboard: true
---
```

1. Write your article using the markdown syntax outlined below.

2. Open a PR! 

   

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

Slate uses [PHP Markdown Extra](https://michelf.ca/projects/php-markdown/extra/#table) style tables:

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

You can use these formatting rules anywhere on the page (tables, paragraphs, lists, wherever!). However, they will appear verbatim in code blocks.

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
This is an [internal link](#markdown-reference), this is an [external link](http://google.com).
```

Will render:

This is an [internal link](#markdown-reference), this is an [external link](http://google.com).

### Notes and Warnings

You can add highlighted warnings and notes with just a little HTML embedded in your markdown document:

```html
<aside class="notice">
    You must replace meowmeowmeow with your personal API key.
</aside>
```

Use `class="notice"` for blue "info" notes, `class="warning"` for red "warning" notes, and `class="success"` for green "checkmark" notes.

Markdown inside HTML blocks won't be processed, but you can still use normal html.
