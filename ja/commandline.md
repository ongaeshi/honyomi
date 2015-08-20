---
layout: layout-ja
title: コマンドライン
---
# コマンドライン

## データベースの作成

```
$ honyomi init
Create database to "/home/username/.honyomi/db/honyomi.db"
```

データベースディレクトリの指定 (他のコマンドも同様)

```
$ HONYOMI_DATABASE_DIR=/path/to/dir honyomi init
Create database to "/path/to/dir/db/honyomi.db"
```

### 書籍の追加

`pdftoppm`コマンドが存在する場合はイメージも一緒に追加します。

```
$ honyomi add /path/to/this_is_book.pdf
A 1 this_is_book (10 pages)
```

### 書籍のイメージを追加

ページの内容をブラウザ上で閲覧することができます。`pdftoppm`コマンドが必要です。

```
$ honyomi image 1
Generated images to '/Users/ongaeshi/.honyomi/image/1'
```

### 書籍の編集

タイトルなどを変更します。書籍idを指定します。

```
$ honyomi edit 1 -t "This is Book"
id:        1
title:     This is Book
path:      /path/to/this_is_book.pdf
pages:     10
timestamp: 2013-01-01 00:00:00
```

### 書籍の一覧表示

```
$ honyomi list
1 This is Book (10 pages)
2 That is Book (20 pages)
```

書籍idを指定すると詳細が表示されます。

```
$ honyomi list 1
id:        1
title:     This is Book
path:      /path/to/this_is_book.pdf
pages:     10
timestamp: 2013-01-01 00:00:00
```

### コマンドラインから検索

```
$ honyomi search bbb
1 matches
--- This is Book (5 page) ---
aaa <<bbb>> ccc
```

### Webアプリケーションの起動

```
$ honyomi web
```

詳しい使い方は[Webインターフェース](./webinterface.html)へ

### Basic認証

Webアプリケーションに簡易認証をかけることができます。

(1) パスワードのSHA-2ハッシュを取得します

```
$ ruby -r 'digest/sha2' -e 'puts Digest::SHA256.hexdigest("this_is_password")'
a6a27374ec8f49426e8ee6249125369e8c529f361ffa20ace73de0b92514bb0f
```

(2) 環境変数に渡します

```
$ HONYOMI_AUTH_USERNAME=ongaeshi HONYOMI_AUTH_PASSWORD=a6a27374ec8f49426e8ee6249125369e8c529f361ffa20ace73de0b92514bb0f honyomi web
```
