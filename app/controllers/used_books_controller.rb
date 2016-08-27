class UsedBooksController < ApplicationController
  require "nokogiri"
  require "open-uri"
  require "uri"
  include UsedBooksHelper

  def index
    get_used_books
  end

  private

    # 매장 리스트
    STORE_LISTS = %w(Gangnam Sinchon Geondae Nowon Daehakro
                     Suyu Sillim Yeonsinnae Jamsil Sincheon Jongno Hapjeong)
    # 검색 기본 URI
    SEARCH_URI = "http://off.aladin.co.kr/usedstore/wsearchresult.aspx?SearchWord="

    # Unknown, but required
    X_Y = URI.encode("&x=0&y=0".encode('euc-kr', 'utf-8'))

    def get_used_books
      # 찾고자 하는 책
      target_book = URI.encode(params[:query].encode('euc-kr', 'utf-8'))
      puts target_book
      # 매장별 결과를 담을 해시
      result = {}

      STORE_LISTS.each do |store|
        uri = SEARCH_URI + target_book + X_Y + URI.encode("?Offcode=#{store}".encode('euc-kr', 'utf-8'))
        page = Nokogiri::HTML(open(uri, 'r:binary').read.encode('utf-8', 'euc-kr'))
        titles = []

        search_results = page.css('div.ss_book_box td a.bo_l b')
        search_results.each do |book|
          titles << book.text
        end
        result[store] = titles
      end
      render json: result
    end
end
