---
layout: layout-ja
title: Webインターフェース
---
# Webインターフェース

<img alt='honyomi' src='https://raw.githubusercontent.com/ongaeshi/honyomi/master/images/honyomi-03.gif' />

コマンドラインの使い方は[こちら](./commandline.html)。

実際に動くものを[本読みの図書館](http://ongaeshi.honyomi.me)で確認することができます。

## 検索

### キーワード検索

```
hello
```

### フレーズ検索

```
"hello world"
```

### 32ページへジャンプ

```
32
```

## フィルターオプション

### 書籍idで絞り込み

```
b:11 hello
```

### 書籍id(NOT)

```
-b:11 hello
```

### タイトル

```
t:hello world
```

### ページ番号

```
p:>100 p:<200  world
```

## ブックマーク

1. 星をクリックするとページをブックマークすることが出来ます
        %img(src="/image/bookmark-01.png")
        %img(src="/image/bookmark-02.png")
2. もういちどクリックするとメモを書くことができます
        %img(src="/image/bookmark-03.png")


