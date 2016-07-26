class CollaborativeFilter
  attr_reader :user_item_matrix, :similarity_function, :neighborhood_size, :test_matrix
  attr_accessor :rmse

  def initialize(training_dataset, testing_dataset=nil)
    @user_item_matrix = training_dataset
    @test_matrix = testing_dataset
  end


  # Similarity measure using Euclidean distance
  def similarity_score(active_user, other_user)
    case self.similarity_function
    when "euclidean"
      score = euclidean_distance_similarity(active_user, other_user)
    when "pearson"
      score = pearson_correlation_similarity(active_user, other_user)
    else
      score = 0
    end

    return score
  end


  # Similarity measure using Euclidean distance
  def euclidean_distance_similarity(user, other_user)
    co_rated_items = []
    sum_of_squares = 0

    user_item_matrix[user].each_key do |item|
      if user_item_matrix[other_user].has_key?(item)
        co_rated_items << item
      end
    end

    # No co-rated items
    return 0 if co_rated_items.count == 0

    # Find euclidean distance
    user_item_matrix[user].each_key do |item|
      if user_item_matrix[other_user].has_key?(item)
        sum_of_squares += (user_item_matrix[user][item] - user_item_matrix[other_user][item]) ** 2
      end
    end

    return 1/(1 + Math.sqrt(sum_of_squares))
  end

  # Similarity measure using Pearson correlation
  def pearson_correlation_similarity(user, other_user)
    co_rated_items = []
    dividend = multiplicand = multiplier = 0

    user_item_matrix[user].each_key do |item|
      if user_item_matrix[other_user].has_key?(item)
        co_rated_items << item
      end
    end

    # No co-rated items
    return 0 if co_rated_items.count == 0

    user_average_rating = average_rating(user)
    other_user_average_rating = average_rating(other_user)

    co_rated_items.each do |item|
      dividend += (user_item_matrix[user][item] - user_average_rating) * (user_item_matrix[other_user][item] - other_user_average_rating)
      multiplicand += (user_item_matrix[user][item] - user_average_rating) ** 2
      multiplier += (user_item_matrix[other_user][item] - other_user_average_rating) ** 2
    end
    divisor = Math.sqrt(multiplicand) * Math.sqrt(multiplier)

    return 0 if divisor == 0

    dividend/divisor
  end

  def set_similarity_function(similarity_function)
    unless ["euclidean", "pearson"].include?(similarity_function)
      puts "#{similarity_function} is not a supported similarity function."
      return false;
    end
    @similarity_function = similarity_function
  end

  def similarity_function
    if @similarity_function.nil?
      @similarity_function = "euclidean"
    end
    @similarity_function
  end

  def similar_users(active_user)
    similarity_scores = {}
    user_item_matrix.each do |other_user, ratings|
      unless other_user.eql? active_user
        similarity_scores[other_user] = similarity_score(active_user, other_user)
      end
    end
    best_scores(similarity_scores, neighborhood_size)
  end

  def set_neighborhood_size(k)
    unless k.is_a?(Integer) && k > 0
      puts "#{k} is not an Integer and/or #{k} is greater than zero."
      return false;
    end
    @neighborhood_size = k
  end

  def neighborhood_size
    if @neighborhood_size.nil?
      @neighborhood_size = 4
    end
    @neighborhood_size
  end

  def best_scores(scores, k)
    scores.max_by(k){ |item, score| score}.to_h
  end

  def best_predictions(predictions, item_count=1)
    predictions.max_by(item_count){ |prediction| prediction["rating"]}.collect do |prediction|
      prediction["item"]
    end
  end


  # Recommends item_count items to active_user
  def recommendations(active_user, item_count=1)
    predictions = []
    dividends, divisors = {}, {}

    co_rated_items = user_item_matrix[active_user].keys
    active_user_average_rating = average_rating(active_user, co_rated_items)

    neighbors = similar_users(active_user)

    neighbors.each do |neighbor, similarity|
      
      next if similarity <= 0

      ratings = user_item_matrix[neighbor]

      ratings.each do |item, rating|
        # Only make predictions for items not rated by active user
        if user_item_matrix[active_user][item].nil?
          dividends[item] ||= 0
          divisors[item] ||= 0
          average_co_rating = average_rating(neighbor, co_rated_items)

          dividends[item] += (rating - average_co_rating) * similarity
          divisors[item] += similarity
        end
      end
  
    end

    # Calculate weighted averages
    dividends.each do |item, dividend|
      predictions << { "item" => item, "rating" => active_user_average_rating + (dividend / divisors[item])}
    end

    unless test_matrix.nil?
      self.rmse = calculate_rmse(active_user, predictions)
    end

    # return top average as recommendation
    best_predictions(predictions, item_count)
  end

  def average_rating(user, items = nil)
    items_ratings = items.nil? ? user_item_matrix[user] : user_item_matrix[user].select{ |item, rating| items.include? item }

    co_ratings = items_ratings.collect {|item_id, rating| rating}
    (co_ratings.reduce(:+))/co_ratings.count
  end

  def calculate_rmse(active_user, predictions)
    total_squared_error = 0
    count = 0
    predictions.each do |item|
      actual_rating = test_matrix[active_user][item['item']]
      unless actual_rating.nil?
        total_squared_error += (item['rating'] - actual_rating) ** 2
        count += 1
      end
    end
    return count > 0 ? Math.sqrt(total_squared_error/count) : "No corresponding testing data found."
  end
end

