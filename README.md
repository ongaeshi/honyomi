# Honyomi

honyomi is a e-book (pdf) search engine. It have command line interface and web application. It will accelerate the e-book of your life.

honyomi is "本読み". "Read a book" is meaning.

![honyomi-01.png]()

## Installation

    $ gem install honyomi

And, need 'pdftotext' command (poppler, xpdf ..)

## Usage

```
$ honyomi
honyomi 0.0.1

Commands:
  honyomi add file1 [file2 ...]           # Add pdf files
  honyomi edit book_id [options]          # Edit book info
  honyomi help [COMMAND]                  # Describe available commands or one specific command
  honyomi init                            # Create database in ENV['HONYOMI_DATABASE_DIR'] or '~/.honyomi'
  honyomi list [book_id1 book_id2 ...]    # List books
  honyomi remove book_id1 [book_id2 ...]  # Remove books
  honyomi search query                    # Search pages
  honyomi web                             # Web search interface

Options:
  -h, [--help]  # Help message
```

### Create a database

```
$ honyomi init
Create database to "/home/username/.honyomi/db/honyomi.db"
```

Specify database dir. (Commands as well as other)

```
$ HONYOMI_DATABASE_DIR=/path/to/dir honyomi init
Create database to "/path/to/dir/db/honyomi.db"
```

### Add e-book

```
$ honyomi add /path/to/this_is_book.pdf
A 1 this_is_book (10 pages)
```

### Edit e-book

Change title. Specify book id.

```
$ honyomi edit 1 -t "This is Book"
id:        1
title:     This is Book
path:      /path/to/this_is_book.pdf
pages:     10
timestamp: 2013-01-01 00:00:00
```

### List books

```
$ honyomi list
1 This is Book (10 pages)
2 That is Book (20 pages)
```

Show detail. Specify book id.

```
$ honyomi list 1
id:        1
title:     This is Book
path:      /path/to/this_is_book.pdf
pages:     10
timestamp: 2013-01-01 00:00:00
```

### Search command line

```
$ honyomi search bbb
1 matches
--- This is Book (5 page) ---
aaa <<bbb>> ccc
```

### Web application

```
$ honyomi web
```

![honyomi-02.png]()

