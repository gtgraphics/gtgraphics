# GTGRAPHICS

[<img src="https://codeclimate.com/github/gtgraphics/gtgraphics.png" />](https://codeclimate.com/github/gtgraphics/gtgraphics)

A project presentation and portfolio web site.

## Requirements

* Ruby 2.2.2
* Rails 4.2.2
* PostgreSQL
* ImageMagick
* ExifTool

## Setup

1. Make sure you have PostgreSQL and RVM installed
2. Install Ruby 2.2.2: `rvm install 2.2.2`
2. Install ImageMagick:  `sudo apt-get install imagemagick libmagickwand libmagickwand-dev`
2. Install ExifTool: `sudo apt-get install libimage-exiftool-perl perl-doc`
3. `bundle`
4. `rake db:setup`
5. `rails s`
