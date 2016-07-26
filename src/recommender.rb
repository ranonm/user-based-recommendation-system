require_relative "movie_lens_dataset"
require_relative "collaborative_filter"

class Recommender
  attr_reader :cf
  class << self
    def run
      @cf = CollaborativeFilter.new(MovieLensDataset.training, MovieLensDataset.testing)

      while TRUE
        input = self.ask "Identify active user (type \"exit\" to quit): "
        break if input.downcase.eql?("exit")

        active_user = input

        unless cf.user_item_matrix[active_user].nil?
          self.configure_similarity_function
          self.configure_neighborhood_size
          top_item_size = self.configure_max_item_size

          self.recommend(active_user, top_item_size)
          puts "Root mean square error: #{cf.rmse}"

          puts "Press any key to continue..."
          gets

        else
          next
        end





        system "clear"
      end
      system "clear"
      puts "Thank you for using the Collaborative Filter Recommendation System."
      puts "Bye!"

    end

    def ask(question)
      print "#{question} "
      gets.chomp
    end

    def configure_similarity_function
      similarity_func = ask "Which similarity measure (\"euclidean\" or \"pearson\")? "
      cf.set_similarity_function(similarity_func.downcase)
    end

    def configure_neighborhood_size
      neighborhood_size = ask "Set your neighborhood size (integer > 1): "
      cf.set_neighborhood_size(neighborhood_size.to_i)
    end

    def configure_max_item_size
      ask("Maximum recommended items: ").to_i
    end

    def recommend(active_user, item_count)
      recommendations = cf.recommendations(active_user, item_count)
      
      puts "For active user #{active_user}, I recommend: "
      
      recommendations.each do |recommendation|
        puts recommendation
      end
    end

    def cf
      @cf
    end
  end
end

Recommender.run