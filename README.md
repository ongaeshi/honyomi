# Honyomi

Honyomi is ebook (pdf) search engine written by Ruby. It have command line interface and web application. It will accelerate the ebook of your life.

Honyomi is "本読み". "Read a book" is meaning.

![honyomi-01.png]()

## Installation

    $ gem install honyomi

And, need 'pdftotext' command (poppler, xpdf ..)

## Usage

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

### Add book

```
$ honyomi add /path/to/this_is_book.pdf
A 1 this_is_book (10 pages)
```

### Edit book

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

