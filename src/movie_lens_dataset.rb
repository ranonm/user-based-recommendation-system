require "csv"

class MovieLensDataset
  attr_reader :movies, :dataset_path, :training, :testing
  class << self
    def dataset_path
      if @dataset_path.nil?
        @dataset_path = "dataset/ml-100k/"
      end
      @dataset_path
    end

    def movies
      if @movies.nil?
        @movies = {}
        CSV.foreach("#{dataset_path}u.item", { :col_sep => "\t" }) do |row|
          row = row[0].split("|")
          @movies[row[0]] = row[1]
        end
      end
      @movies
    end

    def training
      if @training.nil?
        @training = fetch_data("ua.base")
      end
      @training
    end

    def testing
      if @testing.nil?
        @testing = fetch_data("ua.test")
      end
      @testing
    end

    def fetch_data(filename)
      file_path = dataset_path + filename
      data = {}
      CSV.foreach(file_path, { :col_sep => "\t" }) do |row|
        uid, movie, rating = row[0], movies[row[1]], row[2].to_f
        data[uid] ||= {}
        data[uid][movie] = rating
      end
      data
    end

  end
  private_class_method :fetch_data, :dataset_path
end
