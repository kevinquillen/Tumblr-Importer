Tumblr Importer
===============

A simple Tumblr importer. Imports flat HTML files into Tumblr blog posts. This is more or less just an exercise for me with the Tumblr API and learning Ruby.

The system I am moving from is Octopress- I lost all my .markdown files that made the site, so I thought it would be fun to see if I could recreate it from the rendered HTML, snatch the post title, body, tags, and date, and import it to Tumblr via their API.

Setup
=====

1. Assemble all the HTML files you wish to import as posts, and drop them into an 'html' folder in the same folder the converter.rb script is contained.
2. Place your OAuth key at the top to use to connect to your Tumblr.
3. From the command line, navigate to the directory containing converter.rb, and type 'ruby converter.rb'.