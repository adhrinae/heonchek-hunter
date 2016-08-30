module UsedBooksHelper
  def total_results
    @results.values.inject(0) {|sum, arr| sum + arr.size }
  end
end
