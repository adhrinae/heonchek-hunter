class UsedBooksController < ApplicationController
  require "uri"
  require "mechanize"

  def index
    get_used_books
  end

  private

    # 매장 리스트
    STORE_LISTS = %w(gangnam sinchon geondae nowon daehakro
                     suyu sillim yeonsinnae jamsil sincheon jongno hapjeong)

    # 매장 방문 URI
    STORE_URI = "http://off.aladin.co.kr/usedstore/wstoremain.aspx?offcode="

    # 검색 기본 URI
    SEARCH_URI = "http://off.aladin.co.kr/usedstore/wsearchresult.aspx?SearchWord="

    def get_used_books
      # 찾고자 하는 책
      target_book = params[:query].encode('euc-kr', 'utf-8') # EUC-KR 인코딩을 한 뒤에 쿼리
      # 매장별 결과를 담을 해시
      result = {}

      STORE_LISTS.each do |store|
        # 각 매장별 페이지 주소
        to_store = URI.parse(STORE_URI + store)
        # Mechanize 객체 생성
        agent = Mechanize.new

        # 각 매장별 인덱스 페이지 진입 후, 폼에 책 제목을 입력한 뒤에 제출, 그리고 그 결과를 받아온다.
        store_index = agent.get(to_store)
        search_form = store_index.form('QuickSearch')
        search_form['SearchWord'] = target_book
        page = agent.submit(search_form)
        page.encoding = 'EUC-KR' # 결과 리턴받는데 반드시 인코딩을 지정해주어야 함. 안그러면 한글 깨짐

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
