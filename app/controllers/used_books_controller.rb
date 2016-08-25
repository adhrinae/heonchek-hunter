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
    STORE_LISTS = %w(gangnam sinchon geondae nowon daehakro
                     suyu sillim yeonsinnae jamsil sincheon jongno hapjeong)
    # 검색 기본 URI
    SEARCH_URI = "http://off.aladin.co.kr/usedstore/wsearchresult.aspx?SearchWord="

    # Unknown, but required
    X_Y = "&x=0&y=0"

    def get_used_books
      # 찾고자 하는 책
      target_book = params[:query].to_s
      # 매장별 결과를 담을 해시
      result = {}

      STORE_LISTS.each do |store|
        uri = SEARCH_URI + target_book + X_Y + "?offcode=#{store}"
        page = Nokogiri::HTML(open uri)

        search_result = page.css('div.ss_book_box')
      end
    end
end
