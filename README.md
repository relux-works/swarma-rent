# Swarma Rent

Private working repository for the book "Swarma Rent": the target design of a
self-sufficient agent rental service built on the Swarma Platform and the
Swarma Link protocol.

The Russian text is the source of truth. This is a first draft: it describes a
target design, and the status of every part is in the chapter "Где мы".

## Layout

| Path | What it is |
| --- | --- |
| `book/ru/NN-*.md` | The chapters, Pandoc Markdown, one file per chapter. Title metadata is in `00-vvedenie.md`. |
| `book/src/*.toml` | Figure sources (declarative, one figure per file). |
| `book/diagrams/*.svg` | Rendered figures. Never edit by hand: re-render from the source. |
| `book/build.sh` | Builds the PDF. |
| `book/check.sh` | Hygiene check of the chapters. |
| `book/style.css`, `book/template.html`, `book/filters/book.lua` | The Swarma book house style, copied from the Swarma docs repository so this book looks like the others. |
| `book/swarma-rent.ru.pdf` | The built book. |
| `scripts/diagram-kit/` | The Swarma diagram kit (renderer, theme, font metrics), vendored from the Swarma docs repository. |
| `NOTES.md` | Summary for the lead: design choices, open questions, gap list. |

## Tools

| Tool | Used for | How to run | Output |
| --- | --- | --- | --- |
| pandoc 3.x | Markdown chapters to one HTML document | called by `book/build.sh` | temporary |
| WeasyPrint 69+ | HTML to PDF | called by `book/build.sh` | `book/swarma-rent.ru.pdf` |
| Python 3.11+ | Runs the diagram kit | `python3 scripts/diagram-kit/render.py book/src/NAME.toml book/diagrams/NAME.svg --require-fit tall` | `book/diagrams/NAME.svg` |
| Graphviz 14.0.4 | Needed only for figures with `layout = "graph"` (none today) | called by the diagram kit | none |
| poppler (`pdfinfo`, `pdftotext`) | Checking the built PDF | `pdfinfo book/swarma-rent.ru.pdf`; `pdftotext book/swarma-rent.ru.pdf -` | stdout |
| `book/check.sh` | Style and hygiene rules of the Swarma books | `sh book/check.sh` | stdout; non-zero exit on a hit |

Fonts: PT Serif, PT Sans and PT Mono must be installed.

### Build

```sh
sh book/check.sh
bash book/build.sh            # writes book/swarma-rent.ru.pdf
```

`build.sh` first checks the figures: every figure a chapter links has a TOML
source, every source has its SVG, and every SVG equals a fresh render of its
source and fits its box. `RENT_BOOK_SKIP_FIGURE_RENDER=1` skips only the
render comparison.

### Hygiene check

`book/check.sh` fails on internal identifiers, local paths,
status markers and delivery hedges outside the two state chapters
(`*-chego-ne-hvataet.md`, `*-gde-my.md`), dashes used as connectives,
guillemets, antithesis, filler openers, marketing adjectives, common words
written without the letter "ё", and a chapter without a level-1 heading. The
checks are lexical; the final judgement stays with the reviewer.

Names of machines, seats and people are not kept in this repository. To check
for them, keep a local file with one extended regular expression per line and
run `RENT_BOOK_DENY_FILE=/path/to/file sh book/check.sh`; an unreadable deny
file is a refusal, not a pass.

### Adding a figure

1. Write `book/src/NAME.toml` (layouts `stack`, `sequence` or `graph`; see the
   existing sources).
2. Render it: `python3 scripts/diagram-kit/render.py book/src/NAME.toml book/diagrams/NAME.svg --require-fit tall`.
3. Link it in a chapter: `![Caption.](../diagrams/NAME.svg){.tall}` (drop
   `{.tall}` when the figure fits the normal box, and use `--require-fit normal`).

## Writing rules

The book follows the Swarma books' style guide: present tense for the target
design, a definition before use, exact guarantees with their limits next to
the mechanism, no delivery hedges outside the state chapters, no internal
identifiers, the letter "ё" everywhere. A statement with a citation is taken
from the cited source; a statement without one is a proposal of this book.
