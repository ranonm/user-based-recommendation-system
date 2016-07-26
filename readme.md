# Collaborative Filtering: Implementation of a user-based recommendation system using K-Nearest Neighbor

Individual graduate course work; Conducted research on collaborative filtering and implemented a user-based recommendation system using the K-Nearest Neighbor algorithm in Ruby.

## Application file structure

The entire user-based recommendation system implementation spans over multiple files, with the following file structure:

* dataset (Movie lens dataset)
* collaborative_filter.rb
* movie_lens_dataset.rb 
* recommender.rb
* simple_dataset.rb (Simple test dataset)


## System requirements
You need Ruby 2.2.1+ to run this script.
Please go to [Ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/) to download the latest version of Ruby.


## How to run the Recommender

1. Download source directory to desired location on local computer.
2. Enter source code directory.
3. Type "ruby recommender.rb" to start the Recommender.


## Interacting with the Recommender

* When the Recommender asks for an active user, enter a number between 1 - 943 or type "exit" to quit.
* When the Recommender asks for the similarity measure, type "euclidean" or "pearson"
* When the Recommender asks for the neighborhood size, enter an integer that is greater than or equal to 1.
* When the Recommender asks for the maximum recommended items, enter an integer that is greater than or equal to 1.
