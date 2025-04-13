TPSV
====

TPSV stands for Tab-Pipe-Separated-Values and is a human readable replacement for CSV and TSV.
Like both of these formats, TPSV is able to describe tabular data where each cell contains a string value.
The main design requirement for TPSV is that it should be easy to parse and easy to use for everyone with a text editor, no plugins needed.

## Syntax

The basic syntax is simple.

1. A cell starts with a `|` and ends with one or more tabs.
2. A line that starts with a cell is a row. Any other lines are ignored.
3. The first row is the header row, and it defines the number of columns and their names.

That's all you need, but there are a few more rules to make life easier.

4. A row with too few cells has the remaining cells be an empty string.
5. A row with too many cells has the superfluous cells ignored.
6. The last column in a row does not have to end with tabs.

Then there is one last optional rule, the multiline extension.

7. A row that starts with a `\` instead of a `|` is treated as a continuation row.
   The contents of its cells are appended to the cells of the previous row, delimited by a newline character.

## Example

This is a sample TPSV demonstrating the format

```
vim: tw=4
Employee table
|First Name	|Second Name	|Occupation	|Notes			|Details
------------|---------------|-----------|---------------|-------
|Alice		|Johnson		|Engineer	|Top performer	|Has consistently exceeded expectations across multiple projects, including the Q4 rollout.
|Bob		|Lee			|Manager	|Needs review	|Pending evaluation for lateral move to operations; decision expected next month.
|Carol		|Wu				|Analyst	|Fast learner	|Quickly adapted to new tooling. Mentors junior staff.					| TODO: review this row
|Dan		|Kent			|Technician	|Retired		|Though retired, Dan remains available on a consultancy basis,
\			|				|			|				|especially for legacy systems and knowledge transfer sessions with new staff.
```

This example is chosen to highlight a few aspects.

- The first two lines are comments. The first line is a modeline, which can be interpreted by text editors that support them, and in this case sets the tab width to 4.
- The header separator does not start with a | or a \ , and is thus ignored.
- This chosen header separator makes this example compatible with markdown pipe tables, which are recognized as tables in many places, like github markdown.
  Convenient if you want to paste it somewhere.
- The last column is ideal for long cell contents.
- The cell with the TODO is past the last column, so it acts as a comment.
- The last line is a continuation, which can be nice if you don't want the text to exceed a certain width.

## Editor compatibility

Recommendations:

- Use monospaced text editor.
- Configure editor to render tab characters (so you can distinghuish from spaces).
- Use editorconfig to set tabwidth for specific files, or use modelines like `vim: tw=8`, which are supported by several editors.
- The smaller you choose the tabwidth, the more finegrained you can make the column widths, but this also comes with more width management.
  I would generally recommend a tabwidth of 8 for TPSV files, but other choices can make a lot of sense too.


Example .editorconfig for generic tsv files:

```
[*.tsv]
indent_style = tab
tab_width = 28
trim_trailing_whitespace = false
max_line_length = 999
insert_final_newline = true
```

## Comparison with other formats

Improvements over TSV:

- Allows comments
- Easier to view in text editors without setting the tabwidth very high
  (which would make all columns as wide as the widest column)
- Can be made compatible with markdown pipe tables
- Multiline extension

Improvements over markdown pipe tables:

- Less managing spaces for vertical alignment. Tabs are easier to space evenly (unless you have a tabwidth of 1).
- Cell contents are able to contain pipes and leading/trailing spaces.
- Multiline extension

## Parsing

This parses the basic syntax.

```python
def parse_tpsv(file):
    headers = []
    for line in file:
        if line.startswith('|'):
            cells = [c.rstrip('\t') for c in line[1:].rstrip('\n').split('\t|')]
            if not headers:
                headers = cells
            else:
                cells += [''] * (len(headers) - len(cells)) # Missing cells are empty
                yield dict(zip(headers, cells)) # Superfluous cells are omitted
```

To also parse the multiline extension, something like this would do


```python
def parse_tpsv_multiline(file):
    headers = []
    row = None

    for line in file:
        line = line.rstrip('\n')

        if line.startswith('|'):
            if row:
                yield row
            cells = line[1:].split('\t|')
            cells = [c.rstrip('\t') for c in cells]
            if not headers:
                headers = cells
            else:
                cells += [''] * (len(headers) - len(cells))
                row = dict(zip(headers, cells))
        elif line.startswith('\\') and row:
            cells = line[1:].split('\t|')
            cells += [''] * (len(headers) - len(cells))
            for h, c in zip(headers, cells):
                if c.strip():
                    row[h] += '\n' + c.rstrip('\t')
                    
    if row:
        yield row
```

