class UsedBooksController < ApplicationController
  require "uri"
  require "mechanize"

  def index
  end

  private

    # 매장 리스트
    STORE_LISTS = { 'gangnam' => '강남점', 'sinchon' => '신촌점', 'geondae' => '건대점',  'nowon' => '노원점', 'daehakro' => '대학로점',
                    'suyu' => '수유점', 'sillim' => '신림점', 'yeonsinnae' => '연신내점', 'jamsil' => '잠실롯데월드타워점',
                    'sincheon' => '잠실신천점', 'jongno' => '종로점', 'hapjeong' => '합정점' }

    # 매장 방문 URI
    STORE_URI = "http://off.aladin.co.kr/usedstore/wstoremain.aspx?offcode="

    # 검색 기본 URI
    SEARCH_URI = "http://off.aladin.co.kr/usedstore/wsearchresult.aspx?SearchWord="

    def get_used_books
      # 찾고자 하는 책
      target_book = params[:query].encode('euc-kr', 'utf-8') # EUC-KR 인코딩을 한 뒤에 쿼리
      # 매장별 결과를 담을 해시
      result = {}

      STORE_LISTS.keys.each do |store|
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

        book_list = []
        search_results = page.css('div.ss_book_box')
        search_results.each do |book|
          book_info = {}
          first_column = book.css('div.ss_book_list')[0]
          second_column = book.css('div.ss_book_list')[1]

          book_info[:title] = first_column.css('a.bo_l b').text
          book_info[:sub_title] = first_column.css('span.ss_f_g2').text

          # 특별한 순위를 매기는 경우 li 태그가 하나 더 늘어남 ex) 청소년 100위 2주
          if first_column.css('span.ss_ht2').empty?
            author_list = first_column.css('li')[1].text.split(' | ')
          else
            author_list = first_column.css('li')[2].text.split(' | ')
          end

          book_info[:author] = author_list[0].strip
          book_info[:publisher] = author_list[1].strip
          book_info[:pub_date] = author_list[2].strip

          book_info[:price] = second_column.css('span.ss_p2 b').text
          book_info[:stock] = second_column.css('span.ss_p4 b').text

          book_list << book_info
        end
        result[STORE_LISTS[store]] = book_list
      end
      render json: result
    end
end
