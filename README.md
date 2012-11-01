Tumblr Importer
===============

A simple Tumblr importer. Imports flat HTML files into Tumblr blog posts. This is more or less just an exercise for me with the Tumblr API and learning Ruby.

The system I am moving from is Octopress- I lost all my .markdown files that made the site, so I thought it would be fun to see if I could recreate it from the rendered HTML, snatch the post title, body, tags, and date, and import it to Tumblr via their API.

Setup
=====

1. Assemble all the HTML files you wish to import as posts, and drop them into an 'html' folder in the same folder the converter.rb script is contained.
2. Setup an Application at Tumblr, and keep a browser window open containing the OAuth Consumer Key and Secret Key. The callback URL should be http://localhost/.
3. From the command line, navigate to the directory containing converter.rb, and type 'ruby converter.rb'.
4. Enter each value at the prompt, your blog hostname and OAuth keys.
5. If OAuth request is successful, it will give you an authorization URL. Post this into your browser, and allow the app access to your Tumblr account.
6. When redirected to http://localhost/, copy the OAuth Verifier key in the URL, and paste that back into the command line when prompted. If authentication is successful, all posts will start moving to Tumblr.

The script will then look for all .html files in all the directories, and pick out the title, body content, category tags, and publish date using Nokogiri.

Since this script was based on Octopress, Nokogiri is looking for the following elements with these classes:

* Post Title: 'h1.entry-title'
* Post Body:  'div.entry-content'
* Post Tags:  'span.categories a'
* Post Date:  'time'