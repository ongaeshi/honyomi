# HISTORY - Honyomi

## 1.2 - 2015-07-03

* Add image command
  * It can be inline display of page on browser
  * Need 'pdftoppm'
* Remove duplicated :type => :boolean

* Add book on web
  * Drag & drop OR Dialog
  * If you want to disable this feature, set ENV["HONYOMI_DISABLE_WEB_ADD"]
    * $ HONYOMI_DISABLE_WEB_ADD=1 honyomi web

* Fix encode error
  * Specify file encoding in File.read
  * Add String#scrub

## 1.1 - 2015-06-23

* Add book on web
  * Drag & drop OR Dialog
  * If you want to disable this feature, set ENV["HONYOMI_DISABLE_WEB_ADD"]
    * $ HONYOMI_DISABLE_WEB_ADD=1 honyomi web

* Fix encode error
  * Specify file encoding in File.read
  * Add String#scrub

## 1.0 - 2014-11-15

* Bookmark a page
  * Click star
  * Is also attached comments
    * Link page no (P111)
    * Auto link http://...
    * Ctrl+Enter: Shortcut to Update

* Edit a book information on web
  * Title, Author, URL

* Convenient search query
  * `123`: Jump to page
  * `b:11 hello`: Book Id
  * `-b:11 hello`: Book Id (NOT)
  * `t:hello world`: Book Title
  * `p:>100 p:<200  world`: Page Number

* Help

* Clear Button

* Impliment Util.highlight_keywords using Groonga::PatriciaTrie#tag_keys instead of Pure Ruby

## 0.2 - 2014-10-07

* Improve search result
  * Highlight keywords
  * Take over the search query
* Improve text mode
  * Rename from 'raw' to 'text'
  * Highlight keywords
  * Take over the search query
  * Change rendering tag from <pre> to <div>
  * Change background color
* Change Navbar to static
* Add link to honyomi-web
* Refactor page tag

## 0.1 - 2014-10-02

* Search in book
* Display the book list
* Pagination (AutoPagerize)
* Add favicon

## 0.0.3 - 2014-07-18

* Support file name includes parenthesis or any special characters
